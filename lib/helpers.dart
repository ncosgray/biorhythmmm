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

// Today's date with no time component
DateTime get today => DateUtils.dateOnly(DateTime.now());

// Get inclusive date difference in days
int dateDiff(DateTime from, DateTime to, {int addDays = 0}) {
  return 1 +
      DateUtils.dateOnly(to)
          .add(Duration(days: addDays))
          .difference(from)
          .inDays;
}

// Format date as short date
String shortDate(DateTime d) {
  return DateFormat.Md().format(d);
}

// Format date as short date with day of week
String dateAndDay(DateTime d) {
  return DateFormat.E().add_Md().format(d);
}

// Format date as long date
String longDate(DateTime d) {
  return DateFormat('M/d/yy').format(d);
}

// Round double to neareast int
int roundInt(double x) {
  return (x * 1000).round() ~/ 10;
}

// Format number as percentage
String shortPercent(double x) {
  return '${roundInt(x)}%';
}

// Get phase icon for a value (up, down, or critical)
IconData getPhaseIcon(double x) {
  int i = roundInt(x);
  if (i > -15 && i < 15) {
    return Icons.warning;
  } else if (i > 0) {
    return Icons.arrow_upward;
  } else {
    return Icons.arrow_downward;
  }
}
