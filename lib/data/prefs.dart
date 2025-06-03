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

import 'package:biorhythmmm/common/notifications.dart' show NotificationType;
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
  static String get _biorhythmsKey => 'biorhythms';
  static String get _notificationsKey => 'notifications';
  static String get _useAccessibleColorsKey => 'useAccessibleColors';
  static String get _showCriticalZoneKey => 'showCriticalZone';

  // Get and set birthday
  static DateTime get birthday => DateTime.fromMillisecondsSinceEpoch(
    _sharedPrefs.getInt(_birthdayKey) ?? 0,
  );
  static set birthday(DateTime d) =>
      _sharedPrefs.setInt(_birthdayKey, d.millisecondsSinceEpoch);
  static bool get isBirthdaySet => _sharedPrefs.containsKey(_birthdayKey);

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
