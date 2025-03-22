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
// - Chart interactivity (touch, pan, zoom)

import 'package:biorhythmmm/common/helpers.dart';
import 'package:biorhythmmm/common/strings.dart';
import 'package:biorhythmmm/common/styles.dart';
import 'package:biorhythmmm/data/app_state.dart';
import 'package:biorhythmmm/data/biorhythm.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Chart
final GlobalKey chartKey = GlobalKey();
final TransformationController chartController = TransformationController();

// Chart ranges
final int chartRange = 180;
final int chartRangeSplit = (chartRange / 2).floor();
final int chartWindow = 14;

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
  Biorhythm? _highlighted;

  // Populate data points
  void setPoints([List<BiorhythmPoint>? newPoints]) {
    if (newPoints != null) {
      // Update points with specified data
      _points = newPoints;
    } else {
      // Reset points to today
      int day = dateDiff(context.read<AppStateCubit>().birthday, today);
      _points = [
        for (final Biorhythm b in context.read<AppStateCubit>().biorhythms)
          b.getBiorhythmPoint(day),
      ];
    }
  }

  // Reset biorhythm chart and points to today
  void resetChart() {
    setPoints();
    _highlighted = null;
    context.read<AppStateCubit>().reload();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    resetChart();
    super.initState();

    // Show the reset button when the chart gets transformed
    chartController
        .addListener(() => context.read<AppStateCubit>().enableResetButton());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppStateCubit, AppState>(
      builder: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Process a reload request
          if (state.reload) {
            // Scale chart to show default range
            double scaleFactor = chartRangeSplit / chartWindow;
            double chartWidth = chartKey.currentContext!.size!.width;
            chartController.value = Matrix4.identity()
              ..scale(scaleFactor)
              ..translate(-((chartWidth - chartWindow) / 2));
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

  // Create a line chart graphing biorhythm data
  LineChart get biorhythmChart => LineChart(
        chartData,
        chartRendererKey: chartKey,
        duration: Duration.zero,
        transformationConfig: chartTransformation,
      );

  // Define chart data
  LineChartData get chartData => LineChartData(
        lineBarsData: lineBarsData,
        lineTouchData: lineTouchData,
        gridData: gridData,
        titlesData: titlesData,
        borderData: borderData,
        maxY: 1,
        minY: -1,
      );

  List<LineChartBarData> get lineBarsData => [
        for (final Biorhythm b in context.read<AppStateCubit>().biorhythms)
          biorhythmLineData(
            color: _highlighted == b ? b.highlightColor : b.graphColor,
            pointCount: chartRange,
            pointGenerator: b.getPoint,
          ),
      ];

  LineChartBarData biorhythmLineData({
    required Color color,
    required int pointCount,
    required double Function(int) pointGenerator,
  }) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      // Graph a range of biorhythm points
      spots: List.generate(
        pointCount,
        (int day) => FlSpot(
          (day - chartRangeSplit).toDouble(),
          pointGenerator(
            dateDiff(
              context.read<AppStateCubit>().birthday,
              today,
              addDays: day - chartRangeSplit,
            ),
          ),
        ),
      ),
    );
  }

  // Chart interactivity
  LineTouchData get lineTouchData => LineTouchData(
        handleBuiltInTouches: true,
        touchCallback: touchCallback,
        touchTooltipData: LineTouchTooltipData(
          showOnTopOfTheChartBoxArea: true,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            // Show date on tooltip with no other items
            List<LineTooltipItem?> items =
                List.filled(touchedSpots.length, null);
            if (touchedSpots.isNotEmpty) {
              items[0] = LineTooltipItem(
                dateAndDay(
                  today.add(Duration(days: touchedSpots[0].x.toInt())),
                ),
                titleText,
              );
            }
            return items;
          },
          getTooltipColor: (touchedSpot) => Theme.of(context).dividerColor,
        ),
      );

  void touchCallback(FlTouchEvent event, LineTouchResponse? response) {
    setState(() {
      if (event.isInterestedForInteractions) {
        if (response?.lineBarSpots != null) {
          // Update points for percent displays
          setPoints(
            [
              for (final TouchLineBarSpot spot in response!.lineBarSpots!)
                context
                    .read<AppStateCubit>()
                    .biorhythms[spot.barIndex]
                    .getBiorhythmPoint(
                      dateDiff(
                        context.read<AppStateCubit>().birthday,
                        today,
                        addDays: spot.x.toInt(),
                      ),
                    ),
            ],
          );
        }
      } else {
        // Reset points to today
        setPoints();
      }
    });
  }

  // Chart grids
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
        ? FlLine(
            color: Colors.amber,
            strokeWidth: 2,
          )
        : FlLine(
            color: value > 0 ? Colors.green : Colors.red,
            strokeWidth: 1,
            dashArray: [2, 2],
          );
  }

  FlLine getDrawingVerticalLine(double value) {
    return FlLine(
      color: Theme.of(context).dividerColor,
      strokeWidth: value == 0 ? 8 : 1,
    );
  }

  // Chart titles
  FlTitlesData get titlesData => FlTitlesData(
        bottomTitles: AxisTitles(sideTitles: bottomTitles),
        rightTitles: noTitles,
        topTitles: noTitles,
        leftTitles: noTitles,
      );

  AxisTitles get noTitles => const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      );

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: titleText.fontSize! * 2,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    Widget title = Container();

    if (value == 0) {
      title = Text(
        Str.todayLabel,
        style: titleTodayText,
      );
    } else if (value.abs() % (chartWindow / 2) == 0) {
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

  // Chart tranformation
  FlTransformationConfig get chartTransformation => FlTransformationConfig(
        scaleAxis: FlScaleAxis.horizontal,
        minScale: chartWindow / 4,
        maxScale: chartWindow.toDouble(),
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
            previous.birthday != current.birthday ||
            previous.biorhythms != current.biorhythms,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (int i = 0; i < _points.length; i++)
              biorhythmPercentBox(_points[i]),
          ],
        ),
      );

  // Display a biorhythm point as a percentage with label
  Widget biorhythmPercentBox(BiorhythmPoint point) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _highlighted == point.biorhythm
              ? point.biorhythm.highlightColor
              : point.biorhythm.graphColor,
        ),
        child: Column(
          children: [
            // Name label
            Text(
              point.biorhythm.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelText,
            ),
            // Point percentage with phase icon
            SizedBox.fromSize(
              size: Size(
                pointText.fontSize! * 4.8,
                pointText.fontSize! * 1.8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shortPercent(point.point),
                    style: pointText,
                  ),
                  Icon(
                    point.trend.trendIcon,
                    size: pointText.fontSize!,
                  ),
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
