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

import 'package:biorhythmmm/data/app_state.dart';
import 'package:biorhythmmm/data/prefs.dart';
import 'package:biorhythmmm/common/strings.dart';
import 'package:biorhythmmm/common/themes.dart';
import 'package:biorhythmmm/widgets/home_page.dart';

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
        theme: lightTheme,
        darkTheme: darkTheme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
