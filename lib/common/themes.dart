/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    themes.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - App theme data

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Light theme
ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.orange.shade300,
    brightness: Brightness.light,
  ),
  appBarTheme: appBarTheme,
  dividerColor: Colors.black26,
  splashFactory: splashFactory,
  cupertinoOverrideTheme: cupertinoOverrideTheme,
);

// Dark theme
ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.orange,
    brightness: Brightness.dark,
  ),
  appBarTheme: appBarTheme,
  dividerColor: Colors.white12,
  splashFactory: splashFactory,
  cupertinoOverrideTheme: cupertinoOverrideTheme,
);

// Common theme elements
AppBarTheme get appBarTheme => AppBarTheme(
      surfaceTintColor: Platform.isIOS ? Colors.transparent : null,
      shadowColor: Platform.isIOS ? CupertinoColors.darkBackgroundGray : null,
      scrolledUnderElevation: Platform.isIOS ? .1 : null,
      toolbarHeight: Platform.isIOS ? 44 : null,
    );

InteractiveInkFeatureFactory? get splashFactory =>
    Platform.isIOS ? NoSplash.splashFactory : null;

CupertinoThemeData get cupertinoOverrideTheme =>
    const CupertinoThemeData(primaryColor: CupertinoColors.systemBlue);
