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

class AppState {
  AppState(
    this.birthdays,
    this.selectedBirthday,
    this.biorhythms,
    this.notifications,
    this.useAccessibleColors,
    this.showExtraPoints,
    this.showCriticalZone,
    this.showResetButton,
    this.reload,
  );

  final List<BirthdayEntry> birthdays;
  final int selectedBirthday;
  final List<Biorhythm> biorhythms;
  final NotificationType notifications;
  final bool useAccessibleColors;
  final bool showExtraPoints;
  final bool showCriticalZone;
  final bool showResetButton;
  final bool reload;

  // Populate state with initial values from shared preferences
  static AppState initial() => AppState(
    Prefs.birthdays,
    Prefs.selectedBirthday,
    Prefs.biorhythms,
    Prefs.notifications,
    Prefs.useAccessibleColors,
    Prefs.biorhythms.length == allBiorhythms.length ? true : false,
    Prefs.showCriticalZone,
    false,
    false,
  );
}

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit() : super(AppState.initial());

  // Getters
  DateTime get birthday => state.birthdays[state.selectedBirthday].date;
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
      AppState(
        newBirthdays,
        newSelectedBirthday,
        state.biorhythms,
        state.notifications,
        state.useAccessibleColors,
        state.showExtraPoints,
        state.showCriticalZone,
        state.showResetButton,
        state.reload,
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
    emit(
      AppState(
        newBirthdays,
        state.selectedBirthday,
        state.biorhythms,
        state.notifications,
        state.useAccessibleColors,
        state.showExtraPoints,
        state.showCriticalZone,
        state.showResetButton,
        state.reload,
      ),
    );
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
      AppState(
        newBirthdays,
        newSelectedBirthday,
        state.biorhythms,
        state.notifications,
        state.useAccessibleColors,
        state.showExtraPoints,
        state.showCriticalZone,
        state.showResetButton,
        state.reload,
      ),
    );
  }

  void setSelectedBirthday(int newSelectedBirthday) {
    Prefs.selectedBirthday = newSelectedBirthday;
    emit(
      AppState(
        state.birthdays,
        newSelectedBirthday,
        state.biorhythms,
        state.notifications,
        state.useAccessibleColors,
        state.showExtraPoints,
        state.showCriticalZone,
        state.showResetButton,
        state.reload,
      ),
    );
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
      AppState(
        state.birthdays,
        state.selectedBirthday,
        newBiorhythms,
        state.notifications,
        state.useAccessibleColors,
        newBiorhythms.length == allBiorhythms.length ? true : false,
        state.showCriticalZone,
        state.showResetButton,
        state.reload,
      ),
    );
    updateNotifications();
  }

  void removeBiorhythm(Biorhythm oldBiorhythm) {
    List<Biorhythm> newBiorhythms = List.from(Prefs.biorhythms)
      ..remove(oldBiorhythm);
    Prefs.biorhythms = newBiorhythms;
    emit(
      AppState(
        state.birthdays,
        state.selectedBirthday,
        newBiorhythms,
        state.notifications,
        state.useAccessibleColors,
        false,
        state.showCriticalZone,
        state.showResetButton,
        state.reload,
      ),
    );
    updateNotifications();
  }

  bool isBiorhythmSelected(Biorhythm b) => Prefs.biorhythms.contains(b);

  // Enable or disable notifications
  void setNotifications(NotificationType newNotifications) {
    Prefs.notifications = newNotifications;
    emit(
      AppState(
        state.birthdays,
        state.selectedBirthday,
        state.biorhythms,
        newNotifications,
        state.useAccessibleColors,
        state.showExtraPoints,
        state.showCriticalZone,
        state.showResetButton,
        state.reload,
      ),
    );
    updateNotifications();
  }

  // Schedule or cancel notifications after a settings change
  void updateNotifications() {
    if (state.notifications == NotificationType.none) {
      Notifications.cancel();
    } else {
      Notifications.schedule();
    }
  }

  // Enable or disable accessible color palette
  void setAccessibleColors(bool newUseAccessibleColors) {
    Prefs.useAccessibleColors = newUseAccessibleColors;
    emit(
      AppState(
        state.birthdays,
        state.selectedBirthday,
        state.biorhythms,
        state.notifications,
        newUseAccessibleColors,
        state.showExtraPoints,
        state.showCriticalZone,
        state.showResetButton,
        state.reload,
      ),
    );
  }

  // Toggle extra biorhythms display
  void toggleExtraPoints() {
    bool newShowExtraPoints = !state.showExtraPoints;
    emit(
      AppState(
        state.birthdays,
        state.selectedBirthday,
        newShowExtraPoints
            ? allBiorhythms
            : (Prefs.biorhythms.length == allBiorhythms.length
                  ? primaryBiorhythms
                  : Prefs.biorhythms),
        state.notifications,
        state.useAccessibleColors,
        newShowExtraPoints,
        state.showCriticalZone,
        state.showResetButton,
        state.reload,
      ),
    );
  }

  // Enable or disable critical zone display
  void setCriticalZone(bool newShowCriticalZone) {
    Prefs.showCriticalZone = newShowCriticalZone;
    emit(
      AppState(
        state.birthdays,
        state.selectedBirthday,
        state.biorhythms,
        state.notifications,
        state.useAccessibleColors,
        state.showExtraPoints,
        newShowCriticalZone,
        state.showResetButton,
        state.reload,
      ),
    );
  }

  // Enable reset button
  void enableResetButton() {
    if (!state.showResetButton) {
      emit(
        AppState(
          state.birthdays,
          state.selectedBirthday,
          state.biorhythms,
          state.notifications,
          state.useAccessibleColors,
          state.showExtraPoints,
          state.showCriticalZone,
          true,
          state.reload,
        ),
      );
    }
  }

  // Reload request
  void reload() => emit(
    AppState(
      state.birthdays,
      state.selectedBirthday,
      state.biorhythms,
      state.notifications,
      state.useAccessibleColors,
      state.showExtraPoints,
      state.showCriticalZone,
      state.showResetButton,
      true,
    ),
  );

  void resetReload() => emit(
    AppState(
      state.birthdays,
      state.selectedBirthday,
      state.biorhythms,
      state.notifications,
      state.useAccessibleColors,
      state.showExtraPoints,
      state.showCriticalZone,
      false,
      false,
    ),
  );
}
