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
  List<double> _biorhythmPoints = List.filled(Biorhythm.values.length, 0);
  Biorhythm? _highlighted;

  // Reset biorhythm points to today
  void resetPoints() {
    _biorhythmPoints = List.generate(
      Biorhythm.values.length,
      (i) => Biorhythm.values[i].getPoint(dateDiff(widget.birthday, 0)),
    );
    _highlighted = null;
  }

  @override
  void initState() {
    resetPoints();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Biorhythm chart
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LineChart(
                biorhythmData,
                duration: const Duration(milliseconds: 250),
              ),
            ),
          ),
          // Biorhythm percentages
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < Biorhythm.values.length; i++)
                  Expanded(
                    child: biorhythmPercentBox(
                      biorhythm: Biorhythm.values[i],
                      point: _biorhythmPoints[i],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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
          if (i < _biorhythmPoints.length) {
            _biorhythmPoints[i] = response.lineBarSpots![i].y;
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
        reservedSize: 28,
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
        for (final Biorhythm b in Biorhythm.values)
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
            Text(
              biorhythm.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: labelStyle,
            ),
            Text(directionalPercent(point), style: pointStyle),
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
