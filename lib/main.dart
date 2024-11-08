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

import 'package:biorhythmmm/home_page.dart';
import 'package:biorhythmmm/strings.dart';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/find_locale.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Shared preferences
late SharedPreferences sharedPrefs;
const String birthdayKey = 'birthday';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get shared preferences instance
  sharedPrefs = await SharedPreferences.getInstance();

  // Get default locale for DateFormat and NumberFormat
  await initializeDateFormatting();
  Intl.defaultLocale = await findSystemLocale();

  runApp(const BiorhythmApp());
}

// Create the app
class BiorhythmApp extends StatelessWidget {
  const BiorhythmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Str.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange.shade300,
          brightness: Brightness.light,
        ),
        dividerColor: Colors.black26,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
        dividerColor: Colors.white12,
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
