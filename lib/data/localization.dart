/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    localization.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Populate strings from language files
// - Get translated strings
// - String keys

import 'dart:async';
import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String appName = 'Biorhythmmm';
const Locale defaultLocale = Locale.fromSubtags(languageCode: 'en');

// Supported locales
const List<Locale> supportedLocales = [
  Locale.fromSubtags(languageCode: 'en'),
  Locale.fromSubtags(languageCode: 'de'),
  Locale.fromSubtags(languageCode: 'es'),
  Locale.fromSubtags(languageCode: 'fr'),
  Locale.fromSubtags(languageCode: 'ja'),
  Locale.fromSubtags(languageCode: 'pt'),
  Locale.fromSubtags(languageCode: 'zh'),
];
final List<String> supportedLanguageCodes = supportedLocales
    .map<String>((Locale locale) => locale.languageCode)
    .toList();

// Languages not supported by GlobalMaterialLocalizations
final List<String> fallbackLanguageCodes = supportedLanguageCodes
    .where((item) => !kMaterialSupportedLanguages.contains(item))
    .toList();

// Localizable app strings
enum AppString {
  aboutAdditional('aboutAdditional'),
  aboutApp('aboutApp'),
  aboutBiorhythmDays('aboutBiorhythmDays'),
  aboutCompare('aboutCompare'),
  aboutCopyright('aboutCopyright'),
  aboutCycles('aboutCycles'),
  aboutEmotional('aboutEmotional'),
  aboutIntellectual('aboutIntellectual'),
  aboutPhases('aboutPhases'),
  aboutPhysical('aboutPhysical'),
  aboutTitle('aboutTitle'),
  biorhythmAesthetic('biorhythmAesthetic'),
  biorhythmAwareness('biorhythmAwareness'),
  biorhythmEmotional('biorhythmEmotional'),
  biorhythmIntellectual('biorhythmIntellectual'),
  biorhythmIntuition('biorhythmIntuition'),
  biorhythmPhysical('biorhythmPhysical'),
  biorhythmSpiritual('biorhythmSpiritual'),
  birthdayAddLabel('birthdayAddLabel'),
  birthdayDefaultName('birthdayDefaultName'),
  birthdayEditLabel('birthdayEditLabel'),
  birthdayManageLabel('birthdayManageLabel'),
  birthdayNameLabel('birthdayNameLabel'),
  cancelLabel('cancelLabel'),
  chartTitle('chartTitle'),
  compareClear('compareClear'),
  compareLabel('compareLabel'),
  compareManageLabel('compareManageLabel'),
  dateNoneLabel('dateNoneLabel'),
  dateSelectLabel('dateSelectLabel'),
  deleteLabel('deleteLabel'),
  doneLabel('doneLabel'),
  editLabel('editLabel'),
  manageLabel('manageLabel'),
  notificationsLabel('notificationsLabel'),
  notificationTimeLabel('notificationTimeLabel'),
  notificationTypeCritical('notificationTypeCritical'),
  notificationTypeDaily('notificationTypeDaily'),
  notificationTypeNone('notificationTypeNone'),
  notifyChannelName('notifyChannelName'),
  notifyCriticalPrefix('notifyCriticalPrefix'),
  notifyTitleName('notifyTitleName'),
  notifyTitleToday('notifyTitleToday'),
  okLabel('okLabel'),
  otherSettingsTitle('otherSettingsTitle'),
  resetLabel('resetLabel'),
  selectBiorhythmsTitle('selectBiorhythmsTitle'),
  setNotificationsLabel('setNotificationsLabel'),
  settingsTitle('settingsTitle'),
  showCriticalZoneLabel('showCriticalZoneLabel'),
  todayLabel('todayLabel'),
  toggleExtraLabel('toggleExtraLabel'),
  useAccessibleColorsLabel('useAccessibleColorsLabel');

  const AppString(this.key);

  final String key;

  // Lookup localized string and apply substitutions
  String translate({String name = '', String biorhythm = '', int days = 0}) {
    return AppLocalizations.translate(key)
        .replaceAll('{{app_name}}', appName)
        .replaceAll('{{name}}', name)
        .replaceAll('{{biorhythm}}', biorhythm)
        .replaceAll('{{days}}', days.toString());
  }
}

// Given a locale, return its flat string name in the expected format
String localeString(Locale locale) {
  String name = locale.languageCode;
  if (locale.scriptCode != null) name += '_${locale.scriptCode!}';
  if (locale.countryCode != null) name += '_${locale.countryCode!}';
  return name;
}

// Given a flat string, parse into a locale
Locale parseLocaleString(String name) {
  List<String> nameParts = name.split('_');
  String? scriptCode;
  String? countryCode;
  if (nameParts.length > 1) {
    if (nameParts[1].length == 2 &&
        nameParts[1] == nameParts[1].toUpperCase()) {
      countryCode = nameParts[1];
    } else {
      scriptCode = nameParts[1];
    }
  }
  return Locale.fromSubtags(
    languageCode: nameParts[0],
    scriptCode: scriptCode,
    countryCode: countryCode,
  );
}

// Resolve app locale from the device locale
Locale localeResolutionCallback(
  Locale? deviceLocale,
  Iterable<Locale> appLocales,
) {
  if (deviceLocale != null) {
    // Set locale if supported
    if (appLocales.contains(deviceLocale)) {
      return deviceLocale;
    }
    if (deviceLocale.scriptCode != null) {
      for (final appLocale in appLocales) {
        if (appLocale.languageCode == deviceLocale.languageCode &&
            appLocale.scriptCode == deviceLocale.scriptCode) {
          return appLocale;
        }
      }
    }
    if (deviceLocale.countryCode != null) {
      for (final appLocale in appLocales) {
        if (appLocale.languageCode == deviceLocale.languageCode &&
            appLocale.countryCode == deviceLocale.countryCode) {
          return appLocale;
        }
      }
    }
    for (final appLocale in appLocales) {
      if (appLocale.languageCode == deviceLocale.languageCode) {
        return appLocale;
      }
    }
  }

  // Default if locale not supported
  return defaultLocale;
}

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  // Localizations instance
  static AppLocalizations get instance => AppLocalizationsDelegate.instance!;

  Map<String, String> _localizedStrings = {};
  Map<String, String> _defaultStrings = {};

  // Populate strings
  Future<bool> load() async {
    // Populate strings map from JSON file in langs folder
    String jsonString = await rootBundle.loadString(
      'langs/${localeString(locale)}.json',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    // Populate default (English) strings map
    String jsonDefaultString = await rootBundle.loadString(
      'langs/${localeString(defaultLocale)}.json',
    );
    Map<String, dynamic> jsonDefaultMap = json.decode(jsonDefaultString);
    _defaultStrings = jsonDefaultMap.map(
      (key, value) => MapEntry(key, value.toString()),
    );

    return true;
  }

  // Get translated string (or use default string if unavailable)
  static String translate(String key) {
    return instance._localizedStrings[key] ?? instance._defaultStrings[key]!;
  }

  // Locale info
  String get appLocaleString => localeString(instance.locale);
  bool get isFallbackLanguage =>
      fallbackLanguageCodes.contains(instance.locale.languageCode);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  static AppLocalizations? instance;

  // Determine if a language is supported
  @override
  bool isSupported(Locale locale) =>
      supportedLanguageCodes.contains(locale.languageCode);

  // Load localizations
  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    instance = localizations;
    return localizations;
  }

  @override
  bool shouldReload(old) => false;
}

class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  // Force defaults for locales not supported by GlobalMaterialLocalizations
  @override
  bool isSupported(Locale locale) =>
      fallbackLanguageCodes.contains(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      const DefaultMaterialLocalizations();

  @override
  bool shouldReload(old) => false;
}

class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  // Force defaults for locales not supported by CupertinoLocalizations
  @override
  bool isSupported(Locale locale) =>
      fallbackLanguageCodes.contains(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) async =>
      const DefaultCupertinoLocalizations();

  @override
  bool shouldReload(old) => false;
}
