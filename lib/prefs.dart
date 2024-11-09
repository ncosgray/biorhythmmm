/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    prefs.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Shared preferences

import 'package:shared_preferences/shared_preferences.dart';

abstract class Prefs {
  static late SharedPreferences sharedPrefs;

  // Initialize shared preferences instance
  static init() async {
    sharedPrefs = await SharedPreferences.getInstance();
  }

  // Preference keys
  static String get birthdayKey => 'birthday';

  // Get and set birthday
  static DateTime get birthday =>
      DateTime.fromMillisecondsSinceEpoch(sharedPrefs.getInt(birthdayKey) ?? 0);
  static set birthday(DateTime d) =>
      sharedPrefs.setInt(birthdayKey, d.millisecondsSinceEpoch);
  static bool get isBirthdaySet => sharedPrefs.containsKey(birthdayKey);
}
