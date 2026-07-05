// Biorhythmmm
// - Helper function tests (date math and formatting)

import 'package:biorhythmmm/common/helpers.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Chicago'));
    Intl.defaultLocale = 'en_US';
  });

  group('dateDiff', () {
    test('same day is zero', () {
      final DateTime d = DateTime(2026, 7, 4);
      expect(dateDiff(d, d), 0);
    });

    test('counts calendar days', () {
      expect(dateDiff(DateTime(2026, 1, 1), DateTime(2026, 1, 8)), 7);
      expect(dateDiff(DateTime(2026, 1, 31), DateTime(2026, 2, 1)), 1);
    });

    test('ignores time-of-day components', () {
      expect(
        dateDiff(DateTime(2026, 1, 1, 23, 59), DateTime(2026, 1, 2, 0, 1)),
        1,
      );
    });

    test('addDays offsets the target date', () {
      final DateTime d = DateTime(2026, 7, 4);
      expect(dateDiff(d, d, addDays: 5), 5);
      expect(dateDiff(d, d, addDays: -3), -3);
    });

    test('negative for dates before the start date', () {
      expect(dateDiff(DateTime(2026, 1, 8), DateTime(2026, 1, 1)), -7);
    });

    test('handles leap years', () {
      // 2024 is a leap year
      expect(dateDiff(DateTime(2024, 2, 28), DateTime(2024, 3, 1)), 2);
      // 2026 is not
      expect(dateDiff(DateTime(2026, 2, 28), DateTime(2026, 3, 1)), 1);
    });

    test('counts calendar days across spring-forward DST transition', () {
      // US DST began March 8, 2026 in America/Chicago
      expect(dateDiff(DateTime(2026, 3, 7), DateTime(2026, 3, 9)), 2);
    });

    test('counts calendar days across fall-back DST transition', () {
      // US DST ended November 1, 2026 in America/Chicago
      expect(dateDiff(DateTime(2026, 10, 31), DateTime(2026, 11, 2)), 2);
    });

    test('counts calendar days over long spans crossing DST', () {
      // Winter birthday to a summer date (net one hour shorter locally)
      expect(dateDiff(DateTime(2026, 1, 1), DateTime(2026, 7, 1)), 181);
      // Multi-year span from a typical birthday
      expect(dateDiff(DateTime(1990, 6, 15), DateTime(1991, 6, 15)), 365);
    });
  });

  group('date formatting', () {
    final DateTime d = DateTime(2026, 7, 4); // a Saturday

    test('shortDate formats month/day', () {
      expect(shortDate(d), '7/4');
    });

    test('dateAndDay formats weekday with month/day', () {
      expect(dateAndDay(d), 'Sat 7/4');
    });

    test('longDate formats full date', () {
      expect(longDate(d), 'Jul 4, 2026');
    });
  });

  group('shortPercent', () {
    test('formats positive values', () {
      expect(shortPercent(0.5), '50%');
      expect(shortPercent(1), '100%');
      expect(shortPercent(0.999), '100%');
    });

    test('formats zero', () {
      expect(shortPercent(0), '0%');
    });

    test('formats negative values with a minus sign', () {
      expect(shortPercent(-0.5), '−50%');
      expect(shortPercent(-1), '−100%');
    });

    test('rounds to whole percent', () {
      expect(shortPercent(0.004), '0%');
      expect(shortPercent(0.005), '1%');
      expect(shortPercent(-0.004), '0%');
    });
  });
}
