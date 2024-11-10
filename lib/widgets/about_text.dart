/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    about_text.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - About text

import 'package:biorhythmmm/strings.dart';
import 'package:biorhythmmm/styles.dart';

import 'package:flutter/material.dart';

// Rich text widget explaining biorhythms
Widget aboutText({required Color textColor}) {
  return RichText(
    text: TextSpan(
      style: bodyText.copyWith(color: textColor),
      children: [
        TextSpan(text: Str.aboutCycles),
        lineBreak,
        TextSpan(
          text: Str.aboutIntellectualBullet,
          style: bodyBoldText,
        ),
        TextSpan(text: Str.aboutIntellectualText),
        lineBreak,
        TextSpan(
          text: Str.aboutEmotionalBullet,
          style: bodyBoldText,
        ),
        TextSpan(text: Str.aboutEmotionalText),
        lineBreak,
        TextSpan(
          text: Str.aboutPhysicalBullet,
          style: bodyBoldText,
        ),
        TextSpan(text: Str.aboutPhysicalText),
        lineBreak,
        lineBreak,
        TextSpan(text: Str.aboutAdditional),
        TextSpan(
          text: Str.biorhythmIntuition,
          style: bodyBoldText,
        ),
        TextSpan(text: Str.aboutIntutionDays),
        TextSpan(
          text: Str.biorhythmAesthetic,
          style: bodyBoldText,
        ),
        TextSpan(text: Str.aboutAestheticDays),
        TextSpan(
          text: Str.biorhythmAwareness,
          style: bodyBoldText,
        ),
        TextSpan(text: Str.aboutAwarenessDays),
        TextSpan(
          text: Str.biorhythmSpiritual,
          style: bodyBoldText,
        ),
        TextSpan(text: Str.aboutSpiritualDays),
        lineBreak,
        lineBreak,
        TextSpan(text: Str.aboutPhases),
        lineBreak,
        lineBreak,
        TextSpan(
          text: Str.aboutApp,
          style: footerText,
        ),
        lineBreak,
        TextSpan(
          text: Str.aboutCopyright,
          style: footerText,
        ),
      ],
    ),
  );
}

// Line break for RichText widget
TextSpan get lineBreak => TextSpan(text: '\n');
