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

import 'package:biorhythmmm/helpers.dart';
import 'package:biorhythmmm/prefs.dart';
import 'package:biorhythmmm/strings.dart';
import 'package:biorhythmmm/styles.dart';
import 'package:biorhythmmm/widgets/about_text.dart';
import 'package:biorhythmmm/widgets/biorhythm_chart.dart';

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State variables
  DateTime _birthday = Prefs.birthday;

  @override
  void initState() {
    // Prompt user once if birthday is unset
    Future.delayed(
      Duration.zero,
      () {
        if (mounted && !Prefs.isBirthdaySet) {
          saveBirthday(_birthday);
          adaptiveBirthdayPicker(context);
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(Str.appName),
        // About button
        leading: IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: showAboutDialog,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Birthday setting
            Padding(
              padding: const EdgeInsets.all(4),
              child: TextButton.icon(
                onPressed: () => adaptiveBirthdayPicker(context),
                label: Text(
                  '${Str.birthdayLabel} ${longDate(_birthday)}',
                  style: labelText,
                ),
                icon: Icon(Icons.edit, size: labelText.fontSize),
                iconAlignment: IconAlignment.end,
              ),
            ),
            // Chart
            BiorhythmChart(birthday: _birthday),
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

  // Save chosen birthday
  saveBirthday(DateTime picked) {
    setState(() => _birthday = picked);
    Prefs.birthday = _birthday;
  }

  // Android date picker
  buildMaterialDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      helpText: Str.birthdaySelectText,
      initialDate: _birthday,
      firstDate: DateTime(0),
      lastDate: DateTime(DateTime.now().year),
    );
    if (picked != null) {
      saveBirthday(picked);
    }
  }

  // Cupertino date picker
  buildCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).copyWith().size.height / 3,
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
                  onDateTimeChanged: (picked) => saveBirthday(picked),
                  initialDateTime: _birthday,
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
  Future<void> showAboutDialog() {
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
