/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    biorhythm.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Biorhythm definitions

import 'package:biorhythmmm/common/helpers.dart';
import 'package:biorhythmmm/common/strings.dart';

import 'dart:math';
import 'package:flutter/material.dart';

typedef BiorhythmPoint = ({
  Biorhythm biorhythm,
  double point,
  BiorhythmTrend trend,
});

enum Biorhythm {
  intellectual(Colors.lightGreen, Color(0xFF00A896), 33, true),
  emotional(Colors.pinkAccent, Color(0xFFE63946), 28, true),
  physical(Colors.cyan, Color(0xFF2A9DF4), 23, true),
  intuition(Colors.purple, Color(0xFFD62AD0), 38, false),
  aesthetic(Colors.indigoAccent, Color(0xFF06D6A0), 43, false),
  awareness(Colors.orangeAccent, Color(0xFFFFB703), 48, false),
  spiritual(Colors.blueGrey, Color(0xFF996600), 53, false);

  const Biorhythm(
    this.color,
    this.accessibleColor,
    this.cycleDays,
    this.primary,
  );

  final Color color;
  final Color accessibleColor;
  final int cycleDays;
  final bool primary;

  // Biorhythm names
  String get name => switch (this) {
    intellectual => Str.biorhythmIntellectual,
    emotional => Str.biorhythmEmotional,
    physical => Str.biorhythmPhysical,
    intuition => Str.biorhythmIntuition,
    aesthetic => Str.biorhythmAesthetic,
    awareness => Str.biorhythmAwareness,
    spiritual => Str.biorhythmSpiritual,
  };

  // Biorhythm chart color
  Color getChartColor({
    bool isHighlighted = false,
    bool useAccessibleColors = false,
  }) => isHighlighted
      ? useAccessibleColors
            ? accessibleColor
            : color
      : useAccessibleColors
      ? accessibleColor.withValues(alpha: 0.6)
      : color.withValues(alpha: 0.6);

  // Calcuate biorhythm point for a given day
  double getPoint(int day) => sin(2 * pi * day / cycleDays);

  BiorhythmPoint getBiorhythmPoint(int day) => (
    biorhythm: this,
    point: getPoint(day),
    trend: getTrend(getPoint(day), getPoint(day + 1)),
  );
}

// Define default biorhythm list options
final List<Biorhythm> allBiorhythms = Biorhythm.values.toList();
final List<Biorhythm> primaryBiorhythms = Biorhythm.values
    .where((b) => b.primary)
    .toList();

// Biorhythm trend
enum BiorhythmTrend {
  decreasing(0),
  critical(1),
  increasing(2);

  const BiorhythmTrend(this.value);

  final int value;

  // Display icons
  IconData get trendIcon => switch (this) {
    decreasing => Icons.trending_down,
    critical => Icons.warning,
    increasing => Icons.trending_up,
  };
}

// Calculate trend (increasing, critical, or decreasing)
BiorhythmTrend getTrend(double a, double b) {
  if (isCritical(a)) {
    return BiorhythmTrend.critical;
  } else if ((b - a) > 0) {
    return BiorhythmTrend.increasing;
  } else {
    return BiorhythmTrend.decreasing;
  }
}

// Determine if a biorhythm value is in critical range
const double criticalThreshold = 15;
bool isCritical(double x) {
  int i = roundInt(x);
  return (i > -criticalThreshold && i < criticalThreshold);
}
