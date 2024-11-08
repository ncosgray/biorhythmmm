/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    helpers.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Helper functions for string formatting

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Get inclusive date difference in days
int dateDiff(DateTime from, int addDays) {
  DateTime to =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .add(Duration(days: addDays));
  return to.difference(from).inDays + 1;
}

// Format date as short date
String shortDate(DateTime d) {
  return DateFormat.Md().format(d);
}

// Format date as long date
String longDate(DateTime d) {
  return DateFormat.yMd().format(d);
}

// Round double to neareast int
int roundInt(double x) {
  return (x * 1000).round() ~/ 10;
}

// Format number as absolute percent
String shortPercent(double x) {
  return '${roundInt(x).abs()}%';
}

// Get phase icon for a value (up, down, or critical)
IconData getPhaseIcon(double x) {
  int i = roundInt(x);
  if (i == 0) {
    return Icons.warning;
  } else if (i > 0) {
    return Icons.arrow_upward;
  } else {
    return Icons.arrow_downward;
  }
}
