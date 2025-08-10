/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    time_picker.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Platform aware notification time picker

import 'dart:io' show Platform;

import 'package:biorhythmmm/common/strings.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Open a dialog box to choose time
Future<TimeOfDay?> adaptiveTimePicker(
  BuildContext context, {
  TimeOfDay? initialTime,
  String? helpText,
}) async {
  if (Platform.isIOS) {
    return await buildCupertinoDatePicker(context, initialTime: initialTime);
  } else {
    return await buildMaterialDatePicker(
      context,
      initialTime: initialTime,
      helpText: helpText,
    );
  }
}

// Android time picker
Future<TimeOfDay?> buildMaterialDatePicker(
  BuildContext context, {
  TimeOfDay? initialTime,
  String? helpText,
}) async {
  return await showTimePicker(
    context: context,
    helpText: helpText,
    initialTime: initialTime ?? TimeOfDay.now(),
  );
}

// Cupertino time picker
Future<TimeOfDay?> buildCupertinoDatePicker(
  BuildContext context, {
  TimeOfDay? initialTime,
}) async {
  // CupertinoDatePicker requires a DateTime, so we need to convert
  DateTime initialDate = DateTime(
    1969,
    1,
    1,
    initialTime?.hour ?? TimeOfDay.now().hour,
    initialTime?.minute ?? TimeOfDay.now().minute,
  );
  DateTime? tempPicked = initialDate;
  DateTime? result = await showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Theme.of(context).canvasColor,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 3.5 - 40,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialDate,
                  onDateTimeChanged: (picked) {
                    setState(() {
                      tempPicked = picked;
                    });
                  },
                ),
              ),
              SafeArea(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  sizeStyle: CupertinoButtonSize.medium,
                  child: Text(Str.doneLabel),
                  onPressed: () {
                    Navigator.of(context).pop(tempPicked);
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
  return TimeOfDay.fromDateTime(result ?? initialDate);
}
