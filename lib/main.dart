/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    main.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - App initialization

import 'package:biorhythmmm/common/notifications.dart';
import 'package:biorhythmmm/common/themes.dart';
import 'package:biorhythmmm/data/app_state.dart';
import 'package:biorhythmmm/data/localization.dart';
import 'package:biorhythmmm/data/prefs.dart';
import 'package:biorhythmmm/widgets/home_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/find_locale.dart';
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest_all.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

void main() {
  initApp().then((_) => runApp(const BiorhythmApp()));
}

// Initialize preferences, locale, time zone, and notifications
Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get shared preferences instance
  await Prefs.init();

  // Get default locale for DateFormat and NumberFormat
  await initializeDateFormatting();
  Intl.defaultLocale = await findSystemLocale();

  // Get time zone
  tz.initializeTimeZones();
  final TimezoneInfo timeZone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZone.identifier));
}

// Create the app
class BiorhythmApp extends StatelessWidget {
  const BiorhythmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppStateCubit>(
      create: (BuildContext context) => AppStateCubit(),
      child: MaterialApp(
        home: HomePage(),
        title: appName,
        theme: lightTheme,
        darkTheme: darkTheme,
        debugShowCheckedModeBanner: false,
        supportedLocales: supportedLocales,
        localizationsDelegates: [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          FallbackMaterialLocalizationsDelegate(),
          FallbackCupertinoLocalizationsDelegate(),
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          final Locale resolvedLocale = localeResolutionCallback(
            locale,
            supportedLocales,
          );

          // Set up notifications after locale is resolved
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => Notifications.init(),
          );

          return resolvedLocale;
        },
      ),
    );
  }
}
