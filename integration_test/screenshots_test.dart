/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    screenshots_test.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Generate Biorhythmmm screenshots

import 'package:biorhythmmm/common/helpers.dart';
import 'package:biorhythmmm/data/localization.dart';
import 'package:biorhythmmm/main.dart';
import 'package:biorhythmmm/common/icons.dart';

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized()
    ..framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(() async {
    // Initialize app
    await initApp();

    // Initialize Flutter bindings
    TestWidgetsFlutterBinding.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isAndroid) {
      await binding.convertFlutterSurfaceToImage();
    }
  });

  // Helper to create a birthday entry
  createBirthdayEntry($, String name, int years) async {
    await $.tap(find.text(AppString.dateSelectLabel.translate()));
    await $.pumpAndSettle();
    if (Platform.isIOS) {
      await $.tap(
        find.textContaining(
          (today.year - years).toString(),
          skipOffstage: false,
        ),
      );
      await $.pumpAndSettle();
      await $.tap(
        find.descendant(
          of: find.byType(StatefulBuilder),
          matching: find.text(AppString.doneLabel.translate()),
        ),
      );
    } else {
      await $.tap(
        find.textContaining((today.year).toString(), skipOffstage: false),
      );
      await $.pumpAndSettle();
      await $.tap(
        find.textContaining(
          (today.year - years).toString(),
          skipOffstage: false,
        ),
      );
      await $.pumpAndSettle();
      final okButton = find
          .ancestor(
            of: find.text(AppString.okLabel.translate()),
            matching: find.byType(TextButton),
          )
          .first;
      await $.tap(okButton);
    }
    await $.pumpAndSettle();
    final textField = find
        .byWidgetPredicate(
          (widget) => widget is TextField || widget is CupertinoTextField,
        )
        .first;
    await $.tap(textField);
    await $.enterText(textField, name);
    await $.tap(find.text(AppString.okLabel.translate()));
    await $.pumpAndSettle();
  }

  testWidgets('collect screenshots', ($) async {
    // Run app
    await $.pumpWidget(const BiorhythmApp());
    await $.pumpAndSettle();

    // Set up user birthdays
    String name = AppString.birthdayDefaultName.translate();
    String secondaryName = '${AppString.birthdayNameLabel.translate()} 2';
    await createBirthdayEntry($, secondaryName, 2);
    await $.tap(find.text(secondaryName));
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.manageLabel.translate()));
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.birthdayAddLabel.translate()));
    await $.pumpAndSettle();
    await createBirthdayEntry($, name, 1);

    // Screenshot 1: Initial home screen
    await $.tap(find.text(AppString.chartTitle.translate()));
    await $.pumpAndSettle();
    sleep(const Duration(seconds: 2));
    await binding.takeScreenshot('1-initial');

    // Screenshot 2: Chart with all biorhythms visible
    await $.tap(find.byIcon(invisibleIcon));
    await $.pumpAndSettle();
    sleep(const Duration(seconds: 2));
    await binding.takeScreenshot('2-visible');

    // Screenshot 3: Comparison chart
    await $.tap(find.byIcon(visibleIcon));
    await $.pumpAndSettle();
    await $.tap(find.text(name));
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.compareLabel.translate()));
    await $.pumpAndSettle();
    await $.tap(find.text(secondaryName));
    await $.pumpAndSettle();
    await $.tap(find.text(AppString.chartTitle.translate()));
    await $.pumpAndSettle();
    sleep(const Duration(seconds: 2));
    await binding.takeScreenshot('3-comparison');

    // Screenshot 4: Settings page
    await $.tap(find.byIcon(settingsIcon));
    await $.pumpAndSettle();
    sleep(const Duration(seconds: 2));
    await binding.takeScreenshot('4-settings');
  });
}
