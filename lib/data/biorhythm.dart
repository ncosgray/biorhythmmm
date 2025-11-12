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

import 'package:biorhythmmm/data/localization.dart';

import 'dart:math';
import 'package:flutter/material.dart';

typedef BiorhythmPoint = ({
  Biorhythm biorhythm,
  double point,
  BiorhythmTrend trend,
});

enum Biorhythm {
  intellectual('Intellectual', Colors.lightGreen, Color(0xFF00A896), 33, true),
  emotional('Emotional', Colors.pinkAccent, Color(0xFFE63946), 28, true),
  physical('Physical', Colors.cyan, Color(0xFF2A9DF4), 23, true),
  intuition('Intuition', Colors.purple, Color(0xFFD62AD0), 38, false),
  aesthetic('Aesthetic', Colors.indigoAccent, Color(0xFF06D6A0), 43, false),
  awareness('Awareness', Colors.orangeAccent, Color(0xFFFFB703), 48, false),
  spiritual('Spiritual', Colors.blueGrey, Color(0xFF996600), 53, false);

  const Biorhythm(
    this.name,
    this.color,
    this.accessibleColor,
    this.cycleDays,
    this.primary,
  );

  final String name;
  final Color color;
  final Color accessibleColor;
  final int cycleDays;
  final bool primary;

  // Biorhythm names
  String get localizedName => switch (this) {
    intellectual => AppString.biorhythmIntellectual.translate(),
    emotional => AppString.biorhythmEmotional.translate(),
    physical => AppString.biorhythmPhysical.translate(),
    intuition => AppString.biorhythmIntuition.translate(),
    aesthetic => AppString.biorhythmAesthetic.translate(),
    awareness => AppString.biorhythmAwareness.translate(),
    spiritual => AppString.biorhythmSpiritual.translate(),
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
const double criticalThreshold = 0.15;
bool isCritical(double x) {
  return (x > -criticalThreshold && x < criticalThreshold);
}
