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
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

// Today's date with no time component
DateTime get today {
  tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  return tz.TZDateTime(tz.local, now.year, now.month, now.day);
}

// Get inclusive date difference in days
int dateDiff(DateTime f, DateTime t, {int addDays = 0}) {
  t = t.add(Duration(days: addDays));

  // Use UTC to account for daylight savings
  tz.TZDateTime from = tz.TZDateTime(tz.UTC, f.year, f.month, f.day);
  tz.TZDateTime to = tz.TZDateTime(tz.UTC, t.year, t.month, t.day);

  return 1 + to.difference(from).inDays;
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
