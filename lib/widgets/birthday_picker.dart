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

import 'dart:io' show Platform;

import 'package:biorhythmmm/common/strings.dart';
import 'package:biorhythmmm/common/styles.dart';

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
    helpText: Str.birthdaySelectText,
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
              Padding(
                padding: EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(Str.birthdaySelectText, style: titleText),
                ),
              ),
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
              Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: CupertinoButton(
                  sizeStyle: CupertinoButtonSize.large,
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
  return result;
}
