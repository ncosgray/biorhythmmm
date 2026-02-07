/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    modals.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Adaptive modals for different platforms

import 'package:biorhythmmm/common/styles.dart';
import 'package:biorhythmmm/data/localization.dart';

import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Open a modal adapted to the current platform
Future<void> showModal(BuildContext context, Widget builder) async {
  if (Platform.isIOS) {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).canvasColor,
      builder: (_) => builder,
    );
  } else {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => builder,
    );
  }
}

// Adaptive modal sheet header
Widget sheetHeader(BuildContext context, {required String title}) {
  return Padding(
    padding: const EdgeInsets.only(left: 12, top: 12, right: 12),
    child: ListTile(
      title: Text(title, style: listTitleText(context)),
      trailing: Platform.isIOS
          ? CupertinoButton(
              padding: EdgeInsets.zero,
              child: Text(AppString.doneLabel.translate()),
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.close),
              tooltip: AppString.doneLabel.translate(),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
    ),
  );
}
