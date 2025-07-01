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

import 'dart:io' show Platform;

import 'package:biorhythmmm/common/buttons.dart';
import 'package:biorhythmmm/common/helpers.dart';
import 'package:biorhythmmm/common/icons.dart';
import 'package:biorhythmmm/common/strings.dart';
import 'package:biorhythmmm/common/styles.dart';
import 'package:biorhythmmm/data/app_state.dart';
import 'package:biorhythmmm/data/prefs.dart';
import 'package:biorhythmmm/widgets/about_dialog.dart';
import 'package:biorhythmmm/widgets/biorhythm_chart.dart';
import 'package:biorhythmmm/widgets/birthday_manager.dart';
import 'package:biorhythmmm/widgets/birthday_picker.dart';
import 'package:biorhythmmm/widgets/settings_sheet.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_down_button/pull_down_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Prompt user once if birthday is unset
      if (context.mounted && !Prefs.isBirthdaySet) {
        final picked = await adaptiveBirthdayPicker(context);
        if (!context.mounted) return;
        context.read<AppStateCubit>().setBirthdays([
          BirthdayEntry(date: picked ?? today),
        ]);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(Str.chartTitle),
        actions: [
          // About button
          IconButton(
            icon: Icon(helpIcon),
            onPressed: () => showAboutBiorhythms(context),
          ),
          // Settings button
          IconButton(
            icon: Icon(settingsIcon),
            onPressed: () => showSettingsSheet(context),
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
                    child: adaptiveIconButton(
                      child: Text(Str.resetLabel, style: labelText),
                      icon: Icon(todayIcon, size: labelText.fontSize),
                      onPressed: () => context.read<AppStateCubit>().reload(),
                    ),
                  ),
                ),
                // Birthday switcher
                BlocSelector<AppStateCubit, AppState, AppState>(
                  selector: (state) => state,
                  builder: (context, state) {
                    final entries = state.birthdays;
                    final selected = state.selectedBirthday;
                    if (Platform.isIOS) {
                      return PullDownButton(
                        buttonBuilder: (_, showMenu) => adaptiveSettingButton(
                          onPressed: showMenu,
                          child: Text(entries[selected].name, style: labelText),
                        ),
                        itemBuilder: (_) => [
                          for (int i = 0; i < entries.length; i++)
                            PullDownMenuItem.selectable(
                              selected: i == selected,
                              title: entries[i].name,
                              onTap: () => context
                                  .read<AppStateCubit>()
                                  .setSelectedBirthday(i),
                            ),
                          PullDownMenuItem(
                            title: Str.manageLabel,
                            onTap: () => showBirthdayManager(context),
                          ),
                        ],
                      );
                    } else {
                      return DropdownButton<int>(
                        style: labelText,
                        value: selected,
                        items: [
                          for (int i = 0; i < entries.length; i++)
                            DropdownMenuItem(
                              value: i,
                              child: Text(entries[i].name),
                            ),
                          DropdownMenuItem(
                            value: -1,
                            child: Text(Str.manageLabel),
                          ),
                        ],
                        onChanged: (i) {
                          if (i == null) return;
                          if (i == -1) {
                            showBirthdayManager(context);
                          } else {
                            context.read<AppStateCubit>().setSelectedBirthday(
                              i,
                            );
                          }
                        },
                      );
                    }
                  },
                ),
                // Toggle extra biorhythms
                BlocSelector<AppStateCubit, AppState, bool>(
                  selector: (state) => state.showExtraPoints,
                  builder: (context, showExtraPoints) => adaptiveIconButton(
                    child: Text(Str.toggleExtraLabel, style: labelText),
                    icon: Icon(
                      showExtraPoints ? visibleIcon : invisibleIcon,
                      size: labelText.fontSize,
                    ),
                    iconAlignEnd: true,
                    onPressed: () =>
                        context.read<AppStateCubit>().toggleExtraPoints(),
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
