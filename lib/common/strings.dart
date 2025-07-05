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
  static String get aboutAdditional => 'Additional cycles include ';
  static String get aboutAestheticDays =>
      ' (${Biorhythm.aesthetic.cycleDays} days), ';
  static String get aboutApp => '${Str.appName} is a free, open-source app';
  static String get aboutAwarenessDays =>
      ' (${Biorhythm.awareness.cycleDays} days), and ';
  static String get aboutCopyright => '\u00a9 Nathan Cosgray';
  static String get aboutCycles =>
      'Biorhythms are natural cycles that influence the states of our minds and bodies. The three primary cycles are:';
  static String get aboutEmotionalBullet => '\u2022 ${Str.biorhythmEmotional}';
  static String get aboutEmotionalText =>
      ' cycle governing mood and emotional stability (${Biorhythm.emotional.cycleDays} days)';
  static String get aboutIntellectualBullet =>
      '\u2022 ${Str.biorhythmIntellectual}';
  static String get aboutIntellectualText =>
      ' cycle influencing mental clarity and concentration (${Biorhythm.intellectual.cycleDays} days)';
  static String get aboutIntutionDays =>
      ' (${Biorhythm.intuition.cycleDays} days), ';
  static String get aboutPhases =>
      'Each cycle moves through high, low, and \u26A0critical\u26A0 phases. During the critical phase a cycle crosses from high to low or from low to high. It is at this time \u2014 when the body and mind are out of sync \u2014 that individuals may experience a higher likelihood of stress, accidents, or mistakes.';
  static String get aboutPhysicalBullet => '\u2022 ${Str.biorhythmPhysical}';
  static String get aboutPhysicalText =>
      ' cycle affecting strength and energy (${Biorhythm.physical.cycleDays} days)';
  static String get aboutSpiritualDays =>
      ' (${Biorhythm.spiritual.cycleDays} days).';
  static String get aboutTitle => 'About biorhythms';
  static String get appName => 'Biorhythmmm';
  static String get biorhythmAesthetic => 'Aesthetic';
  static String get biorhythmAwareness => 'Awareness';
  static String get biorhythmEmotional => 'Emotional';
  static String get biorhythmIntellectual => 'Intellectual';
  static String get biorhythmIntuition => 'Intuition';
  static String get biorhythmPhysical => 'Physical';
  static String get biorhythmSpiritual => 'Spiritual';
  static String get birthdayAddLabel => 'Add birthday';
  static String get birthdayDefaultName => 'Me';
  static String get birthdayEditLabel => 'Edit birthday';
  static String get birthdayManageLabel => 'Manage birthdays';
  static String get birthdayNameLabel => 'Name';
  static String get cancelLabel => 'Cancel';
  static String get chartTitle => 'Today\u2019s Biorhythms';
  static String get dateNoneLabel => 'No date selected';
  static String get dateSelectLabel => 'Select date';
  static String get deleteLabel => 'Delete';
  static String get doneLabel => 'Done';
  static String get editLabel => 'Edit';
  static String get manageLabel => 'Manage...';
  static String get notificationsLabel => 'Biorhythm alerts';
  static String get notificationTypeCritical => 'Critical days';
  static String get notificationTypeDaily => 'Every day';
  static String get notificationTypeNone => 'Never';
  static String get notifyChannelName => 'Biorhythm alerts';
  static String get notifyCriticalPrefix => 'Critical: ';
  static String get notifyForPrefix => ' for ';
  static String get notifyTitle => "Today's Biorhythms";
  static String get okLabel => 'OK';
  static String get otherSettingsTitle => 'Other settings';
  static String get resetLabel => 'Reset';
  static String get selectBiorhythmsTitle => 'Select biorhythms';
  static String get settingsTitle => 'Settings';
  static String get showCriticalZoneLabel => 'Show critical zone on graph';
  static String get todayLabel => 'Today';
  static String get toggleExtraLabel => 'View';
  static String get useAccessibleColorsLabel => 'Colorblind safe palette';
}
