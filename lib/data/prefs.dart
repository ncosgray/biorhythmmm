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

import 'dart:convert';

import 'package:biorhythmmm/common/notifications.dart' show NotificationType;
import 'package:biorhythmmm/common/strings.dart';
import 'package:biorhythmmm/data/biorhythm.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';

abstract class Prefs {
  static late SharedPreferencesWithCache _sharedPrefs;

  // Initialize shared preferences instance
  static Future<void> init() async {
    const SharedPreferencesOptions sharedPreferencesOptions =
        SharedPreferencesOptions();

    // Migrate legacy prefs
    final legacyPrefs = await SharedPreferences.getInstance();
    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: legacyPrefs,
      sharedPreferencesAsyncOptions: sharedPreferencesOptions,
      migrationCompletedKey: _migrationCompletedKey,
    );

    // Instantiate shared prefs with caching
    _sharedPrefs = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(),
      sharedPreferencesOptions: sharedPreferencesOptions,
    );
  }

  // Preference keys
  static String get _migrationCompletedKey => 'migrationCompleted';
  static String get _birthdayKey => 'birthday';
  static String get _birthdaysKey => 'birthdays';
  static String get _selectedBirthdayKey => 'selectedBirthday';
  static String get _biorhythmsKey => 'biorhythms';
  static String get _notificationsKey => 'notifications';
  static String get _useAccessibleColorsKey => 'useAccessibleColors';
  static String get _showCriticalZoneKey => 'showCriticalZone';

  // Determine if a birthday has been set
  static bool get isBirthdaySet =>
      _sharedPrefs.containsKey(_birthdaysKey) ||
      _sharedPrefs.containsKey(_birthdayKey);

  // Get and set selected birthday index
  static int get selectedBirthday =>
      _sharedPrefs.getInt(_selectedBirthdayKey) ?? 0;
  static set selectedBirthday(int i) =>
      _sharedPrefs.setInt(_selectedBirthdayKey, i);

  // Get selected birthday
  static DateTime get birthday => DateTime.fromMillisecondsSinceEpoch(
    _sharedPrefs.containsKey(_selectedBirthdayKey) &&
            _sharedPrefs.containsKey(_birthdaysKey)
        ? birthdays[selectedBirthday].date.millisecondsSinceEpoch
        // Fallback to legacy birthday
        : _sharedPrefs.getInt(_birthdayKey) ?? 0,
  );

  // Get and set birthdays list
  static List<BirthdayEntry> get birthdays {
    final list = _sharedPrefs.getStringList(_birthdaysKey);
    if (list == null || list.isEmpty) {
      // Fallback to legacy birthday
      return [BirthdayEntry(name: Str.birthdayDefaultName, date: birthday)];
    }
    return list.map((s) => BirthdayEntry.fromJson(jsonDecode(s))).toList();
  }

  static set birthdays(List<BirthdayEntry> l) => _sharedPrefs.setStringList(
    _birthdaysKey,
    l.map((b) => jsonEncode(b.toJson())).toList(),
  );

  // Get and set biorhythm list
  static List<Biorhythm> get biorhythms {
    List<String>? l = _sharedPrefs.getStringList(_biorhythmsKey);
    if (l == null) {
      return primaryBiorhythms;
    } else {
      return l
          .map((name) => Biorhythm.values.where((b) => b.name == name).first)
          .toList();
    }
  }

  static set biorhythms(List<Biorhythm> l) =>
      _sharedPrefs.setStringList(_biorhythmsKey, l.map((b) => b.name).toList());

  // Get and set notification choice
  static NotificationType get notifications =>
      NotificationType.values[_sharedPrefs.getInt(_notificationsKey) ?? 0];
  static set notifications(NotificationType n) =>
      _sharedPrefs.setInt(_notificationsKey, n.value);

  // Get and set accessible color palette choice
  static bool get useAccessibleColors =>
      _sharedPrefs.getBool(_useAccessibleColorsKey) ?? false;
  static set useAccessibleColors(bool u) =>
      _sharedPrefs.setBool(_useAccessibleColorsKey, u);

  // Get and set critical zone choice
  static bool get showCriticalZone =>
      _sharedPrefs.getBool(_showCriticalZoneKey) ?? true;
  static set showCriticalZone(bool s) =>
      _sharedPrefs.setBool(_showCriticalZoneKey, s);
}

class BirthdayEntry {
  factory BirthdayEntry.fromJson(Map<String, dynamic> json) => BirthdayEntry(
    name: json['name'],
    date: DateTime.fromMillisecondsSinceEpoch(json['date']),
  );

  BirthdayEntry({this.name = '', required this.date});
  final String name;
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date.millisecondsSinceEpoch,
  };
}
