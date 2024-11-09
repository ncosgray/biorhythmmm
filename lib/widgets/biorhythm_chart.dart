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
// - Chart interactivity

import 'package:biorhythmmm/biorhythm.dart';
import 'package:biorhythmmm/helpers.dart';
import 'package:biorhythmmm/prefs.dart';
import 'package:biorhythmmm/text_styles.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Chart ranges
final int dayRange = 29;
final int dayRangeSplit = (dayRange / 2).floor();

// Interactive biorhythm chart
class BiorhythmChart extends StatefulWidget {
  const BiorhythmChart({super.key, required this.birthday});

  final DateTime birthday;

  @override
  State<StatefulWidget> createState() => BiorhythmChartState();
}

class BiorhythmChartState extends State<BiorhythmChart> {
  // State variables
  late List<double> _chartPoints;
  Biorhythm? _highlighted;
  bool _showExtraPoints = Prefs.showExtraPoints;

  // Biorhythm list: all available or only primary points
  List<Biorhythm> get biorhythms => _showExtraPoints
      ? Biorhythm.values.toList()
      : Biorhythm.values.where((b) => b.primary).toList();

  // Reset biorhythm points to today
  void resetPoints() {
    _chartPoints = List.generate(
      biorhythms.length,
      (i) => biorhythms[i].getPoint(dateDiff(widget.birthday, 0)),
    );
    _highlighted = null;
  }

  // Toggle extra points setting
  void toggleExtraPoints() {
    setState(() {
      _showExtraPoints = !_showExtraPoints;
      Prefs.showExtraPoints = _showExtraPoints;
      resetPoints();
    });
  }

  @override
  void initState() {
    resetPoints();
    super.initState();
  }

  @override
  void didUpdateWidget(BiorhythmChart oldWidget) {
    resetPoints();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // Biorhythm chart
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AspectRatio(
            aspectRatio: 1,
            child: LineChart(
              biorhythmData,
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Biorhythm percentages
                for (int i = 0; i < _chartPoints.length; i++)
                  biorhythmPercentBox(
                    biorhythm: biorhythms[i],
                    point: _chartPoints[i],
                  ),
                // Toggle extra biorhythms
                IconButton(
                  onPressed: toggleExtraPoints,
                  icon: Icon(Icons.expand_more),
                  isSelected: _showExtraPoints,
                  selectedIcon: Icon(Icons.expand_less),
                  style: TextButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                  ),
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
        minX: -dayRangeSplit.toDouble(),
        maxX: dayRangeSplit.toDouble(),
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
                  DateTime.now().add(Duration(days: touchedSpots[0].x.toInt())),
                ),
                titleStyle,
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
      resetPoints();
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
            color: Theme.of(context).dividerColor,
            strokeWidth: 1,
          )
        : FlLine(
            color: Theme.of(context).dividerColor,
            strokeWidth: 1,
            dashArray: [2, 2],
          );
  }

  FlLine getDrawingVerticalLine(double value) {
    return value == 0
        ? FlLine(color: Theme.of(context).dividerColor, strokeWidth: 2)
        : FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1);
  }

  // Chart titles
  FlTitlesData get titlesData => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: noTitles,
        topTitles: noTitles,
        leftTitles: noTitles,
      );

  AxisTitles get noTitles => const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      );

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: titleStyle.fontSize! * 2.25,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    Widget title = Container();

    if (value.toInt().abs() == dayRangeSplit) {
      title = Text(
        shortDate(DateTime.now().add(Duration(days: value.toInt()))),
        style: titleStyle,
      );
    } else if (value.toInt() == 0) {
      title = Text(
        'Today',
        style: titleStyle,
      );
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
      child: title,
    );
  }

  // Chart borders
  BorderSide get borderSideData =>
      BorderSide(color: Theme.of(context).dividerColor, width: 2);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: borderSideData,
          left: borderSideData,
          right: borderSideData,
          top: borderSideData,
        ),
      );

  // Define chart data
  List<LineChartBarData> get lineBarsData => [
        for (final Biorhythm b in biorhythms)
          biorhythmLineData(
            color: _highlighted == b ? b.highlightColor : b.graphColor,
            pointCount: dayRange,
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
          (day - dayRangeSplit).toDouble(),
          pointGenerator(dateDiff(widget.birthday, day - dayRangeSplit)),
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
              style: labelStyle,
            ),
            // Point percentage with phase icon
            SizedBox.fromSize(
              size: Size(
                pointStyle.fontSize! * 4.8,
                pointStyle.fontSize! * 1.8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(getPhaseIcon(point)),
                  Text(shortPercent(point), style: pointStyle),
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
