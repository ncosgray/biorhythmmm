/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    strings.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - UI strings

import 'package:biorhythmmm/data/biorhythm.dart';

class Str {
  static String get appName => 'Biorhythmmm';
  static String get biorhythmIntellectual => 'Intellectual';
  static String get biorhythmEmotional => 'Emotional';
  static String get biorhythmPhysical => 'Physical';
  static String get biorhythmIntuition => 'Intuition';
  static String get biorhythmAesthetic => 'Aesthetic';
  static String get biorhythmAwareness => 'Awareness';
  static String get biorhythmSpiritual => 'Spiritual';
  static String get birthdayLabel => 'DOB:';
  static String get birthdaySelectText => 'When were you born?';
  static String get resetLabel => 'Reset';
  static String get todayLabel => 'Today';
  static String get toggleExtraLabel => 'View';
  static String get aboutTitle => 'About Biorhythms';
  static String get aboutCycles =>
      'Biorhythms are natural cycles that influence the states of our minds and bodies. The three primary cycles are:';
  static String get aboutIntellectualBullet =>
      '\u2022 ${Str.biorhythmIntellectual}';
  static String get aboutIntellectualText =>
      ' cycle influencing mental clarity and concentration (${Biorhythm.intellectual.cycleDays} days)';
  static String get aboutEmotionalBullet => '\u2022 ${Str.biorhythmEmotional}';
  static String get aboutEmotionalText =>
      ' cycle governing mood and emotional stability (${Biorhythm.emotional.cycleDays} days)';
  static String get aboutPhysicalBullet => '\u2022 ${Str.biorhythmPhysical}';
  static String get aboutPhysicalText =>
      ' cycle affecting strength and energy (${Biorhythm.physical.cycleDays} days)';
  static String get aboutAdditional => 'Additional cycles include ';
  static String get aboutIntutionDays =>
      ' (${Biorhythm.intuition.cycleDays} days), ';
  static String get aboutAestheticDays =>
      ' (${Biorhythm.aesthetic.cycleDays} days), ';
  static String get aboutAwarenessDays =>
      ' (${Biorhythm.awareness.cycleDays} days), and ';
  static String get aboutSpiritualDays =>
      ' (${Biorhythm.spiritual.cycleDays} days).';
  static String get aboutPhases =>
      'Each cycle moves through \u2191 high, \u2193 low, and \u26A0 critical phases. During the critical phase a cycle crosses from high to low or from low to high. It is at this time \u2014 when the body and mind are out of sync \u2014 that individuals may experience a higher likelihood of stress, accidents, or mistakes.';
  static String get aboutApp => '${Str.appName} is a free, open-source app';
  static String get aboutCopyright => '\u00a9 Nathan Cosgray';
  static String get okLabel => 'OK';
}
