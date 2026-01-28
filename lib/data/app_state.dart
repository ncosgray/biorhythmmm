/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    app_state.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - App state
// - Manage preferences

import 'package:biorhythmmm/common/notifications.dart';
import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:biorhythmmm/data/prefs.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart' show TimeOfDay;

class AppState {
  AppState(
    this.birthdays,
    this.selectedBirthday,
    this.compareBirthday,
    this.biorhythms,
    this.notifications,
    this.notificationTime,
    this.useAccessibleColors,
    this.showExtraPoints,
    this.showCriticalZone,
    this.showResetButton,
    this.reload,
  );

  final List<BirthdayEntry> birthdays;
  final int selectedBirthday;
  final int compareBirthday;
  final List<Biorhythm> biorhythms;
  final NotificationType notifications;
  final TimeOfDay notificationTime;
  final bool useAccessibleColors;
  final bool showExtraPoints;
  final bool showCriticalZone;
  final bool showResetButton;
  final bool reload;

  // Populate state with initial values from shared preferences
  static AppState initial() => AppState(
    Prefs.birthdays,
    Prefs.selectedBirthday,
    -1,
    Prefs.biorhythms,
    Prefs.notifications,
    Prefs.notificationTime,
    Prefs.useAccessibleColors,
    Prefs.biorhythms.length == allBiorhythms.length ? true : false,
    Prefs.showCriticalZone,
    false,
    false,
  );

  // Helper method to create a copy of the state with updated values
  AppState copyWith({
    List<BirthdayEntry>? birthdays,
    int? selectedBirthday,
    int? compareBirthday,
    List<Biorhythm>? biorhythms,
    NotificationType? notifications,
    TimeOfDay? notificationTime,
    bool? useAccessibleColors,
    bool? showExtraPoints,
    bool? showCriticalZone,
    bool? showResetButton,
    bool? reload,
  }) {
    return AppState(
      birthdays ?? this.birthdays,
      selectedBirthday ?? this.selectedBirthday,
      compareBirthday ?? this.compareBirthday,
      biorhythms ?? this.biorhythms,
      notifications ?? this.notifications,
      notificationTime ?? this.notificationTime,
      useAccessibleColors ?? this.useAccessibleColors,
      showExtraPoints ?? this.showExtraPoints,
      showCriticalZone ?? this.showCriticalZone,
      showResetButton ?? this.showResetButton,
      reload ?? this.reload,
    );
  }
}

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit() : super(AppState.initial());

  // Getters
  DateTime get birthday => state.birthdays[state.selectedBirthday].date;
  String get birthdayName => state.birthdays[state.selectedBirthday].name;
  DateTime? get compareBirthday => state.compareBirthday >= 0
      ? state.birthdays[state.compareBirthday].date
      : null;
  String? get compareBirthdayName => state.compareBirthday >= 0
      ? state.birthdays[state.compareBirthday].name
      : null;
  List<Biorhythm> get biorhythms => state.biorhythms;
  NotificationType get notifications => state.notifications;
  bool get useAccessibleColors => state.useAccessibleColors;
  bool get showExtraPoints => state.showExtraPoints;
  bool get showCriticalZone => state.showCriticalZone;
  bool get showResetButton => state.showResetButton;

  // Manage birthday
  void setBirthdays(List<BirthdayEntry> newBirthdays) {
    final int newSelectedBirthday = newBirthdays.length - 1;
    Prefs.birthdays = newBirthdays;
    Prefs.selectedBirthday = newSelectedBirthday;
    emit(
      state.copyWith(
        birthdays: newBirthdays,
        selectedBirthday: newSelectedBirthday,
      ),
    );
  }

  void addBirthday(BirthdayEntry entry) {
    final newBirthdays = List<BirthdayEntry>.from(state.birthdays)..add(entry);
    setBirthdays(newBirthdays);
  }

  void editBirthday(int index, BirthdayEntry entry) {
    List<BirthdayEntry> newBirthdays = List<BirthdayEntry>.from(
      state.birthdays,
    );
    newBirthdays[index] = entry;
    Prefs.birthdays = newBirthdays;
    emit(state.copyWith(birthdays: newBirthdays));
    updateNotifications();
  }

  void removeBirthday(int index) {
    final newBirthdays = List<BirthdayEntry>.from(state.birthdays)
      ..removeAt(index);
    int newSelectedBirthday = state.selectedBirthday;
    if (newSelectedBirthday >= newBirthdays.length) {
      newSelectedBirthday = newBirthdays.length - 1;
    }
    Prefs.birthdays = newBirthdays;
    Prefs.selectedBirthday = newSelectedBirthday;
    emit(
      state.copyWith(
        birthdays: newBirthdays,
        selectedBirthday: newSelectedBirthday,
      ),
    );
    updateNotifications();
  }

  void setSelectedBirthday(int newSelectedBirthday) {
    Prefs.selectedBirthday = newSelectedBirthday;
    emit(state.copyWith(selectedBirthday: newSelectedBirthday));
  }

  void setCompareBirthday(int newCompareBirthday) {
    emit(state.copyWith(compareBirthday: newCompareBirthday));
  }

  void clearCompareBirthday() {
    emit(state.copyWith(compareBirthday: -1));
  }

  void toggleBirthdayNotify(int index) {
    List<BirthdayEntry> newBirthdays = List<BirthdayEntry>.generate(
      state.birthdays.length,
      (i) => BirthdayEntry(
        name: state.birthdays[i].name,
        date: state.birthdays[i].date,
        notify: i == index ? true : false,
      ),
    );
    Prefs.birthdays = newBirthdays;
    emit(state.copyWith(birthdays: newBirthdays));
    updateNotifications();
  }

  // Manage biorhythms
  void addBiorhythm(Biorhythm newBiorhythm) {
    // Add biorhythm maintaining correct sort order
    Set<Biorhythm> selectedBiorhythms = Set.from(Prefs.biorhythms)
      ..add(newBiorhythm);
    List<Biorhythm> newBiorhythms = List.from(
      allBiorhythms.where((b) => selectedBiorhythms.contains(b)),
    );
    Prefs.biorhythms = newBiorhythms;
    emit(
      state.copyWith(
        biorhythms: newBiorhythms,
        showExtraPoints: newBiorhythms.length == allBiorhythms.length
            ? true
            : false,
      ),
    );
    updateNotifications();
  }

  void removeBiorhythm(Biorhythm oldBiorhythm) {
    List<Biorhythm> newBiorhythms = List.from(Prefs.biorhythms)
      ..remove(oldBiorhythm);
    Prefs.biorhythms = newBiorhythms;
    emit(state.copyWith(biorhythms: newBiorhythms, showExtraPoints: false));
    updateNotifications();
  }

  bool isBiorhythmSelected(Biorhythm b) => Prefs.biorhythms.contains(b);

  // Enable or disable notifications
  void setNotifications(NotificationType newNotifications) {
    Prefs.notifications = newNotifications;
    emit(state.copyWith(notifications: newNotifications));
    updateNotifications();
  }

  // Set notification time
  void setNotificationTime(TimeOfDay newNotificationTime) {
    Prefs.notificationTime = newNotificationTime;
    emit(state.copyWith(notificationTime: newNotificationTime));
    updateNotifications();
  }

  // Schedule or cancel notifications after a settings change
  void updateNotifications() {
    if (state.notifications == NotificationType.none) {
      Notifications.cancel();
    } else {
      // Ensure at least one birthday can generate notifications
      if (!state.birthdays.any((d) => d.notify)) {
        List<BirthdayEntry> newBirthdays = List<BirthdayEntry>.generate(
          state.birthdays.length,
          (i) => BirthdayEntry(
            name: state.birthdays[i].name,
            date: state.birthdays[i].date,
            notify: i == 0 ? true : false,
          ),
        );
        Prefs.birthdays = newBirthdays;
        emit(state.copyWith(birthdays: newBirthdays));
      }
      Notifications.schedule(state.notificationTime);
    }
  }

  // Enable or disable accessible color palette
  void setAccessibleColors(bool newUseAccessibleColors) {
    Prefs.useAccessibleColors = newUseAccessibleColors;
    emit(state.copyWith(useAccessibleColors: newUseAccessibleColors));
  }

  // Toggle extra biorhythms display
  void toggleExtraPoints() {
    bool newShowExtraPoints = !state.showExtraPoints;
    emit(
      state.copyWith(
        biorhythms: newShowExtraPoints
            ? allBiorhythms
            : (Prefs.biorhythms.length == allBiorhythms.length
                  ? primaryBiorhythms
                  : Prefs.biorhythms),
        showExtraPoints: newShowExtraPoints,
      ),
    );
  }

  // Enable or disable critical zone display
  void setCriticalZone(bool newShowCriticalZone) {
    Prefs.showCriticalZone = newShowCriticalZone;
    emit(state.copyWith(showCriticalZone: newShowCriticalZone));
  }

  // Enable reset button
  void enableResetButton() {
    if (!state.showResetButton) {
      emit(state.copyWith(showResetButton: true));
    }
  }

  // Reload request
  void reload() => emit(state.copyWith(reload: true));

  void resetReload() =>
      emit(state.copyWith(showResetButton: false, reload: false));
}
