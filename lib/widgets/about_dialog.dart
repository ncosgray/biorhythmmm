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
  return RichText(
    text: TextSpan(
      style: bodyText.copyWith(color: textColor),
      children: [
        TextSpan(text: AppString.aboutCycles.translate()),
        lineBreak,
        buildTextWithBold(
          text: AppString.aboutIntellectual.translate(
            biorhythm: AppString.biorhythmIntellectual.translate(),
            days: Biorhythm.intellectual.cycleDays,
          ),
          textToBold: AppString.biorhythmIntellectual.translate(),
        ),
        lineBreak,
        buildTextWithBold(
          text: AppString.aboutEmotional.translate(
            biorhythm: AppString.biorhythmEmotional.translate(),
            days: Biorhythm.emotional.cycleDays,
          ),
          textToBold: AppString.biorhythmEmotional.translate(),
        ),
        lineBreak,
        buildTextWithBold(
          text: AppString.aboutPhysical.translate(
            biorhythm: AppString.biorhythmPhysical.translate(),
            days: Biorhythm.physical.cycleDays,
          ),
          textToBold: AppString.biorhythmPhysical.translate(),
        ),
        lineBreak,
        lineBreak,
        TextSpan(text: AppString.aboutAdditional.translate()),
        lineBreak,
        buildTextWithBold(
          text: AppString.aboutBiorhythmDays.translate(
            biorhythm: AppString.biorhythmIntuition.translate(),
            days: Biorhythm.intuition.cycleDays,
          ),
          textToBold: AppString.biorhythmIntuition.translate(),
        ),
        lineBreak,
        buildTextWithBold(
          text: AppString.aboutBiorhythmDays.translate(
            biorhythm: AppString.biorhythmAesthetic.translate(),
            days: Biorhythm.aesthetic.cycleDays,
          ),
          textToBold: AppString.biorhythmAesthetic.translate(),
        ),
        lineBreak,
        buildTextWithBold(
          text: AppString.aboutBiorhythmDays.translate(
            biorhythm: AppString.biorhythmAwareness.translate(),
            days: Biorhythm.awareness.cycleDays,
          ),
          textToBold: AppString.biorhythmAwareness.translate(),
        ),
        lineBreak,
        buildTextWithBold(
          text: AppString.aboutBiorhythmDays.translate(
            biorhythm: AppString.biorhythmSpiritual.translate(),
            days: Biorhythm.spiritual.cycleDays,
          ),
          textToBold: AppString.biorhythmSpiritual.translate(),
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

// Helper function to create a TextSpan widget with a bolded portion
TextSpan buildTextWithBold({required String text, required String textToBold}) {
  final parts = text.split(textToBold);

  return TextSpan(
    children: [
      for (int i = 0; i < parts.length; i++) ...[
        TextSpan(text: parts[i]),
        if (i < parts.length - 1)
          TextSpan(
            text: textToBold,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
      ],
    ],
  );
}
