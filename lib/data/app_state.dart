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
    this.birthday,
    this.biorhythms,
    this.notifications,
    this.showExtraPoints,
    this.showCriticalZone,
    this.showResetButton,
    this.reload,
  );

  final DateTime birthday;
  final List<Biorhythm> biorhythms;
  final NotificationType notifications;
  final bool showExtraPoints;
  final bool showCriticalZone;
  final bool showResetButton;
  final bool reload;

  // Populate state with initial values from shared preferences
  static AppState initial() => AppState(
    Prefs.birthday,
    Prefs.biorhythms,
    Prefs.notifications,
    Prefs.biorhythms.length == allBiorhythms.length ? true : false,
    Prefs.showCriticalZone,
    false,
    false,
  );
}

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit() : super(AppState.initial());

  // Getters
  DateTime get birthday => state.birthday;
  List<Biorhythm> get biorhythms => state.biorhythms;
  NotificationType get notifications => state.notifications;
  bool get showExtraPoints => state.showExtraPoints;
  bool get showCriticalZone => state.showCriticalZone;
  bool get showResetButton => state.showResetButton;

  // Manage birthday
  saveBirthday() => Prefs.birthday = state.birthday;
  bool get isBirthdaySet => Prefs.isBirthdaySet;

  void setBirthday(DateTime newBirthday) {
    Prefs.birthday = newBirthday;
    emit(
      AppState(
        newBirthday,
        state.biorhythms,
        state.notifications,
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
    // Add biorthyhm maintaining correct sort order
    Set<Biorhythm> selectedBiorhythms = Set.from(Prefs.biorhythms)
      ..add(newBiorhythm);
    List<Biorhythm> newBiorhythms = List.from(
      allBiorhythms.where((b) => selectedBiorhythms.contains(b)),
    );
    Prefs.biorhythms = newBiorhythms;
    emit(
      AppState(
        state.birthday,
        newBiorhythms,
        state.notifications,
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
        state.birthday,
        newBiorhythms,
        state.notifications,
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
        state.birthday,
        state.biorhythms,
        newNotifications,
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

  // Toggle extra biorhythms display
  void toggleExtraPoints() {
    bool newShowExtraPoints = !state.showExtraPoints;
    emit(
      AppState(
        state.birthday,
        newShowExtraPoints
            ? allBiorhythms
            : (Prefs.biorhythms.length == allBiorhythms.length
                ? primaryBiorhythms
                : Prefs.biorhythms),
        state.notifications,
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
        state.birthday,
        state.biorhythms,
        state.notifications,
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
          state.birthday,
          state.biorhythms,
          state.notifications,
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
      state.birthday,
      state.biorhythms,
      state.notifications,
      state.showExtraPoints,
      state.showCriticalZone,
      state.showResetButton,
      true,
    ),
  );

  void resetReload() => emit(
    AppState(
      state.birthday,
      state.biorhythms,
      state.notifications,
      state.showExtraPoints,
      state.showCriticalZone,
      false,
      false,
    ),
  );
}
