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
// - Text and button styles

import 'package:flutter/material.dart';

const bodyText = TextStyle(
  fontSize: 14,
);

const bodyBoldText = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

const footerText = TextStyle(
  fontSize: 12,
  color: Colors.grey,
);

const titleText = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
);

const buttonText = TextStyle(
  fontSize: 14,
);

const labelText = TextStyle(
  fontSize: 16,
);

const pointText = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  fontFeatures: [
    FontFeature.tabularFigures(),
  ],
);

ButtonStyle buttonStyle = TextButton.styleFrom(
  splashFactory: NoSplash.splashFactory,
);
