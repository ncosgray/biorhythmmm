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

import 'package:biorhythmmm/common/buttons.dart';
import 'package:biorhythmmm/common/icons.dart';
import 'package:biorhythmmm/common/notifications.dart' show NotificationType;
import 'package:biorhythmmm/common/styles.dart';
import 'package:biorhythmmm/data/app_state.dart';
import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:biorhythmmm/data/localization.dart';
import 'package:biorhythmmm/widgets/birthday_manager.dart';
import 'package:biorhythmmm/widgets/time_picker.dart';

import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_down_button/pull_down_button.dart';

// Navigate to settings sheet
void showSettingsSheet(BuildContext context) {
  if (Platform.isIOS) {
    Navigator.of(context).push(
      CupertinoSheetRoute<void>(builder: (_) => buildSettingsSheet(context)),
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
  appBar: AppBar(
    title: Text(AppString.settingsTitle.translate()),
    toolbarHeight: 56,
  ),
  body: SingleChildScrollView(
    padding: const .all(8),
    child: SafeArea(
      child: Column(
        children: [
          // Select biorhythms
          Padding(
            padding: const .all(8),
            child: Text(
              AppString.selectBiorhythmsTitle.translate(),
              style: titleText,
            ),
          ),
          BlocSelector<AppStateCubit, AppState, List<Biorhythm>>(
            selector: (state) => state.biorhythms,
            builder: (context, biorhythms) => Column(
              crossAxisAlignment: .start,
              children: [
                for (final Biorhythm b in allBiorhythms)
                  CheckboxListTile.adaptive(
                    title: Text(b.localizedName, style: listTileText(context)),
                    value: context.read<AppStateCubit>().isBiorhythmSelected(b),
                    onChanged: (bool? value) {
                      // Add or remove selected biorhythm
                      if (value!) {
                        context.read<AppStateCubit>().addBiorhythm(b);
                      } else {
                        context.read<AppStateCubit>().removeBiorhythm(b);
                      }
                    },
                    enabled:
                        biorhythms.length > 1 ||
                        !context.read<AppStateCubit>().isBiorhythmSelected(b),
                    visualDensity: .compact,
                  ),
              ],
            ),
          ),
          // Other settings
          Padding(
            padding: const .all(8),
            child: Text(
              AppString.otherSettingsTitle.translate(),
              style: titleText,
            ),
          ),
          // Select notifications
          ListTile(
            title: Text(
              AppString.notificationsLabel.translate(),
              style: listTileText(context),
            ),
            trailing: BlocSelector<AppStateCubit, AppState, NotificationType>(
              selector: (state) => state.notifications,
              builder: (context, notifications) {
                if (Platform.isIOS) {
                  // iOS styled dropdown menu
                  return PullDownButton(
                    buttonBuilder: (_, showMenu) => adaptiveSettingButton(
                      onPressed: showMenu,
                      child: Text(notifications.name),
                    ),
                    // Notification type options
                    itemBuilder: (_) => [
                      for (final NotificationType n in NotificationType.values)
                        PullDownMenuItem.selectable(
                          selected: n == notifications,
                          title: n.name,
                          // Set selected notification type
                          onTap: () =>
                              context.read<AppStateCubit>().setNotifications(n),
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
                      for (final NotificationType n in NotificationType.values)
                        DropdownMenuItem(value: n, child: Text(n.name)),
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
          // Notification time
          BlocSelector<AppStateCubit, AppState, NotificationType>(
            selector: (state) => state.notifications,
            builder: (context, notifications) => AnimatedSize(
              duration: const Duration(milliseconds: 100),
              child: Visibility(
                visible: notifications != NotificationType.none,
                child: ListTile(
                  title: Text(
                    AppString.notificationTimeLabel.translate(),
                    style: listTileText(context),
                  ),
                  trailing: BlocSelector<AppStateCubit, AppState, TimeOfDay>(
                    selector: (state) => state.notificationTime,
                    builder: (context, notificationTime) =>
                        adaptiveSettingButton(
                          child: Text(notificationTime.format(context)),
                          onPressed: () async {
                            TimeOfDay? newValue = await adaptiveTimePicker(
                              context,
                              initialTime: notificationTime,
                              helpText: AppString.notificationTimeLabel
                                  .translate(),
                            );
                            if (!context.mounted) return;
                            if (newValue != null) {
                              // Set selected notification time
                              context.read<AppStateCubit>().setNotificationTime(
                                newValue,
                              );
                            }
                          },
                        ),
                  ),
                ),
              ),
            ),
          ),
          // Birthday manager
          BlocSelector<AppStateCubit, AppState, bool>(
            selector: (state) =>
                state.notifications != NotificationType.none &&
                state.birthdays.length > 1,
            builder: (context, showSetNotificationsLabel) {
              return ListTile(
                title: Text(
                  AppString.birthdayManageLabel.translate(),
                  style: listTileText(context),
                ),
                // Optional text about setting notifications
                subtitle: showSetNotificationsLabel
                    ? FittedBox(
                        fit: .scaleDown,
                        alignment: .centerLeft,
                        child: Row(
                          mainAxisSize: .min,
                          children: [
                            Text(AppString.setNotificationsLabel.translate()),
                            Padding(
                              padding: .symmetric(horizontal: 8),
                              child: Icon(notifyOnIcon, size: 16),
                            ),
                          ],
                        ),
                      )
                    : null,
                trailing: chevronIcon,
                onTap: () => showBirthdayManager(context),
              );
            },
          ),
          // Use accessible color palette
          ListTile(
            title: Text(
              AppString.useAccessibleColorsLabel.translate(),
              style: listTileText(context),
            ),
            trailing: BlocSelector<AppStateCubit, AppState, bool>(
              selector: (state) => state.useAccessibleColors,
              builder: (context, useAccessibleColors) => Switch.adaptive(
                value: useAccessibleColors,
                onChanged: (bool value) {
                  context.read<AppStateCubit>().setAccessibleColors(value);
                },
              ),
            ),
          ),
          // Show critical zone
          ListTile(
            title: Text(
              AppString.showCriticalZoneLabel.translate(),
              style: listTileText(context),
            ),
            trailing: BlocSelector<AppStateCubit, AppState, bool>(
              selector: (state) => state.showCriticalZone,
              builder: (context, showCriticalZone) => Switch.adaptive(
                value: showCriticalZone,
                onChanged: (bool value) {
                  context.read<AppStateCubit>().setCriticalZone(value);
                },
              ),
            ),
          ),
        ],
      ),
    ),
  ),
);
