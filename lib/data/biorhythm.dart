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

typedef BiorhythmPoint =
    ({Biorhythm biorhythm, double point, BiorhythmTrend trend});

enum Biorhythm {
  intellectual(Colors.lightGreen, 33, true),
  emotional(Colors.pinkAccent, 28, true),
  physical(Colors.cyan, 23, true),
  intuition(Colors.purple, 38, false),
  aesthetic(Colors.indigoAccent, 43, false),
  awareness(Colors.deepOrange, 48, false),
  spiritual(Colors.blueGrey, 53, false);

  const Biorhythm(this.color, this.cycleDays, this.primary);

  final Color color;
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

  // Biorhythm colors
  Color get graphColor => color.withValues(alpha: 0.6);
  Color get highlightColor => color;

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
final List<Biorhythm> primaryBiorhythms =
    Biorhythm.values.where((b) => b.primary).toList();

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
