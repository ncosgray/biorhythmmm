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

import 'package:biorhythmmm/app_model.dart';
import 'package:biorhythmmm/biorhythm.dart';
import 'package:biorhythmmm/helpers.dart';
import 'package:biorhythmmm/strings.dart';
import 'package:biorhythmmm/styles.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

// Chart ranges
final GlobalKey chartKey = GlobalKey();
final int chartRange = 180;
final int chartRangeSplit = (chartRange / 2).floor();
final int chartWindow = 14;

// Interactive biorhythm chart
class BiorhythmChart extends WatchingStatefulWidget {
  const BiorhythmChart({super.key});

  @override
  State<StatefulWidget> createState() => BiorhythmChartState();
}

class BiorhythmChartState extends State<BiorhythmChart> {
  // State variables
  Biorhythm? _highlighted;
  late List<double> _chartPoints;
  final TransformationController _controller = TransformationController();

  // Populate chart data
  void setPoints() {
    _chartPoints = List.generate(
      di<AppModel>().biorhythms.length,
      (i) => di<AppModel>()
          .biorhythms[i]
          .getPoint(dateDiff(di<AppModel>().birthday, today)),
    );
  }

  // Reset biorhythm points to today
  void resetPoints() {
    di<AppModel>().resetChart = true;
    _highlighted = null;
    setPoints();
  }

  @override
  void initState() {
    resetPoints();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BiorhythmChart oldWidget) {
    resetPoints();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final resetChart = watchPropertyValue((AppModel m) => m.resetChart);
    final showExtraPoints =
        watchPropertyValue((AppModel m) => m.showExtraPoints);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (resetChart) {
        di<AppModel>().resetChart = false;

        // Scale chart to show default range
        double scaleFactor = chartRangeSplit / chartWindow;
        double chartWidth = chartKey.currentContext!.size!.width;
        _controller.value = Matrix4.identity()
          ..scale(scaleFactor)
          ..translate(-((chartWidth - chartWindow) / 2));
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Biorhythm chart
        Expanded(
          child: LineChart(
            biorhythmData,
            key: chartKey,
            duration: Duration.zero,
            transformationConfig: FlTransformationConfig(
              scaleAxis: FlScaleAxis.horizontal,
              minScale: chartWindow / 4,
              maxScale: chartWindow.toDouble(),
              scaleEnabled: true,
              panEnabled: true,
              transformationController: _controller,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Biorhythm percentages
                for (int i = 0; i < _chartPoints.length; i++)
                  biorhythmPercentBox(
                    biorhythm: di<AppModel>().biorhythms[i],
                    point: _chartPoints[i],
                  ),
                // Toggle extra biorhythms
                IconButton(
                  onPressed: () {
                    di<AppModel>().toggleExtraPoints();
                    setPoints();
                  },
                  icon: showExtraPoints
                      ? Icon(Icons.keyboard_double_arrow_left)
                      : Icon(Icons.keyboard_double_arrow_right),
                  iconSize: 28,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Create a line chart graphing biorhythm data
  LineChartData get biorhythmData => LineChartData(
        lineTouchData: lineTouchData,
        gridData: gridData,
        titlesData: titlesData,
        borderData: borderData,
        lineBarsData: lineBarsData,
        maxY: 1,
        minY: -1,
      );

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
                shortDate(
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
    if (event.isInterestedForInteractions) {
      if (response?.lineBarSpots != null) {
        // Update percent displays
        for (int i = 0; i < response!.lineBarSpots!.length; i++) {
          if (i < _chartPoints.length) {
            _chartPoints[i] = response.lineBarSpots![i].y;
          }
        }
      }
    } else {
      setPoints();
    }

    // UI state update
    setState(() => ());
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

  // Define chart data
  List<LineChartBarData> get lineBarsData => [
        for (final Biorhythm b in di<AppModel>().biorhythms)
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
              di<AppModel>().birthday,
              today,
              addDays: day - chartRangeSplit,
            ),
          ),
        ),
      ),
    );
  }

  // Display a biorhythm point as a percentage with label
  Widget biorhythmPercentBox({
    required Biorhythm biorhythm,
    required double point,
  }) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _highlighted == biorhythm
              ? biorhythm.highlightColor
              : biorhythm.graphColor,
        ),
        child: Column(
          children: [
            // Name label
            Text(
              biorhythm.name,
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
                  Icon(
                    getPhaseIcon(point),
                    size: pointText.fontSize!,
                  ),
                  Text(
                    shortPercent(point),
                    style: pointText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Chart interactivity
      onTapDown: (_) => setState(() => _highlighted = biorhythm),
      onTapUp: (_) => setState(() => _highlighted = null),
      onTapCancel: () => setState(() => _highlighted = null),
    );
  }
}
