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

import 'package:biorhythmmm/common/helpers.dart';
import 'package:biorhythmmm/common/icons.dart';
import 'package:biorhythmmm/common/strings.dart';
import 'package:biorhythmmm/common/styles.dart';
import 'package:biorhythmmm/data/app_state.dart';
import 'package:biorhythmmm/widgets/about_dialog.dart';
import 'package:biorhythmmm/widgets/biorhythm_chart.dart';
import 'package:biorhythmmm/widgets/birthday_picker.dart';
import 'package:biorhythmmm/widgets/settings_dialog.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        // Prompt user once if birthday is unset
        if (context.mounted && !context.read<AppStateCubit>().isBirthdaySet) {
          context.read<AppStateCubit>().saveBirthday();
          adaptiveBirthdayPicker(context);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(Str.appName),
        actions: [
          // About button
          IconButton(
            icon: Icon(helpIcon),
            onPressed: () => showAboutBiorhythms(context),
          ),
          // Settings button
          IconButton(
            icon: Icon(settingsIcon),
            onPressed: () => showSettings(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Reset button
                BlocSelector<AppStateCubit, AppState, bool>(
                  selector: (state) => state.showResetButton,
                  builder: (context, showResetButton) => Visibility.maintain(
                    visible: showResetButton,
                    child: TextButton.icon(
                      onPressed: () => context.read<AppStateCubit>().reload(),
                      label: Text(
                        Str.resetLabel,
                        style: labelText,
                      ),
                      icon: Icon(todayIcon, size: labelText.fontSize),
                      iconAlignment: IconAlignment.start,
                    ),
                  ),
                ),
                // Birthday setting
                BlocSelector<AppStateCubit, AppState, DateTime>(
                  selector: (state) => state.birthday,
                  builder: (context, birthday) => TextButton.icon(
                    onPressed: () => adaptiveBirthdayPicker(context),
                    label: Text(
                      '${Str.birthdayLabel} ${longDate(birthday)}',
                      style: labelText,
                    ),
                    icon: Icon(editIcon, size: labelText.fontSize),
                    iconAlignment: IconAlignment.end,
                  ),
                ),
                // Toggle extra biorhythms
                BlocSelector<AppStateCubit, AppState, bool>(
                  selector: (state) => state.showExtraPoints,
                  builder: (context, showExtraPoints) => TextButton.icon(
                    onPressed: () =>
                        context.read<AppStateCubit>().toggleExtraPoints(),
                    label: Text(
                      Str.toggleExtraLabel,
                      style: labelText,
                    ),
                    icon: Icon(
                      showExtraPoints ? visibleIcon : invisibleIcon,
                      size: labelText.fontSize,
                    ),
                    iconAlignment: IconAlignment.end,
                  ),
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
}
