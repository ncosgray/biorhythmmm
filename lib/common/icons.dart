/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    icons.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Platform aware icons

import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Icon get chevronIcon => Platform.isIOS
    ? Icon(CupertinoIcons.chevron_right, color: CupertinoColors.systemBlue)
    : Icon(Icons.chevron_right);

IconData get helpIcon =>
    Platform.isIOS ? CupertinoIcons.question_circle : Icons.help_outline;

IconData get settingsIcon =>
    Platform.isIOS ? CupertinoIcons.settings : Icons.settings;

IconData get todayIcon =>
    Platform.isIOS ? CupertinoIcons.calendar_today : Icons.calendar_today;

IconData get editIcon =>
    Platform.isIOS ? CupertinoIcons.square_pencil_fill : Icons.edit;

IconData get deleteIcon =>
    Platform.isIOS ? CupertinoIcons.trash : Icons.delete_outline;

IconData get notifyOnIcon =>
    Platform.isIOS ? CupertinoIcons.bell_fill : Icons.notifications_active;

IconData get notifyOffIcon => Platform.isIOS
    ? CupertinoIcons.bell_slash
    : Icons.notifications_off_outlined;

IconData get visibleIcon =>
    Platform.isIOS ? CupertinoIcons.eye : Icons.visibility;

IconData get invisibleIcon =>
    Platform.isIOS ? CupertinoIcons.eye_slash : Icons.visibility_off;
