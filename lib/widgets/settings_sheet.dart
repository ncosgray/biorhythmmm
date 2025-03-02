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
// - Adaptive settings sheet
// - App settings: biorhythm selection, notification type

import 'package:biorhythmmm/common/helpers.dart';
import 'package:biorhythmmm/common/notifications.dart' show NotificationType;
import 'package:biorhythmmm/common/strings.dart';
import 'package:biorhythmmm/common/styles.dart';
import 'package:biorhythmmm/data/app_state.dart';
import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:biorhythmmm/widgets/adaptive.dart';
import 'package:biorhythmmm/widgets/birthday_picker.dart';

import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_down_button/pull_down_button.dart';

// Navigate to settings sheet
showSettingsSheet(BuildContext context) {
  if (Platform.isIOS) {
    Navigator.of(context).push(
      CupertinoSheetRoute<void>(
        builder: (_) => buildSettingsSheet(context),
      ),
    );
  } else {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => buildSettingsSheet(context),
      ),
    );
  }
}

// Settings sheet
Widget buildSettingsSheet(BuildContext context) => Scaffold(
      appBar: adaptiveSheetAppBar(
        context: context,
        title: Str.settingsTitle,
        dismissLabel: Str.doneLabel,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Select biorhythms
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(Str.selectBiorhythmsTitle, style: titleText),
            ),
            BlocSelector<AppStateCubit, AppState, List<Biorhythm>>(
              selector: (state) => state.biorhythms,
              builder: (context, biorhythms) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final Biorhythm b in allBiorhythms)
                    adaptiveListTile(
                      title: Text(b.name, style: listTileText),
                      trailing: Checkbox.adaptive(
                        value: context
                            .read<AppStateCubit>()
                            .isBiorhythmSelected(b),
                        onChanged: biorhythms.length > 1 ||
                                !context
                                    .read<AppStateCubit>()
                                    .isBiorhythmSelected(b)
                            ? (bool? value) {
                                // Add or remove selected biorhythm
                                if (value!) {
                                  context.read<AppStateCubit>().addBiorhythm(b);
                                } else {
                                  context
                                      .read<AppStateCubit>()
                                      .removeBiorhythm(b);
                                }
                              }
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            // Other settings
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(Str.otherSettingsTitle, style: titleText),
            ),
            // Birthday
            adaptiveListTile(
              title: Text(Str.birthdayLabel, style: listTileText),
              trailing: BlocSelector<AppStateCubit, AppState, DateTime>(
                selector: (state) => state.birthday,
                builder: (context, birthday) => adaptiveButton(
                  onPressed: () => adaptiveBirthdayPicker(context),
                  child: Text(longDate(birthday), style: listTileText),
                ),
              ),
            ),
            // Select notifications
            adaptiveListTile(
              title: Text(Str.notificationsLabel, style: listTileText),
              trailing: BlocSelector<AppStateCubit, AppState, NotificationType>(
                selector: (state) => state.notifications,
                builder: (context, notifications) {
                  if (Platform.isIOS) {
                    // iOS styled dropdown menu
                    return PullDownButton(
                      buttonBuilder: (_, showMenu) => adaptiveButton(
                        onPressed: showMenu,
                        child: Text(notifications.name, style: listTileText),
                      ),
                      // Notification type options
                      itemBuilder: (_) => [
                        for (final NotificationType n
                            in NotificationType.values)
                          PullDownMenuItem.selectable(
                            selected: n == notifications,
                            title: n.name,
                            // Set selected notification type
                            onTap: () => context
                                .read<AppStateCubit>()
                                .setNotifications(n),
                          ),
                      ],
                    );
                  } else {
                    // Material dropdown menu
                    return DropdownButton<NotificationType>(
                      value: notifications,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      // Notification type options
                      items: [
                        for (final NotificationType n
                            in NotificationType.values)
                          DropdownMenuItem(
                            value: n,
                            child: Text(n.name),
                          ),
                      ],
                      // Set selected notification type
                      onChanged: (NotificationType? newValue) => context
                          .read<AppStateCubit>()
                          .setNotifications(newValue!),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
