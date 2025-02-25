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
  static const String _notifyChannel = 'Biorhythmmm_channel';
  static const String _notifyIcon = 'ic_stat_name';
  static const int _notifyLookAheadDays = 30;
  static const int _notifyAtHour = 6;

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

    // Ensure scheduled notifications are set properly
    if (Prefs.dailyNotifications) {
      await schedule();
    } else {
      await cancel();
    }
  }

  // Schedule biorhythm notifications
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

    // Generate upcoming notifications
    List<(tz.TZDateTime, String)> alarms = List.generate(
      _notifyLookAheadDays,
      (int day) {
        DateTime date = today.add(Duration(days: day + 1));
        return (
          _notifyAt(date),
          _biorhythmSummary([
            for (final Biorhythm b in Prefs.biorhythms)
              (biorhythm: b, point: b.getPoint(dateDiff(Prefs.birthday, date))),
          ])
        );
      },
    );

    // Schedule alarms
    for (int n = 0; n < alarms.length; n++) {
      await _notifications.zonedSchedule(
        n,
        Str.notifyTitle,
        alarms[n].$2,
        alarms[n].$1,
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
      );
    }
  }

  // Cancel daily biorhythm notifications
  static Future<void> cancel() async {
    await _notifications.cancelAll();
  }

  // Calculate zoned notification time for a given date
  static tz.TZDateTime _notifyAt(DateTime date) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleTime =
        tz.TZDateTime(tz.local, date.year, date.month, date.day, _notifyAtHour);
    if (scheduleTime.isBefore(now)) {
      scheduleTime = now.add(const Duration(minutes: 1));
    }
    return scheduleTime;
  }

  // Summarize biorhythms for a list of points
  static String _biorhythmSummary(List<BiorhythmPoint> points) {
    return [
      for (final BiorhythmPoint p in points)
        '${p.biorhythm.name}: ${shortPercent(p.point)}',
    ].join(', ');
  }
}
