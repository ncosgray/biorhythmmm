// Biorhythmmm
// - Shared preferences (settings persistence) tests

import 'package:biorhythmmm/common/notifications.dart' show NotificationType;
import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:biorhythmmm/data/prefs.dart';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  group('defaults with no stored preferences', () {
    setUp(() async {
      await initTestEnvironment();
    });

    test('no birthday is set', () {
      expect(Prefs.isBirthdaySet, isFalse);
    });

    test('selected birthday defaults to first entry', () {
      expect(Prefs.selectedBirthday, 0);
    });

    test('comparison birthday defaults to none', () {
      expect(Prefs.compareBirthday, -1);
    });

    test('biorhythms default to the primary three', () {
      expect(Prefs.biorhythms, primaryBiorhythms);
    });

    test('notifications default to none', () {
      expect(Prefs.notifications, NotificationType.none);
    });

    test('notification time defaults to 6:00 AM', () {
      expect(Prefs.notificationTime, const TimeOfDay(hour: 6, minute: 0));
    });

    test('accessible colors default to off', () {
      expect(Prefs.useAccessibleColors, isFalse);
    });

    test('critical zone display defaults to on', () {
      expect(Prefs.showCriticalZone, isTrue);
    });

    test('default zoom defaults to medium', () {
      expect(Prefs.defaultZoom, ZoomLevel.medium.days);
    });

    test('birthdays falls back to a default entry', () {
      final List<BirthdayEntry> birthdays = Prefs.birthdays;
      expect(birthdays.length, 1);
      expect(birthdays.first.name, 'Me');
      expect(birthdays.first.date, DateTime.fromMillisecondsSinceEpoch(0));
    });
  });

  group('setting and reading preferences', () {
    setUp(() async {
      await initTestEnvironment();
    });

    test('birthdays list round-trips through JSON storage', () {
      final List<BirthdayEntry> entries = [
        BirthdayEntry(name: 'Alice', date: DateTime(1990, 6, 15), notify: true),
        BirthdayEntry(name: 'Bob', date: DateTime(1985, 12, 1)),
      ];
      Prefs.birthdays = entries;

      expect(Prefs.isBirthdaySet, isTrue);
      final List<BirthdayEntry> stored = Prefs.birthdays;
      expect(stored.length, 2);
      expect(stored[0].name, 'Alice');
      expect(stored[0].date, DateTime(1990, 6, 15));
      expect(stored[0].notify, isTrue);
      expect(stored[1].name, 'Bob');
      expect(stored[1].date, DateTime(1985, 12, 1));
      expect(stored[1].notify, isFalse);
    });

    test('selected birthday determines Prefs.birthday', () {
      Prefs.birthdays = [
        BirthdayEntry(name: 'Alice', date: DateTime(1990, 6, 15)),
        BirthdayEntry(name: 'Bob', date: DateTime(1985, 12, 1)),
      ];
      Prefs.selectedBirthday = 1;
      expect(Prefs.selectedBirthday, 1);
      expect(Prefs.birthday, DateTime(1985, 12, 1));
    });

    test('comparison birthday persists', () {
      Prefs.compareBirthday = 1;
      expect(Prefs.compareBirthday, 1);
    });

    test('biorhythm selection persists by name', () {
      Prefs.biorhythms = [Biorhythm.physical, Biorhythm.spiritual];
      expect(Prefs.biorhythms, [Biorhythm.physical, Biorhythm.spiritual]);

      Prefs.biorhythms = allBiorhythms;
      expect(Prefs.biorhythms, allBiorhythms);
    });

    test('notification type persists', () {
      for (final NotificationType n in NotificationType.values) {
        Prefs.notifications = n;
        expect(Prefs.notifications, n);
      }
    });

    test('notification time persists as encoded int', () {
      Prefs.notificationTime = const TimeOfDay(hour: 8, minute: 30);
      expect(
        Prefs.notificationTime,
        const TimeOfDay(hour: 8, minute: 30),
      );

      // Midnight edge case
      Prefs.notificationTime = const TimeOfDay(hour: 0, minute: 0);
      expect(Prefs.notificationTime, const TimeOfDay(hour: 0, minute: 0));

      // End of day edge case
      Prefs.notificationTime = const TimeOfDay(hour: 23, minute: 59);
      expect(Prefs.notificationTime, const TimeOfDay(hour: 23, minute: 59));
    });

    test('accessible colors setting persists', () {
      Prefs.useAccessibleColors = true;
      expect(Prefs.useAccessibleColors, isTrue);
      Prefs.useAccessibleColors = false;
      expect(Prefs.useAccessibleColors, isFalse);
    });

    test('critical zone setting persists', () {
      Prefs.showCriticalZone = false;
      expect(Prefs.showCriticalZone, isFalse);
      Prefs.showCriticalZone = true;
      expect(Prefs.showCriticalZone, isTrue);
    });

    test('default zoom persists for every zoom level', () {
      for (final ZoomLevel z in ZoomLevel.values) {
        Prefs.defaultZoom = z.days;
        expect(Prefs.defaultZoom, z.days);
      }
    });

    test('invalid stored zoom falls back to medium', () {
      Prefs.defaultZoom = 13;
      expect(Prefs.defaultZoom, ZoomLevel.medium.days);
    });
  });

  group('invalid stored preferences', () {
    test('unknown notification type falls back to none', () async {
      await initTestEnvironment(prefs: {'notifications': 99});
      expect(Prefs.notifications, NotificationType.none);
    });

    test('unrecognized biorhythm names are skipped', () async {
      await initTestEnvironment(
        prefs: {
          'biorhythms': ['Physical', 'Bogus', 'Emotional'],
        },
      );
      expect(Prefs.biorhythms, [Biorhythm.physical, Biorhythm.emotional]);
    });
  });

  group('ZoomLevel', () {
    setUp(() async {
      await initTestEnvironment();
    });

    test('converts days to whole weeks', () {
      expect(ZoomLevel.small.weeks, 2);
      expect(ZoomLevel.medium.weeks, 4);
      expect(ZoomLevel.large.weeks, 8);
    });

    test('display name is the localized weeks string', () {
      expect(ZoomLevel.small.name, '2 weeks');
      expect(ZoomLevel.medium.name, '4 weeks');
      expect(ZoomLevel.large.name, '8 weeks');
    });
  });

  group('notification birthday selection', () {
    setUp(() async {
      await initTestEnvironment();
    });

    test('notifyBirthdayIndex finds the entry flagged for notifications', () {
      Prefs.birthdays = [
        BirthdayEntry(name: 'Alice', date: DateTime(1990, 6, 15)),
        BirthdayEntry(name: 'Bob', date: DateTime(1985, 12, 1), notify: true),
      ];
      expect(Prefs.notifyBirthdayIndex, 1);
      expect(Prefs.notifyBirthday, DateTime(1985, 12, 1));
    });

    test('notifyBirthdayIndex falls back to first entry', () {
      Prefs.birthdays = [
        BirthdayEntry(name: 'Alice', date: DateTime(1990, 6, 15)),
        BirthdayEntry(name: 'Bob', date: DateTime(1985, 12, 1)),
      ];
      expect(Prefs.notifyBirthdayIndex, 0);
    });

    test('notification title includes name only with multiple birthdays', () {
      Prefs.birthdays = [
        BirthdayEntry(name: 'Alice', date: DateTime(1990, 6, 15), notify: true),
      ];
      expect(Prefs.notifyTitle.contains('Alice'), isFalse);

      Prefs.birthdays = [
        BirthdayEntry(name: 'Alice', date: DateTime(1990, 6, 15), notify: true),
        BirthdayEntry(name: 'Bob', date: DateTime(1985, 12, 1)),
      ];
      expect(Prefs.notifyTitle.contains('Alice'), isTrue);
    });
  });

  group('legacy preference migration', () {
    test('legacy single birthday is migrated and readable', () async {
      final DateTime legacyBirthday = DateTime(1980, 3, 21);
      await initTestEnvironment(
        legacyPrefs: {'birthday': legacyBirthday.millisecondsSinceEpoch},
      );

      expect(Prefs.isBirthdaySet, isTrue);
      final List<BirthdayEntry> birthdays = Prefs.birthdays;
      expect(birthdays.length, 1);
      expect(birthdays.first.date, legacyBirthday);
      expect(birthdays.first.name, 'Me');
      expect(birthdays.first.notify, isTrue);
    });

    test('legacy settings are migrated', () async {
      await initTestEnvironment(
        legacyPrefs: {
          'notifications': NotificationType.daily.value,
          'useAccessibleColors': true,
          'showCriticalZone': false,
        },
      );

      expect(Prefs.notifications, NotificationType.daily);
      expect(Prefs.useAccessibleColors, isTrue);
      expect(Prefs.showCriticalZone, isFalse);
    });
  });

  group('BirthdayEntry JSON', () {
    setUp(() async {
      await initTestEnvironment();
    });

    test('round-trips through toJson/fromJson', () {
      final BirthdayEntry entry = BirthdayEntry(
        name: 'Test',
        date: DateTime(2000, 1, 1),
        notify: true,
      );
      final BirthdayEntry decoded = BirthdayEntry.fromJson(entry.toJson());
      expect(decoded.name, 'Test');
      expect(decoded.date, DateTime(2000, 1, 1));
      expect(decoded.notify, isTrue);
    });

    test('fromJson applies defaults for missing fields', () {
      final BirthdayEntry decoded = BirthdayEntry.fromJson(const {});
      expect(decoded.name, 'Me');
      expect(decoded.date, DateTime.fromMillisecondsSinceEpoch(0));
      expect(decoded.notify, isFalse);
    });
  });
}
