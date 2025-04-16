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
  // Use UTC to account for daylight savings
  tz.TZDateTime from = tz.TZDateTime(tz.local, f.year, f.month, f.day).toUtc();
  tz.TZDateTime to = tz.TZDateTime(
    tz.local,
    t.year,
    t.month,
    t.day,
  ).toUtc().add(Duration(days: addDays));

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
  return DateFormat.yMMMd().format(d);
}

// Round double to neareast int
int roundInt(double x) {
  return (x * 1000).round() ~/ 10;
}

// Format number as percentage
String shortPercent(double x) {
  int percent = roundInt(x);
  return '${percent < 0 ? '\u2212' : ''}${percent.abs()}%';
}
