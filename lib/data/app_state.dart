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

import 'package:biorhythmmm/data/biorhythm.dart';
import 'package:biorhythmmm/data/prefs.dart';

import 'package:bloc/bloc.dart';

class AppState {
  AppState(
    this.birthday,
    this.biorhythms,
    this.showExtraPoints,
    this.showResetButton,
    this.reload,
  );

  final DateTime birthday;
  final List<Biorhythm> biorhythms;
  final bool showExtraPoints;
  final bool showResetButton;
  final bool reload;

  // Populate state with initial values from shared preferences
  static AppState initial() => AppState(
        Prefs.birthday,
        Prefs.biorhythms,
        Prefs.biorhythms.length == allBiorhythms.length ? true : false,
        false,
        false,
      );
}

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit() : super(AppState.initial());

  // Getters
  DateTime get birthday => state.birthday;
  List<Biorhythm> get biorhythms => state.biorhythms;
  bool get showExtraPoints => state.showExtraPoints;
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
        state.showExtraPoints,
        state.showResetButton,
        state.reload,
      ),
    );
  }

  // Manage biorhythms
  void addBiorhythm(Biorhythm newBiorhythm) {
    // Add biorthyhm maintaining correct sort order
    Set<Biorhythm> selectedBiorhythms = Set.from(Prefs.biorhythms)
      ..add(newBiorhythm);
    List<Biorhythm> newBiorhythms =
        List.from(allBiorhythms.where((b) => selectedBiorhythms.contains(b)));
    Prefs.biorhythms = newBiorhythms;
    emit(
      AppState(
        state.birthday,
        newBiorhythms,
        newBiorhythms.length == allBiorhythms.length ? true : false,
        state.showResetButton,
        state.reload,
      ),
    );
  }

  void removeBiorhythm(Biorhythm oldBiorhythm) {
    List<Biorhythm> newBiorhythms = List.from(Prefs.biorhythms)
      ..remove(oldBiorhythm);
    Prefs.biorhythms = newBiorhythms;
    emit(
      AppState(
        state.birthday,
        newBiorhythms,
        false,
        state.showResetButton,
        state.reload,
      ),
    );
  }

  bool isBiorhythmSelected(Biorhythm b) => Prefs.biorhythms.contains(b);

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
        newShowExtraPoints,
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
          state.showExtraPoints,
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
          state.showExtraPoints,
          state.showResetButton,
          true,
        ),
      );

  void resetReload() => emit(
        AppState(
          state.birthday,
          state.biorhythms,
          state.showExtraPoints,
          false,
          false,
        ),
      );
}
