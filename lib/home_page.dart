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
  // State variables
  DateTime _birthday =
      DateTime.fromMillisecondsSinceEpoch(sharedPrefs.getInt(birthdayKey) ?? 0);

  @override
  void initState() {
    // Prompt user once if birthday is unset
    Future.delayed(
      Duration.zero,
      () {
        if (mounted && !sharedPrefs.containsKey(birthdayKey)) {
          saveBirthday(_birthday);
          pickBirthday(context);
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
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            // Birthday setting
            Padding(
              padding: const EdgeInsets.all(4),
              child: TextButton.icon(
                onPressed: () => pickBirthday(context),
                style: TextButton.styleFrom(
                  splashFactory: NoSplash.splashFactory,
                ),
                label: Text(
                  '${Str.birthdayLabel} ${longDate(_birthday)}',
                  style: labelStyle,
                ),
                icon: Icon(Icons.edit, size: labelStyle.fontSize),
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
    setState(() => _birthday = picked);
    sharedPrefs.setInt(birthdayKey, _birthday.millisecondsSinceEpoch);
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
                    style: titleStyle,
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
}
