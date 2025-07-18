/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    styles.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Text styles

import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const bodyText = TextStyle(fontSize: 14);

const bodyBoldText = TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

const footerText = TextStyle(fontSize: 12, color: Colors.grey);

const titleText = TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

const titleDateText = TextStyle(
  fontSize: 14,
  fontFeatures: [FontFeature.tabularFigures()],
);

const titleTodayText = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
  fontFeatures: [FontFeature.tabularFigures()],
);

const buttonText = TextStyle(fontSize: 14);

const labelText = TextStyle(fontSize: 16);

TextStyle listTileText(BuildContext context) =>
    (Platform.isIOS
            ? CupertinoTheme.of(context).textTheme.textStyle
            : Theme.of(context).textTheme.bodyMedium!)
        .copyWith(color: Theme.of(context).colorScheme.onSurface);

TextStyle listTitleText(BuildContext context) =>
    (Platform.isIOS
            ? CupertinoTheme.of(context).textTheme.navTitleTextStyle
            : Theme.of(context).textTheme.titleMedium!)
        .copyWith(color: Theme.of(context).colorScheme.onSurface);

const pointText = TextStyle(
  fontSize: 19,
  fontWeight: FontWeight.bold,
  fontFeatures: [FontFeature.tabularFigures()],
);
