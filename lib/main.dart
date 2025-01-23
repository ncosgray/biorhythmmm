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
// - App initialization and themes

import 'package:biorhythmmm/app_state.dart';
import 'package:biorhythmmm/prefs.dart';
import 'package:biorhythmmm/strings.dart';
import 'package:biorhythmmm/widgets/home_page.dart';

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/find_locale.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get shared preferences instance
  await Prefs.init();

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
    return BlocProvider<AppStateCubit>(
      create: (BuildContext context) => AppStateCubit(),
      child: MaterialApp(
        home: HomePage(),
        title: Str.appName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange.shade300,
            brightness: Brightness.light,
          ),
          dividerColor: Colors.black26,
          splashFactory: splashFactory,
          cupertinoOverrideTheme: cupertinoOverrideTheme,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orange,
            brightness: Brightness.dark,
          ),
          dividerColor: Colors.white12,
          splashFactory: splashFactory,
          cupertinoOverrideTheme: cupertinoOverrideTheme,
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  // Common theme elements
  InteractiveInkFeatureFactory? get splashFactory =>
      Platform.isIOS ? NoSplash.splashFactory : null;

  CupertinoThemeData get cupertinoOverrideTheme =>
      const CupertinoThemeData(primaryColor: CupertinoColors.systemBlue);
}
