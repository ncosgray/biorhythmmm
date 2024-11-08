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

import 'package:biorhythmmm/strings.dart';

import 'dart:math';
import 'package:flutter/material.dart';

enum Biorhythm {
  intellectual(Colors.green, 33),
  emotional(Colors.pink, 28),
  physical(Colors.cyan, 23);

  const Biorhythm(this.color, this.cycleDays);

  final Color color;
  final int cycleDays;

  // Biorhythm names
  String get name => switch (this) {
        intellectual => Str.biorhythmIntellectual,
        emotional => Str.biorhythmEmotional,
        physical => Str.biorhythmPhysical,
      };

  // Biorhythm colors
  Color get graphColor => color.withOpacity(0.5);
  Color get highlightColor => color;

  // Calcuate biorhythm point for a given day
  double getPoint(int day) => sin(2 * pi * day / cycleDays);
}
