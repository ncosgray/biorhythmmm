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
import 'package:biorhythmmm/common/strings.dart';
import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:biorhythmmm/data/prefs.dart';

import 'dart:io' show Platform;
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
  static const int _notifyAtHour = 6;

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
    );

    // Ensure scheduled notifications are set properly
    if (Prefs.notifications == NotificationType.none) {
      await cancel();
    } else {
      await schedule();
    }
  }

  // Schedule biorhythm notifications
  static Future<void> schedule() async {
    // Request notification permissions
    if (Platform.isIOS) {
      await _notify
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else {
      await _notify
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // Generate upcoming notifications
    List<(tz.TZDateTime, String)> alarms = [];
    if (Prefs.notifications == NotificationType.daily) {
      // Daily notifications
      alarms = List.generate(
        _notifyLookAheadDays,
        (int day) {
          DateTime date = today.add(Duration(days: day + 1));

          // Generate biorhythm summary notification text for date
          return (
            _notifyAt(date),
            _biorhythmSummary([
              for (final Biorhythm b in Prefs.biorhythms)
                (
                  biorhythm: b,
                  point: b.getPoint(dateDiff(Prefs.birthday, date))
                ),
            ])
          );
        },
      );
    } else {
      // Only critical notifications
      for (int day = 1; day <= _notifyLookAheadDays; day++) {
        DateTime date = today.add(Duration(days: day));

        // Determine if this date has any critical alerts
        List<String> criticals = Prefs.biorhythms
            .where(
              (Biorhythm b) =>
                  isCritical(b.getPoint(dateDiff(Prefs.birthday, date))),
            )
            .map((Biorhythm b) => b.name)
            .toList();

        // Generate critical biorhythm text for date
        if (criticals.isNotEmpty) {
          alarms.add(
            (_notifyAt(date), Str.notifyCriticalPrefix + criticals.join(', ')),
          );
        }
      }
    }

    // Clear existing alarms unless rescheduling all
    if (alarms.length < _notifyLookAheadDays) {
      await cancel();
    }

    // Schedule alarms
    for (final (tz.TZDateTime, String) alarm in alarms) {
      await _notify.zonedSchedule(
        alarms.indexOf(alarm),
        Str.notifyTitle,
        alarm.$2,
        alarm.$1,
        _notificationDetails,
        payload: _notifyChannel,
        androidScheduleMode: AndroidScheduleMode.inexact,
      );
    }
  }

  // Cancel daily biorhythm notifications
  static Future<void> cancel() async {
    await _notify.cancelAll();
  }

  // Notification details
  static final NotificationDetails _notificationDetails = NotificationDetails(
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
  );

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

// Notification types
enum NotificationType {
  none(0),
  critical(1),
  daily(2);

  const NotificationType(this.value);

  final int value;

  // Display names
  String get name => switch (this) {
        none => Str.notificationTypeNone,
        critical => Str.notificationTypeCritical,
        daily => Str.notificationTypeDaily,
      };
}
