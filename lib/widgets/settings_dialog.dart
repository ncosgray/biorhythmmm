/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    settings_dialog.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - App settings: biorhythm selection

import 'package:biorhythmmm/common/notifications.dart';
import 'package:biorhythmmm/common/strings.dart';
import 'package:biorhythmmm/data/app_state.dart';
import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:biorhythmmm/widgets/dialog_action.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Settings dialog
Future<void> showSettings(BuildContext context) {
  return showAdaptiveDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return StatefulBuilder(
        builder: (_, setDialogState) {
          return AlertDialog.adaptive(
            content: SingleChildScrollView(
              child: Material(
                type: MaterialType.transparency,
                child: Column(
                  children: [
                    // Select biorhythms
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(Str.selectBiorhythmsTitle),
                    ),
                    BlocSelector<AppStateCubit, AppState, List<Biorhythm>>(
                      selector: (state) => state.biorhythms,
                      builder: (context, biorhythms) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final Biorhythm b in allBiorhythms)
                            CheckboxListTile.adaptive(
                              title: Text(b.name),
                              value: context
                                  .read<AppStateCubit>()
                                  .isBiorhythmSelected(b),
                              onChanged: (bool? value) {
                                // Add or remove selected biorhythm
                                setDialogState(() {
                                  if (value!) {
                                    context
                                        .read<AppStateCubit>()
                                        .addBiorhythm(b);
                                  } else {
                                    context
                                        .read<AppStateCubit>()
                                        .removeBiorhythm(b);
                                  }
                                });
                              },
                              enabled: biorhythms.length > 1 ||
                                  !context
                                      .read<AppStateCubit>()
                                      .isBiorhythmSelected(b),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ),
                    // Other settings
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(Str.otherSettingsTitle),
                    ),
                    // Daily notifications
                    BlocSelector<AppStateCubit, AppState, bool>(
                      selector: (state) => state.dailyNotifications,
                      builder: (context, dailyNotifications) =>
                          SwitchListTile.adaptive(
                        title: Text(Str.dailyNotificationsText),
                        value: dailyNotifications,
                        onChanged: (bool? value) async {
                          // Schedule or cancel notifications
                          context
                              .read<AppStateCubit>()
                              .setDailyNotifications(value!);
                          if (value) {
                            await Notifications.schedule();
                          } else {
                            await Notifications.cancel();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ],
                ),
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
