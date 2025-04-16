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

import 'package:biorhythmmm/common/strings.dart';
import 'package:biorhythmmm/common/styles.dart';
import 'package:biorhythmmm/data/app_state.dart';

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Open a dialog box to choose user birthday
adaptiveBirthdayPicker(BuildContext context) {
  if (Platform.isIOS) {
    buildCupertinoDatePicker(context);
  } else {
    buildMaterialDatePicker(context);
  }
}

// Android date picker
buildMaterialDatePicker(BuildContext context) async {
  DateTime? picked = await showDatePicker(
    context: context,
    helpText: Str.birthdaySelectText,
    initialDate: context.read<AppStateCubit>().birthday,
    firstDate: DateTime(0),
    lastDate: DateTime(DateTime.now().year),
  );
  if (picked != null && context.mounted) {
    context.read<AppStateCubit>().setBirthday(picked);
  }
}

// Cupertino date picker
buildCupertinoDatePicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).canvasColor,
    builder: (_) {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 3,
        child: Stack(
          children: [
            // Help text overlay
            Padding(
              padding: EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(Str.birthdaySelectText, style: titleText),
              ),
            ),
            // Date picker
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged:
                    (picked) =>
                        context.read<AppStateCubit>().setBirthday(picked),
                initialDateTime: context.read<AppStateCubit>().birthday,
                maximumYear: DateTime.now().year,
              ),
            ),
          ],
        ),
      );
    },
  );
}
