/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    notifications.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Schedule and manage biorhythm alerts
// - Notification types

import 'package:biorhythmmm/common/helpers.dart';
import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:biorhythmmm/data/localization.dart';
import 'package:biorhythmmm/data/prefs.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

abstract class Notifications {
  static final FlutterLocalNotificationsPlugin _notify =
      FlutterLocalNotificationsPlugin();

  // Notification setup
  static const String _notifyChannel = 'Biorhythmmm_channel';
  static const String _notifyIcon = 'ic_stat_name';
  static const int _notifyLookAheadDays = 30;

  // Initialize notifications plugin
  static Future<void> init() async {
    await _notify.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings(_notifyIcon),
        iOS: DarwinInitializationSettings(
          // Wait to request permissions when user enables the setting
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        Notifications.handleNotificationTap();
      },
    );

    // Ensure scheduled notifications are set properly
    if (Prefs.notifications == NotificationType.none) {
      await cancel();
    } else {
      await schedule(Prefs.notificationTime);
    }
  }

  // Callback for when a notification is tapped
  static VoidCallback? onNotificationTap;

  static void handleNotificationTap() {
    onNotificationTap?.call();
  }

  // Schedule biorhythm notifications
  static Future<void> schedule(TimeOfDay time) async {
    // Request notification permissions
    if (Platform.isIOS) {
      await _notify
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else {
      await _notify
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    // Generate upcoming notifications
    int offsetDays = time.isAfter(TimeOfDay.now()) ? 0 : 1;
    List<(tz.TZDateTime, String)> alarms = [];
    if (Prefs.notifications == NotificationType.daily) {
      // Daily notifications
      alarms = List.generate(_notifyLookAheadDays, (int day) {
        DateTime date = today.add(Duration(days: day + offsetDays));

        // Generate biorhythm summary notification text for date
        return (
          _notifyAt(date, time),
          _biorhythmSummary([
            for (final Biorhythm b in Prefs.biorhythms)
              b.getBiorhythmPoint(dateDiff(Prefs.notifyBirthday, date)),
          ]),
        );
      });
    } else {
      // Only critical notifications
      for (int day = offsetDays; day <= _notifyLookAheadDays; day++) {
        DateTime date = today.add(Duration(days: day));

        // Determine if this date has any critical alerts
        List<String> criticals = Prefs.biorhythms
            .where(
              (Biorhythm b) =>
                  isCritical(b.getPoint(dateDiff(Prefs.notifyBirthday, date))),
            )
            .map((Biorhythm b) => b.localizedName)
            .toList();

        // Generate critical biorhythm text for date
        if (criticals.isNotEmpty) {
          alarms.add((
            _notifyAt(date, time),
            AppString.notifyCriticalPrefix.translate() + criticals.join(', '),
          ));
        }
      }
    }

    // Clear existing alarms unless rescheduling all
    if (alarms.length < _notifyLookAheadDays) {
      await cancel();
    }

    // Schedule alarms
    final NotificationDetails notificationDetails = _getNotificationDetails();
    for (final (tz.TZDateTime, String) alarm in alarms) {
      await _notify.zonedSchedule(
        alarms.indexOf(alarm),
        Prefs.notifyTitle,
        alarm.$2,
        alarm.$1,
        notificationDetails,
        payload: _notifyChannel,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
    }
  }

  // Cancel daily biorhythm notifications
  static Future<void> cancel() async {
    await _notify.cancelAll();
  }

  // Determine if app was launched from a notification
  static Future<bool> launchedFromNotification() async {
    final NotificationAppLaunchDetails? notifyLaunchDetails = await _notify
        .getNotificationAppLaunchDetails();
    return notifyLaunchDetails?.didNotificationLaunchApp ?? false;
  }

  // Notification details
  static NotificationDetails _getNotificationDetails() => NotificationDetails(
    android: AndroidNotificationDetails(
      _notifyChannel,
      AppString.notifyChannelName.translate(),
      showWhen: true,
      visibility: NotificationVisibility.public,
      channelShowBadge: true,
      playSound: true,
    ),
    iOS: const DarwinNotificationDetails(
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
    ),
  );

  // Calculate zoned notification time for a given date and time
  static tz.TZDateTime _notifyAt(DateTime date, TimeOfDay time) {
    tz.TZDateTime scheduleTime = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return scheduleTime;
  }

  // Summarize biorhythms for a list of points
  static String _biorhythmSummary(List<BiorhythmPoint> points) {
    return [
      for (final BiorhythmPoint p in points)
        '${p.biorhythm.localizedName}: ${shortPercent(p.point)}',
    ].join(', ');
  }
}

// Notification types
enum NotificationType {
  none(0),
  critical(1),
  daily(2);

  const NotificationType(this.value);

  final int value;

  // Display names
  String get name => switch (this) {
    none => AppString.notificationTypeNone.translate(),
    critical => AppString.notificationTypeCritical.translate(),
    daily => AppString.notificationTypeDaily.translate(),
  };
}
