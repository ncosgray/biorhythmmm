// Biorhythmmm
// - Biorhythm calculation tests

import 'package:biorhythmmm/data/biorhythm.dart';

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Biorhythm cycle definitions', () {
    test('cycle lengths match the biorhythm model', () {
      expect(Biorhythm.physical.cycleDays, 23);
      expect(Biorhythm.emotional.cycleDays, 28);
      expect(Biorhythm.intellectual.cycleDays, 33);
      expect(Biorhythm.intuition.cycleDays, 38);
      expect(Biorhythm.aesthetic.cycleDays, 43);
      expect(Biorhythm.awareness.cycleDays, 48);
      expect(Biorhythm.spiritual.cycleDays, 53);
    });

    test('primary biorhythms are intellectual, emotional, and physical', () {
      expect(primaryBiorhythms, [
        Biorhythm.intellectual,
        Biorhythm.emotional,
        Biorhythm.physical,
      ]);
      expect(allBiorhythms, Biorhythm.values);
      expect(allBiorhythms.length, 7);
    });
  });

  group('Biorhythm point calculation', () {
    test('all cycles start at zero on the day of birth', () {
      for (final Biorhythm b in Biorhythm.values) {
        expect(b.getPoint(0), 0);
      }
    });

    test('emotional cycle hits known values (28-day sine wave)', () {
      // Quarter cycle: peak
      expect(Biorhythm.emotional.getPoint(7), closeTo(1, 1e-12));
      // Half cycle: crossing zero
      expect(Biorhythm.emotional.getPoint(14), closeTo(0, 1e-12));
      // Three-quarter cycle: trough
      expect(Biorhythm.emotional.getPoint(21), closeTo(-1, 1e-12));
      // Full cycle: back to zero
      expect(Biorhythm.emotional.getPoint(28), closeTo(0, 1e-12));
    });

    test('points match the sine formula for arbitrary days', () {
      for (final Biorhythm b in Biorhythm.values) {
        for (final int day in [1, 10, 100, 1000, 10000]) {
          expect(
            b.getPoint(day),
            closeTo(sin(2 * pi * day / b.cycleDays), 1e-12),
            reason: '${b.name} day $day',
          );
        }
      }
    });

    test('cycles are periodic', () {
      for (final Biorhythm b in Biorhythm.values) {
        expect(
          b.getPoint(12345),
          closeTo(b.getPoint(12345 + b.cycleDays), 1e-9),
          reason: b.name,
        );
      }
    });

    test('points stay within [-1, 1]', () {
      for (final Biorhythm b in Biorhythm.values) {
        for (int day = 0; day < 400; day++) {
          final double point = b.getPoint(day);
          expect(point, inInclusiveRange(-1, 1));
        }
      }
    });

    test('first half of cycle is positive, second half negative', () {
      // Physical cycle is 23 days: days 1-11 high phase, days 12-22 low phase
      for (int day = 1; day <= 11; day++) {
        expect(Biorhythm.physical.getPoint(day), greaterThan(0));
      }
      for (int day = 12; day <= 22; day++) {
        expect(Biorhythm.physical.getPoint(day), lessThan(0));
      }
    });

    test('negative day counts (before birth) mirror positive ones', () {
      for (final Biorhythm b in Biorhythm.values) {
        expect(b.getPoint(-5), closeTo(-b.getPoint(5), 1e-12));
      }
    });
  });

  group('Critical values', () {
    test('values near zero are critical', () {
      expect(isCritical(0), isTrue);
      expect(isCritical(0.1), isTrue);
      expect(isCritical(-0.1), isTrue);
      expect(isCritical(0.149999), isTrue);
      expect(isCritical(-0.149999), isTrue);
    });

    test('values at or beyond the threshold are not critical', () {
      expect(isCritical(criticalThreshold), isFalse);
      expect(isCritical(-criticalThreshold), isFalse);
      expect(isCritical(0.5), isFalse);
      expect(isCritical(-0.5), isFalse);
      expect(isCritical(1), isFalse);
      expect(isCritical(-1), isFalse);
    });
  });

  group('Trend calculation', () {
    test('rising value trends increasing', () {
      expect(getTrend(0.5, 0.6), BiorhythmTrend.increasing);
      expect(getTrend(-0.9, -0.8), BiorhythmTrend.increasing);
    });

    test('falling value trends decreasing', () {
      expect(getTrend(0.6, 0.5), BiorhythmTrend.decreasing);
      expect(getTrend(-0.8, -0.9), BiorhythmTrend.decreasing);
    });

    test('value in critical range trends critical regardless of direction', () {
      expect(getTrend(0.1, 0.5), BiorhythmTrend.critical);
      expect(getTrend(-0.1, -0.5), BiorhythmTrend.critical);
      expect(getTrend(0, 0), BiorhythmTrend.critical);
    });

    test('getBiorhythmPoint bundles point and trend', () {
      // Emotional peak at day 7: high point, heading down
      final BiorhythmPoint peak = Biorhythm.emotional.getBiorhythmPoint(7);
      expect(peak.biorhythm, Biorhythm.emotional);
      expect(peak.point, closeTo(1, 1e-12));
      expect(peak.trend, BiorhythmTrend.decreasing);

      // Emotional trough at day 21: low point, heading up
      final BiorhythmPoint trough = Biorhythm.emotional.getBiorhythmPoint(21);
      expect(trough.point, closeTo(-1, 1e-12));
      expect(trough.trend, BiorhythmTrend.increasing);

      // Emotional day of birth: critical zero crossing
      final BiorhythmPoint birth = Biorhythm.emotional.getBiorhythmPoint(0);
      expect(birth.point, 0);
      expect(birth.trend, BiorhythmTrend.critical);
    });
  });
}
