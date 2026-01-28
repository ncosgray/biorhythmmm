/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    biorhythm_chart.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Biorhythm line chart
// - Percentage widget
// - Biorhythm comparison
// - Chart interactivity (touch, pan, zoom)

import 'package:biorhythmmm/common/helpers.dart';
import 'package:biorhythmmm/common/notifications.dart';
import 'package:biorhythmmm/common/styles.dart';
import 'package:biorhythmmm/data/app_state.dart';
import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:biorhythmmm/data/localization.dart';
import 'package:biorhythmmm/data/prefs.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:vector_math/vector_math_64.dart' show Vector3;

// Chart
final GlobalKey chartKey = GlobalKey();
final TransformationController chartController = TransformationController();

// Chart ranges
final int chartRange = 180;
final int chartRangeSplit = (chartRange / 2).floor();
final int chartGrid = 7;
final double chartWindow = chartGrid * 4.5;

// Interactive biorhythm chart
class BiorhythmChart extends StatefulWidget {
  const BiorhythmChart({super.key});

  @override
  State<StatefulWidget> createState() => _BiorhythmChartState();
}

class _BiorhythmChartState extends State<BiorhythmChart>
    with WidgetsBindingObserver {
  // State variables
  List<BiorhythmPoint> _points = [];
  List<BiorhythmPoint> _comparePoints = [];
  Biorhythm? _highlighted;
  double? _touched;

  // Populate data points
  void setPoints([
    List<BiorhythmPoint>? newPoints,
    List<BiorhythmPoint>? newComparePoints,
  ]) {
    final List<Biorhythm> biorhythms = context.read<AppStateCubit>().biorhythms;

    if (newPoints != null) {
      // Update points with specified data
      _points = newPoints;
    } else {
      // Reset points to today
      final int day = dateDiff(context.read<AppStateCubit>().birthday, today);
      _points = [
        for (final Biorhythm b in biorhythms) b.getBiorhythmPoint(day),
      ];
    }

    // Update comparison points if applicable
    if (newComparePoints != null) {
      _comparePoints = newComparePoints;
    } else {
      final DateTime? compareBirthday = context
          .read<AppStateCubit>()
          .compareBirthday;
      if (compareBirthday != null) {
        final int compareDay = dateDiff(compareBirthday, today);
        _comparePoints = [
          for (final Biorhythm b in biorhythms) b.getBiorhythmPoint(compareDay),
        ];
      } else {
        _comparePoints = [];
      }
    }
  }

  // Reset biorhythm chart and points to today
  void resetChart() {
    if (mounted) {
      setPoints();
      _highlighted = null;
      context.read<AppStateCubit>().reload();
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    // Handle notification taps
    Notifications.onNotificationTap = () => selectNotifyBirthday();

    // Handle cold start from notification
    Notifications.launchedFromNotification().then((fromNotification) {
      if (fromNotification) {
        selectNotifyBirthday();
      }
    });

    // Update the chart
    resetChart();
    super.initState();

    // Show the reset button when the chart gets transformed
    chartController.addListener(
      () => context.read<AppStateCubit>().enableResetButton(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Notifications.onNotificationTap = null;
    chartController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BiorhythmChart oldWidget) {
    resetChart();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      resetChart();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didChangeMetrics() {
    // Add a small delay to allow the new layout to be calculated
    Future.delayed(const Duration(milliseconds: 100), () => resetChart());
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppStateCubit, AppState>(
      builder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Process a reload request
          if (state.reload) {
            // Scale chart to show default range centered on today
            double scale = chartRange / chartWindow;
            double offset = -((chartRange - chartWindow + 1) / 2);
            double widthFactor =
                chartKey.currentContext!.size!.width / chartRange;
            double translate = offset * widthFactor;
            chartController.value = Matrix4.identity()
              ..scaleByVector3(Vector3(scale, 1, 1))
              ..translateByVector3(Vector3(translate, 0, 0));
            context.read<AppStateCubit>().resetReload();
          }
        });

        // Biorhythm chart and points
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(child: biorhythmChart),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Center(child: biorhythmPoints),
            ),
          ],
        );
      },
    );
  }

  // Display biorhythm chart for notify birthday
  void selectNotifyBirthday() {
    if (mounted) {
      context.read<AppStateCubit>().setSelectedBirthday(
        Prefs.notifyBirthdayIndex,
      );
    }
  }

  // Create a line chart graphing biorhythm data
  LineChart get biorhythmChart => LineChart(
    chartData,
    chartRendererKey: chartKey,
    duration: Duration.zero,
    transformationConfig: chartTransformation,
  );

  // Define chart data
  LineChartData get chartData => LineChartData(
    gridData: gridData,
    titlesData: titlesData,
    borderData: borderData,
    rangeAnnotations: context.read<AppStateCubit>().showCriticalZone
        ? criticalZoneAnnotation
        : null,
    lineBarsData: lineBarsData,
    lineTouchData: lineTouchData,
    maxY: 1,
    minY: -1,
  );

  List<LineChartBarData> get lineBarsData {
    List<Biorhythm> biorhythms = context.read<AppStateCubit>().biorhythms;
    final DateTime birthday = context.read<AppStateCubit>().birthday;
    final DateTime? compareBirthday = context
        .read<AppStateCubit>()
        .compareBirthday;

    if (_highlighted != null) {
      // Sort the biorhythm lines with highlighted first (end of the stack)
      biorhythms = List.from(biorhythms)
        ..sort((a, b) {
          if (a == _highlighted) return 1;
          if (b == _highlighted) return -1;
          return 0;
        });
    }

    return [
      for (final Biorhythm b in biorhythms)
        biorhythmLineData(
          birthday: birthday,
          color: getBiorhythmColor(b, isHighlighted: _highlighted == b),
          pointCount: chartRange,
          pointGenerator: b.getPoint,
        ),
      if (compareBirthday != null)
        for (final Biorhythm b in biorhythms)
          biorhythmLineData(
            birthday: compareBirthday,
            color: getBiorhythmColor(b, isHighlighted: _highlighted == b),
            pointCount: chartRange,
            pointGenerator: b.getPoint,
            dashedLine: true,
          ),
    ];
  }

  LineChartBarData biorhythmLineData({
    required DateTime birthday,
    required Color color,
    required int pointCount,
    required double Function(int) pointGenerator,
    bool dashedLine = false,
  }) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        getDotPainter: dotPainter,
        // Always show dots for today unless user is touching elsewhere
        checkToShowDot: (spot, _) => spot.x == 0 && _touched == null,
      ),
      belowBarData: BarAreaData(show: false),
      dashArray: dashedLine ? [6, 8] : null,
      // Graph a range of biorhythm points
      spots: List.generate(
        pointCount,
        (int day) => FlSpot(
          (day - chartRangeSplit).toDouble(),
          pointGenerator(
            dateDiff(birthday, today, addDays: day - chartRangeSplit),
          ),
        ),
      ),
    );
  }

  // Chart interactivity
  LineTouchData get lineTouchData => LineTouchData(
    handleBuiltInTouches: true,
    touchCallback: touchCallback,
    // Draw a spot indicator with vertical line extending to the top
    getTouchedSpotIndicator: (barData, spotIndexes) {
      return spotIndexes.map((spotIndex) {
        return TouchedSpotIndicatorData(
          FlLine(color: Colors.transparent),
          FlDotData(getDotPainter: dotPainter),
        );
      }).toList();
    },
    touchTooltipData: LineTouchTooltipData(
      showOnTopOfTheChartBoxArea: true,
      fitInsideHorizontally: true,
      fitInsideVertically: true,
      getTooltipItems: (List<LineBarSpot> touchedSpots) {
        List<LineTooltipItem?> items = List.filled(touchedSpots.length, null);

        if (touchedSpots.isNotEmpty) {
          final DateTime birthday = context.read<AppStateCubit>().birthday;
          final DateTime? compareBirthday = context
              .read<AppStateCubit>()
              .compareBirthday;
          final int addDays = touchedSpots[0].x.toInt();

          // Indicate with a symbol if this is a critical day
          String criticalIndicator =
              touchedSpots.where((spot) => isCritical(spot.y)).isNotEmpty
              ? '\u26A0'
              : '';

          // Date label
          String tooltipText =
              criticalIndicator +
              dateAndDay(today.add(Duration(days: addDays))) +
              criticalIndicator;

          // Append biorhythm values for both birthdays when comparing
          if (compareBirthday != null) {
            tooltipText += '\n\n${context.read<AppStateCubit>().birthdayName}';
            tooltipText += tooltipBiorhythmsText(
              dateDiff(birthday, today, addDays: addDays),
            );

            tooltipText +=
                '\n\n${context.read<AppStateCubit>().compareBirthdayName}';
            tooltipText += tooltipBiorhythmsText(
              dateDiff(compareBirthday, today, addDays: addDays),
            );
          }

          // Build the tooltip as a single item
          items[0] = LineTooltipItem(tooltipText, titleText);
        }
        return items;
      },
      getTooltipColor: (touchedSpot) => Theme.of(context).dividerColor,
    ),
  );

  String tooltipBiorhythmsText(int day) {
    final List<Biorhythm> biorhythms = context.read<AppStateCubit>().biorhythms;
    String text = '';

    for (final Biorhythm b in biorhythms) {
      // Build the text for this biorhythm
      text +=
          '\n${b.localizedName.substring(0, 3)}: ${shortPercent(b.getPoint(day))}';
    }

    return text;
  }

  void touchCallback(FlTouchEvent event, LineTouchResponse? response) {
    setState(() {
      if (event.isInterestedForInteractions) {
        if (response?.lineBarSpots != null) {
          final List<TouchLineBarSpot> spots = response!.lineBarSpots!;
          final List<Biorhythm> biorhythms = context
              .read<AppStateCubit>()
              .biorhythms;
          final DateTime birthday = context.read<AppStateCubit>().birthday;
          final DateTime? compareBirthday = context
              .read<AppStateCubit>()
              .compareBirthday;

          // Update points for percent displays
          setPoints(
            [
              for (final TouchLineBarSpot spot in spots)
                if (spot.barIndex < biorhythms.length)
                  biorhythms[spot.barIndex].getBiorhythmPoint(
                    dateDiff(birthday, today, addDays: spot.x.toInt()),
                  ),
            ],
            [
              if (compareBirthday != null)
                for (final TouchLineBarSpot spot in spots)
                  if (spot.barIndex < biorhythms.length)
                    biorhythms[spot.barIndex].getBiorhythmPoint(
                      dateDiff(compareBirthday, today, addDays: spot.x.toInt()),
                    ),
            ],
          );

          // Update the touched position
          _touched = response.lineBarSpots![0].x;
        }
      } else {
        // Reset points to today
        setPoints();
        _touched = null;
      }
    });
  }

  // Chart grids and dots
  FlGridData get gridData => FlGridData(
    show: true,
    drawHorizontalLine: true,
    drawVerticalLine: true,
    horizontalInterval: 0.25,
    verticalInterval: 1,
    getDrawingHorizontalLine: getDrawingHorizontalLine,
    getDrawingVerticalLine: getDrawingVerticalLine,
  );

  FlLine getDrawingHorizontalLine(double value) {
    return value == 0
        // Critical
        ? FlLine(color: Colors.amber, strokeWidth: 2)
        // Indicate positive and negative cycles with color coding
        : FlLine(
            color: value > 0 ? Colors.green : Colors.red,
            strokeWidth: 1,
            dashArray: [2, 2],
          );
  }

  FlLine getDrawingVerticalLine(double value) {
    // Default grid line
    double strokeWidth = 1;
    if (value == 0) {
      // Today (with touched highlight)
      strokeWidth = (value == _touched) ? 7 : 6;
    } else if (value == _touched) {
      // Touched position
      strokeWidth = 3;
    } else if (value.abs() % chartGrid == 0) {
      // Date labels
      strokeWidth = 2;
    }

    return FlLine(
      color: Theme.of(context).dividerColor,
      strokeWidth: strokeWidth,
    );
  }

  FlDotPainter dotPainter(
    FlSpot spot,
    double percent,
    LineChartBarData barData,
    int index,
  ) {
    Biorhythm? biorhythm = allBiorhythms
        .where((b) => getBiorhythmColor(b) == barData.color)
        .firstOrNull;

    // Use the highlight color if touched or fallback to the bar color
    final Color dotColor = biorhythm != null && _touched != null
        ? getBiorhythmColor(biorhythm, isHighlighted: true)
        : barData.color ?? Colors.transparent;

    return FlDotCirclePainter(radius: 6, color: dotColor);
  }

  // Chart colors
  Color getBiorhythmColor(Biorhythm biorhythm, {bool isHighlighted = false}) =>
      biorhythm.getChartColor(
        isHighlighted: isHighlighted,
        useAccessibleColors: context.read<AppStateCubit>().useAccessibleColors,
      );

  // Chart titles
  FlTitlesData get titlesData => FlTitlesData(
    bottomTitles: AxisTitles(sideTitles: bottomTitles),
    rightTitles: noTitles,
    topTitles: noTitles,
    leftTitles: noTitles,
  );

  AxisTitles get noTitles =>
      const AxisTitles(sideTitles: SideTitles(showTitles: false));

  SideTitles get bottomTitles => SideTitles(
    showTitles: true,
    reservedSize: titleText.fontSize! * 2,
    interval: 1,
    getTitlesWidget: bottomTitleWidgets,
  );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    Widget title = Container();

    if (value == 0) {
      // Today
      title = Text(AppString.todayLabel.translate(), style: titleTodayText);
    } else if (value.abs() % chartGrid == 0) {
      // Date labels
      title = Text(
        shortDate(today.add(Duration(days: value.toInt()))),
        style: titleDateText,
      );
    }

    return title;
  }

  // Chart borders
  BorderSide borderSideData([Color? color]) =>
      BorderSide(color: color ?? Theme.of(context).dividerColor, width: 2);

  FlBorderData get borderData => FlBorderData(
    show: true,
    border: Border(
      bottom: borderSideData(Colors.pink),
      left: borderSideData(),
      right: borderSideData(),
      top: borderSideData(Colors.green),
    ),
  );

  // Chart annotation for critical zone
  RangeAnnotations get criticalZoneAnnotation => RangeAnnotations(
    horizontalRangeAnnotations: [
      HorizontalRangeAnnotation(
        y1: -criticalThreshold,
        y2: criticalThreshold,
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.amberAccent.withValues(alpha: 0.01),
            Colors.amberAccent.withValues(alpha: 0.65),
            Colors.amberAccent.withValues(alpha: 0.01),
          ],
        ),
      ),
    ],
  );

  // Chart tranformation
  FlTransformationConfig get chartTransformation => FlTransformationConfig(
    scaleAxis: FlScaleAxis.horizontal,
    maxScale: chartWindow,
    scaleEnabled: true,
    panEnabled: true,
    transformationController: chartController,
  );

  // Wrapping list of current biorhythm point data
  Widget get biorhythmPoints => BlocListener<AppStateCubit, AppState>(
    listener: (context, state) {
      // Redraw points if birthday or biorhythm selection changes
      setPoints();
    },
    listenWhen: (previous, current) =>
        previous.birthdays != current.birthdays ||
        previous.selectedBirthday != current.selectedBirthday ||
        previous.compareBirthday != current.compareBirthday ||
        previous.biorhythms != current.biorhythms,
    child: Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (int i = 0; i < _points.length; i++)
          biorhythmPercentBox(
            _points[i],
            comparePoint: _comparePoints.isNotEmpty ? _comparePoints[i] : null,
          ),
      ],
    ),
  );

  // Display a biorhythm point as a percentage with label
  Widget biorhythmPercentBox(
    BiorhythmPoint point, {
    BiorhythmPoint? comparePoint,
  }) {
    IconData icon = point.trend.trendIcon;
    String percentText = shortPercent(point.point);

    // Calculate comparison and assign a status icon
    if (comparePoint != null) {
      double compareValue = 1 - (comparePoint.point - point.point).abs() / 2;
      icon = compareValue > .45 && compareValue < .55
          ? Icons.sentiment_neutral
          : compareValue >= .55
          ? Icons.sentiment_satisfied_outlined
          : Icons.sentiment_dissatisfied_outlined;
      percentText = shortPercent(compareValue);
    }

    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(8),
        width: pointText.fontSize! * 6.2,
        height: pointText.fontSize! * 4.2,
        decoration: BoxDecoration(
          color: getBiorhythmColor(
            point.biorhythm,
            isHighlighted: _highlighted == point.biorhythm,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Name label
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(point.biorhythm.localizedName, style: labelText),
            ),
            // Point percentage with phase icon
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (comparePoint != null)
                    Icon(Icons.sync_alt, size: pointText.fontSize!),
                  Text(percentText, style: pointText),
                  Icon(icon, size: pointText.fontSize!),
                ],
              ),
            ),
          ],
        ),
      ),
      // Chart interactivity
      onTapDown: (_) => setState(() => _highlighted = point.biorhythm),
      onTapUp: (_) => setState(() => _highlighted = null),
      onTapCancel: () => setState(() => _highlighted = null),
    );
  }
}
