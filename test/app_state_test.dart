// Biorhythmmm
// - App state cubit tests (settings changes)

import 'package:biorhythmmm/common/notifications.dart' show NotificationType;
import 'package:biorhythmmm/data/app_state.dart';
import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:biorhythmmm/data/prefs.dart';

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  late FakeNotificationsPlatform fakeNotifications;
  late AppStateCubit cubit;

  final DateTime aliceBirthday = DateTime(1990, 6, 15);
  final DateTime bobBirthday = DateTime(1985, 12, 1);

  setUp(() async {
    fakeNotifications = await initTestEnvironment();
    Prefs.birthdays = [
      BirthdayEntry(name: 'Alice', date: aliceBirthday),
      BirthdayEntry(name: 'Bob', date: bobBirthday),
    ];

    cubit = AppStateCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  group('initial state', () {
    test('reflects stored preferences', () {
      expect(cubit.state.birthdays.length, 2);
      expect(cubit.state.selectedBirthday, 0);
      expect(cubit.state.compareBirthday, -1);
      expect(cubit.state.biorhythms, primaryBiorhythms);
      expect(cubit.state.notifications, NotificationType.none);
      expect(cubit.state.notificationTime, const TimeOfDay(hour: 6, minute: 0));
      expect(cubit.state.useAccessibleColors, isFalse);
      expect(cubit.state.showExtraPoints, isFalse);
      expect(cubit.state.showCriticalZone, isTrue);
      expect(cubit.state.defaultZoom, ZoomLevel.medium.days);
      expect(cubit.state.showResetButton, isFalse);
      expect(cubit.state.reload, isFalse);
    });

    test('getters expose the selected birthday', () {
      expect(cubit.birthday, aliceBirthday);
      expect(cubit.birthdayName, 'Alice');
      expect(cubit.compareBirthday, isNull);
      expect(cubit.compareBirthdayName, isNull);
    });
  });

  group('birthday management', () {
    test('setBirthdays replaces the list and selects the last entry', () {
      cubit.setBirthdays([
        BirthdayEntry(name: 'Carol', date: DateTime(2000, 1, 1)),
      ]);
      expect(cubit.state.birthdays.length, 1);
      expect(cubit.state.selectedBirthday, 0);
      expect(cubit.birthdayName, 'Carol');
      expect(Prefs.birthdays.first.name, 'Carol');
    });

    test('addBirthday appends and selects the new entry', () {
      cubit.addBirthday(BirthdayEntry(name: 'Carol', date: DateTime(2000)));
      expect(cubit.state.birthdays.length, 3);
      expect(cubit.state.selectedBirthday, 2);
      expect(cubit.birthdayName, 'Carol');
    });

    test('editBirthday updates an entry in place', () {
      cubit.editBirthday(
        1,
        BirthdayEntry(name: 'Robert', date: bobBirthday),
      );
      expect(cubit.state.birthdays[1].name, 'Robert');
      expect(Prefs.birthdays[1].name, 'Robert');
    });

    test('removeBirthday clamps the selected birthday', () {
      cubit
        ..setSelectedBirthday(1)
        ..removeBirthday(1);
      expect(cubit.state.birthdays.length, 1);
      expect(cubit.state.selectedBirthday, 0);
      expect(cubit.birthdayName, 'Alice');
    });

    test('setSelectedBirthday switches the active birthday', () {
      cubit.setSelectedBirthday(1);
      expect(cubit.birthday, bobBirthday);
      expect(cubit.birthdayName, 'Bob');
      expect(Prefs.selectedBirthday, 1);
    });

    test('toggleBirthdayNotify flags exactly one birthday', () {
      cubit.toggleBirthdayNotify(1);
      expect(cubit.state.birthdays[0].notify, isFalse);
      expect(cubit.state.birthdays[1].notify, isTrue);

      cubit.toggleBirthdayNotify(0);
      expect(cubit.state.birthdays[0].notify, isTrue);
      expect(cubit.state.birthdays[1].notify, isFalse);
    });
  });

  group('comparison birthday', () {
    test('setCompareBirthday exposes the comparison entry', () {
      cubit.setCompareBirthday(1);
      expect(cubit.compareBirthday, bobBirthday);
      expect(cubit.compareBirthdayName, 'Bob');
      expect(Prefs.compareBirthday, 1);
    });

    test('clearCompareBirthday resets to none', () {
      cubit
        ..setCompareBirthday(1)
        ..clearCompareBirthday();
      expect(cubit.state.compareBirthday, -1);
      expect(cubit.compareBirthday, isNull);
      expect(Prefs.compareBirthday, -1);
    });
  });

  group('biorhythm selection', () {
    test('addBiorhythm maintains canonical order', () {
      cubit
        ..addBiorhythm(Biorhythm.spiritual)
        ..addBiorhythm(Biorhythm.intuition);
      expect(cubit.state.biorhythms, [
        Biorhythm.intellectual,
        Biorhythm.emotional,
        Biorhythm.physical,
        Biorhythm.intuition,
        Biorhythm.spiritual,
      ]);
      expect(Prefs.biorhythms, cubit.state.biorhythms);
    });

    test('removeBiorhythm deselects a biorhythm', () {
      cubit.removeBiorhythm(Biorhythm.emotional);
      expect(cubit.state.biorhythms, [
        Biorhythm.intellectual,
        Biorhythm.physical,
      ]);
      expect(cubit.isBiorhythmSelected(Biorhythm.emotional), isFalse);
      expect(cubit.isBiorhythmSelected(Biorhythm.physical), isTrue);
    });

    test('selecting all biorhythms enables extra points display', () {
      for (final Biorhythm b in allBiorhythms) {
        cubit.addBiorhythm(b);
      }
      expect(cubit.state.biorhythms, allBiorhythms);
      expect(cubit.state.showExtraPoints, isTrue);

      cubit.removeBiorhythm(Biorhythm.spiritual);
      expect(cubit.state.showExtraPoints, isFalse);
    });

    test('toggleExtraPoints shows all biorhythms without persisting', () {
      cubit.toggleExtraPoints();
      expect(cubit.state.showExtraPoints, isTrue);
      expect(cubit.state.biorhythms, allBiorhythms);
      // Persisted selection is unchanged
      expect(Prefs.biorhythms, primaryBiorhythms);

      cubit.toggleExtraPoints();
      expect(cubit.state.showExtraPoints, isFalse);
      expect(cubit.state.biorhythms, primaryBiorhythms);
    });
  });

  group('notification settings', () {
    test('setNotifications persists the type', () {
      cubit.setNotifications(NotificationType.daily);
      expect(cubit.state.notifications, NotificationType.daily);
      expect(Prefs.notifications, NotificationType.daily);

      cubit.setNotifications(NotificationType.critical);
      expect(cubit.state.notifications, NotificationType.critical);
      expect(Prefs.notifications, NotificationType.critical);
    });

    test('enabling notifications flags a notify birthday', () {
      expect(cubit.state.birthdays.any((b) => b.notify), isFalse);
      cubit.setNotifications(NotificationType.daily);
      expect(cubit.state.birthdays[0].notify, isTrue);
    });

    test('disabling notifications cancels scheduled alerts', () {
      cubit.setNotifications(NotificationType.none);
      expect(fakeNotifications.calls, contains('cancelAll'));
    });

    test('setNotificationTime persists the time', () {
      cubit.setNotificationTime(const TimeOfDay(hour: 21, minute: 15));
      expect(
        cubit.state.notificationTime,
        const TimeOfDay(hour: 21, minute: 15),
      );
      expect(
        Prefs.notificationTime,
        const TimeOfDay(hour: 21, minute: 15),
      );
    });
  });

  group('display settings', () {
    test('setAccessibleColors persists', () {
      cubit.setAccessibleColors(true);
      expect(cubit.state.useAccessibleColors, isTrue);
      expect(Prefs.useAccessibleColors, isTrue);

      cubit.setAccessibleColors(false);
      expect(cubit.state.useAccessibleColors, isFalse);
      expect(Prefs.useAccessibleColors, isFalse);
    });

    test('setCriticalZone persists', () {
      cubit.setCriticalZone(false);
      expect(cubit.state.showCriticalZone, isFalse);
      expect(Prefs.showCriticalZone, isFalse);

      cubit.setCriticalZone(true);
      expect(cubit.state.showCriticalZone, isTrue);
      expect(Prefs.showCriticalZone, isTrue);
    });

    test('setDefaultZoom persists', () {
      cubit.setDefaultZoom(ZoomLevel.large.days);
      expect(cubit.state.defaultZoom, ZoomLevel.large.days);
      expect(cubit.defaultZoom, ZoomLevel.large.days);
      expect(Prefs.defaultZoom, ZoomLevel.large.days);

      cubit.setDefaultZoom(ZoomLevel.small.days);
      expect(cubit.state.defaultZoom, ZoomLevel.small.days);
      expect(Prefs.defaultZoom, ZoomLevel.small.days);
    });
  });

  group('chart reset and reload', () {
    test('enableResetButton shows the reset button once', () {
      cubit.enableResetButton();
      expect(cubit.state.showResetButton, isTrue);
    });

    test('reload and resetReload round-trip', () {
      cubit
        ..enableResetButton()
        ..reload();
      expect(cubit.state.reload, isTrue);

      cubit.resetReload();
      expect(cubit.state.reload, isFalse);
      expect(cubit.state.showResetButton, isFalse);
    });
  });
}
