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

// Format number as percent with directional indicator
String directionalPercent(double x) {
  x = (x * 1000).round() / 10; // Round to neareast percent
  return x == 0
      ? '\u27350%'
      : '${x > 0 ? '\u2191' : '\u2193'}${x.toInt().abs()}%';
}
