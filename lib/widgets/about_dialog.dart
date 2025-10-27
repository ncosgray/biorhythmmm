/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    about_dialog.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - About text

import 'package:biorhythmmm/common/buttons.dart';
import 'package:biorhythmmm/common/styles.dart';
import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:biorhythmmm/data/localization.dart';

import 'package:flutter/material.dart';

// About Biorhythms dialog
Future<void> showAboutBiorhythms(BuildContext context) {
  return showAdaptiveDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (_, setDialogState) {
          return AlertDialog.adaptive(
            // About Biorhythms
            title: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(AppString.aboutTitle.translate()),
            ),
            content: SingleChildScrollView(
              child: aboutText(
                textColor: Theme.of(context).textTheme.bodyMedium!.color!,
              ),
            ),
            actions: [
              // Dismiss dialog button
              adaptiveDialogAction(
                text: AppString.okLabel.translate(),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    },
  );
}

// Rich text widget explaining biorhythms
Widget aboutText({required Color textColor}) {
  const String bulletSymbol = '\u2022';

  return RichText(
    text: TextSpan(
      style: bodyText.copyWith(color: textColor),
      children: [
        TextSpan(text: AppString.aboutCycles.translate()),
        lineBreak,
        TextSpan(
          text: '$bulletSymbol ${AppString.biorhythmIntellectual.translate()}',
          style: bodyBoldText,
        ),
        TextSpan(
          text: AppString.aboutIntellectualText.translate(
            days: Biorhythm.intellectual.cycleDays,
          ),
        ),
        lineBreak,
        TextSpan(
          text: '$bulletSymbol ${AppString.biorhythmEmotional.translate()}',
          style: bodyBoldText,
        ),
        TextSpan(
          text: AppString.aboutEmotionalText.translate(
            days: Biorhythm.emotional.cycleDays,
          ),
        ),
        lineBreak,
        TextSpan(
          text: '$bulletSymbol ${AppString.biorhythmPhysical.translate()}',
          style: bodyBoldText,
        ),
        TextSpan(
          text: AppString.aboutPhysicalText.translate(
            days: Biorhythm.physical.cycleDays,
          ),
        ),
        lineBreak,
        lineBreak,
        TextSpan(text: AppString.aboutAdditional.translate()),
        TextSpan(
          text: AppString.biorhythmIntuition.translate(),
          style: bodyBoldText,
        ),
        TextSpan(
          text: AppString.aboutIntutionDays.translate(
            days: Biorhythm.intuition.cycleDays,
          ),
        ),
        TextSpan(
          text: AppString.biorhythmAesthetic.translate(),
          style: bodyBoldText,
        ),
        TextSpan(
          text: AppString.aboutAestheticDays.translate(
            days: Biorhythm.aesthetic.cycleDays,
          ),
        ),
        TextSpan(
          text: AppString.biorhythmAwareness.translate(),
          style: bodyBoldText,
        ),
        TextSpan(
          text: AppString.aboutAwarenessDays.translate(
            days: Biorhythm.awareness.cycleDays,
          ),
        ),
        TextSpan(
          text: AppString.biorhythmSpiritual.translate(),
          style: bodyBoldText,
        ),
        TextSpan(
          text: AppString.aboutSpiritualDays.translate(
            days: Biorhythm.spiritual.cycleDays,
          ),
        ),
        lineBreak,
        lineBreak,
        TextSpan(text: AppString.aboutPhases.translate()),
        lineBreak,
        lineBreak,
        TextSpan(text: AppString.aboutApp.translate(), style: footerText),
        lineBreak,
        TextSpan(text: AppString.aboutCopyright.translate(), style: footerText),
      ],
    ),
  );
}

// Line break for RichText widget
TextSpan get lineBreak => TextSpan(text: '\n');
