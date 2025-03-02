/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    adaptive.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Platform aware widgets
// - Dialog action, text button, list tile

import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Dialog action button appropriate to platform
Widget adaptiveDialogAction({
  bool isDefaultAction = false,
  bool isDestructiveAction = false,
  required String text,
  required Function()? onPressed,
}) {
  if (Platform.isIOS) {
    return CupertinoDialogAction(
      isDefaultAction: isDefaultAction,
      isDestructiveAction: isDestructiveAction,
      onPressed: onPressed,
      child: Text(text),
    );
  } else {
    return isDestructiveAction
        ? TextButton(
            onPressed: onPressed,
            child: Text(text),
          )
        : FilledButton.tonal(
            onPressed: onPressed,
            child: Text(text),
          );
  }
}

// Button with styling appropriate to platform
Widget adaptiveButton({
  required Widget child,
  required Function()? onPressed,
}) {
  if (Platform.isIOS) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: child,
    );
  } else {
    return FilledButton(
      onPressed: onPressed,
      child: child,
    );
  }
}

// List tile with styling appropriate to platform
Widget adaptiveListTile({
  required Widget title,
  required Widget trailing,
}) {
  if (Platform.isIOS) {
    return CupertinoListTile(
      title: title,
      trailing: trailing,
    );
  } else {
    return ListTile(
      title: title,
      trailing: trailing,
    );
  }
}
