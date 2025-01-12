/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    home_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - App home page

import 'package:biorhythmmm/app_model.dart';
import 'package:biorhythmmm/helpers.dart';
import 'package:biorhythmmm/strings.dart';
import 'package:biorhythmmm/styles.dart';
import 'package:biorhythmmm/widgets/about_text.dart';
import 'package:biorhythmmm/widgets/biorhythm_chart.dart';

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        // Prompt user once if birthday is unset
        if (context.mounted && !di<AppModel>().isBirthdaySet) {
          di<AppModel>().birthday = di<AppModel>().birthday;
          adaptiveBirthdayPicker(context);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(Str.appName),
        // About button
        leading: IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () => showAboutDialog(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Reset button
                TextButton.icon(
                  onPressed: () => di<AppModel>().resetChart = true,
                  label: Text(
                    Str.todayLabel,
                    style: labelText,
                  ),
                  icon: Icon(Icons.calendar_today, size: labelText.fontSize),
                  iconAlignment: IconAlignment.start,
                ),
                // Birthday setting
                BirthdayButton(
                  onPressed: () => adaptiveBirthdayPicker(context),
                ),
              ],
            ),
            // Chart
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: BiorhythmChart(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Open a dialog box to choose user birthday
  adaptiveBirthdayPicker(BuildContext context) async {
    if (Platform.isIOS) {
      return buildCupertinoDatePicker(context);
    } else {
      return buildMaterialDatePicker(context);
    }
  }

  // Android date picker
  buildMaterialDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: Str.birthdaySelectText,
      initialDate: di<AppModel>().birthday,
      firstDate: DateTime(0),
      lastDate: DateTime(DateTime.now().year),
    );
    if (picked != null) {
      di<AppModel>().birthday = picked;
    }
  }

  // Cupertino date picker
  buildCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: Stack(
            children: [
              // Help text overlay
              Padding(
                padding: EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    Str.birthdaySelectText,
                    style: titleText,
                  ),
                ),
              ),
              // Date picker
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (picked) =>
                      di<AppModel>().birthday = picked,
                  initialDateTime: di<AppModel>().birthday,
                  maximumYear: DateTime.now().year,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // About Biorhythms dialog
  Future<void> showAboutDialog(BuildContext context) {
    return showAdaptiveDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog.adaptive(
              // About Biorthythms
              title: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(Str.aboutTitle),
              ),
              content: SingleChildScrollView(
                child: aboutText(
                  textColor: Theme.of(context).textTheme.bodyMedium!.color!,
                ),
              ),
              actions: [
                // Dismiss dialog button
                adaptiveDialogAction(
                  text: Str.okLabel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Dialog action button appropriate to platform
  Widget adaptiveDialogAction({
    bool isDefaultAction = false,
    bool isDestructiveAction = false,
    required String text,
    required Function()? onPressed,
  }) {
    if (Platform.isIOS) {
      return CupertinoDialogAction(
        isDefaultAction: isDefaultAction,
        isDestructiveAction: isDestructiveAction,
        onPressed: onPressed,
        child: Text(text),
      );
    } else {
      return isDestructiveAction
          ? TextButton(
              onPressed: onPressed,
              child: Text(text),
            )
          : FilledButton.tonal(
              onPressed: onPressed,
              child: Text(text),
            );
    }
  }
}

// Birthday setting text button
class BirthdayButton extends WatchingWidget {
  const BirthdayButton({
    super.key,
    this.onPressed,
  });

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final birthday = watchPropertyValue((AppModel m) => m.birthday);

    return TextButton.icon(
      onPressed: onPressed,
      label: Text(
        '${Str.birthdayLabel} ${longDate(birthday)}',
        style: labelText,
      ),
      icon: Icon(Icons.edit, size: labelText.fontSize),
      iconAlignment: IconAlignment.end,
    );
  }
}
