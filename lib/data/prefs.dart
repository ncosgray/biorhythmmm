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

import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Prefs {
  static late SharedPreferences sharedPrefs;

  // Initialize shared preferences instance
  static init() async {
    sharedPrefs = await SharedPreferences.getInstance();
  }

  // Preference keys
  static String get birthdayKey => 'birthday';
  static String get biorhythmsKey => 'biorhythms';

  // Get and set birthday
  static DateTime get birthday =>
      DateTime.fromMillisecondsSinceEpoch(sharedPrefs.getInt(birthdayKey) ?? 0);
  static set birthday(DateTime d) =>
      sharedPrefs.setInt(birthdayKey, d.millisecondsSinceEpoch);
  static bool get isBirthdaySet => sharedPrefs.containsKey(birthdayKey);

  // Get and set biorhythm list
  static List<Biorhythm> get biorhythms {
    List<String>? l = sharedPrefs.getStringList(biorhythmsKey);
    if (l == null) {
      return primaryBiorhythms;
    } else {
      return l
          .map((name) => Biorhythm.values.where((b) => b.name == name).first)
          .toList();
    }
  }

  static set biorhythms(List<Biorhythm> l) =>
      sharedPrefs.setStringList(biorhythmsKey, l.map((b) => b.name).toList());
}
