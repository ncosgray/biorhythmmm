/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    birthday_picker.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Platform aware date picker

import 'package:biorhythmmm/data/localization.dart';

import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Open a dialog box to choose user birthday
Future<DateTime?> adaptiveBirthdayPicker(
  BuildContext context, {
  DateTime? initialDate,
}) async {
  if (Platform.isIOS) {
    return await buildCupertinoDatePicker(context, initialDate: initialDate);
  } else {
    return await buildMaterialDatePicker(context, initialDate: initialDate);
  }
}

// Android date picker
Future<DateTime?> buildMaterialDatePicker(
  BuildContext context, {
  DateTime? initialDate,
}) async {
  return await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(1900),
    lastDate: DateTime(DateTime.now().year, 12, 31),
  );
}

// Cupertino date picker
Future<DateTime?> buildCupertinoDatePicker(
  BuildContext context, {
  DateTime? initialDate,
}) async {
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
                height: MediaQuery.of(context).size.height / 3 - 40,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate ?? DateTime.now(),
                  maximumDate: DateTime.now(),
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
                  child: Text(AppString.doneLabel.translate()),
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
  return result;
}
