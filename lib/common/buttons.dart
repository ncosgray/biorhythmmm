/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    buttons.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Platform aware buttons

import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Dialog action button with styling appropriate to platform
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

// Icon button with styling appropriate to platform
Widget adaptiveIconButton({
  required Widget child,
  required Widget icon,
  bool iconAlignEnd = false,
  required Function()? onPressed,
}) {
  if (Platform.isIOS) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: iconAlignEnd ? TextDirection.ltr : TextDirection.rtl,
        children: [
          child,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: icon,
          ),
        ],
      ),
    );
  } else {
    return TextButton.icon(
      label: child,
      icon: icon,
      iconAlignment: iconAlignEnd ? IconAlignment.end : IconAlignment.start,
      onPressed: onPressed,
    );
  }
}

// Setting button with styling appropriate to platform
Widget adaptiveSettingButton({
  required Widget child,
  required Function()? onPressed,
}) {
  if (Platform.isIOS) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          // Include an ellipsis icon for iOS
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(CupertinoIcons.ellipsis_circle),
          ),
        ],
      ),
    );
  } else {
    return FilledButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
