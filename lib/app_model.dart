/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    app_model.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - App service locator model
// - Manage preferences

import 'package:biorhythmmm/biorhythm.dart';
import 'package:biorhythmmm/prefs.dart';

import 'package:flutter/material.dart';

abstract class AppModel extends ChangeNotifier {
  // Birthday
  DateTime get birthday;
  set birthday(DateTime newValue);
  bool get isBirthdaySet;

  // Biorthyhm points
  bool get showExtraPoints;
  void toggleExtraPoints();
  List<Biorhythm> get biorhythms;
}

class AppModelImplementation extends AppModel {
  AppModelImplementation();

  // Birthday
  DateTime _birthday = Prefs.birthday;

  @override
  DateTime get birthday => _birthday;

  @override
  set birthday(DateTime newValue) {
    _birthday = newValue;
    Prefs.birthday = _birthday;
    notifyListeners();
  }

  @override
  bool get isBirthdaySet => Prefs.isBirthdaySet;

  // Biorthyhm points
  bool _showExtraPoints = Prefs.showExtraPoints;

  @override
  bool get showExtraPoints => _showExtraPoints;

  @override
  toggleExtraPoints() {
    _showExtraPoints = !_showExtraPoints;
    Prefs.showExtraPoints = _showExtraPoints;
    notifyListeners();
  }

  @override
  List<Biorhythm> get biorhythms => _showExtraPoints
      ? Biorhythm.values.toList()
      : Biorhythm.values.where((b) => b.primary).toList();
}
