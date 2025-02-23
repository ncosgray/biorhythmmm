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
// - Daily notifications

import 'package:biorhythmmm/common/helpers.dart';
import 'package:biorhythmmm/common/strings.dart';
import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:biorhythmmm/data/prefs.dart';

import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;

abstract class Notifications {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Notification setup
  static const int _notifyID = 0;
  static const String _notifyChannel = 'Biorhythmmm_channel';
  static const String _notifyIcon = 'ic_stat_name';
  static const int _notifyHour = 6;

  // Initialize notifications plugin
  static Future<void> init() async {
    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings(_notifyIcon),
        iOS: DarwinInitializationSettings(
          // Wait to request permissions when user enables the setting
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        ),
      ),
    );
  }

  // Schedule daily biorhythm notifications
  static Future<void> schedule() async {
    // Request notification permissions
    if (Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // Schedule the alarm
    await _notifications.zonedSchedule(
      _notifyID,
      Str.notifyTitle,
      _biorhythmSummary(_nextScheduleInstance),
      _nextScheduleInstance,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _notifyChannel,
          Str.notifyChannelName,
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
      ),
      payload: _notifyChannel,
      androidScheduleMode: AndroidScheduleMode.inexact,
      // Repeat daily at time
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Cancel daily biorhythm notifications
  static Future<void> cancel() async {
    await _notifications.cancel(_notifyID);
  }

  // Calculate the next notification time
  static tz.TZDateTime get _nextScheduleInstance {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, _notifyHour);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Summarize biorhythms for date
  static String _biorhythmSummary(tz.TZDateTime date) {
    int day = dateDiff(Prefs.birthday, date);
    return [
      for (final Biorhythm b in Prefs.biorhythms)
        '${b.name}: ${shortPercent(b.getPoint(day))}',
    ].join(', ');
  }
}
