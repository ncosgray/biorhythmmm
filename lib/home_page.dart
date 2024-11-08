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

import 'package:biorhythmmm/biorhythm_chart.dart';
import 'package:biorhythmmm/helpers.dart';
import 'package:biorhythmmm/main.dart';
import 'package:biorhythmmm/strings.dart';
import 'package:biorhythmmm/text_styles.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime birthday =
      DateTime.fromMillisecondsSinceEpoch(sharedPrefs.getInt(birthdayKey) ?? 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(Str.appName),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            BiorhythmChart(birthday: birthday),
            // Birthday setting
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${Str.birthdayLabel} ${longDate(birthday)}',
                    style: labelStyle,
                  ),
                  FilledButton.tonal(
                    onPressed: () => pickBirthday(context),
                    child: Text(
                      Str.birthdayButton,
                      style: buttonStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Open a dialog box to choose user birthday
  pickBirthday(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDatePicker(context);
      default:
        return buildMaterialDatePicker(context);
    }
  }

  // Save chosen birthday
  saveBirthday(DateTime picked) {
    setState(() => birthday = picked);
    sharedPrefs.setInt(birthdayKey, birthday.millisecondsSinceEpoch);
  }

  // Android date picker
  buildMaterialDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthday,
      firstDate: DateTime(0),
      lastDate: DateTime(DateTime.now().year),
      //builder: (context, child) => child!,
    );
    if (picked != null && picked != birthday) {
      saveBirthday(picked);
    }
  }

  // Cupertino date picker
  buildCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return SizedBox(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            onDateTimeChanged: (picked) {
              if (picked != birthday) {
                saveBirthday(picked);
              }
            },
            initialDateTime: birthday,
            maximumYear: DateTime.now().year,
          ),
        );
      },
    );
  }
}
