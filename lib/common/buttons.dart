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
        ? TextButton(onPressed: onPressed, child: Text(text))
        : FilledButton.tonal(onPressed: onPressed, child: Text(text));
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
      padding: .zero,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: .min,
        textDirection: iconAlignEnd ? .ltr : .rtl,
        children: [
          child,
          Padding(padding: .symmetric(horizontal: 8), child: icon),
        ],
      ),
    );
  } else {
    return TextButton.icon(
      label: child,
      icon: icon,
      iconAlignment: iconAlignEnd ? .end : .start,
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
      padding: .zero,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: .min,
        children: [
          child,
          // Include an ellipsis icon for iOS
          Padding(
            padding: .symmetric(horizontal: 8),
            child: Icon(CupertinoIcons.ellipsis_circle),
          ),
        ],
      ),
    );
  } else {
    return FilledButton(onPressed: onPressed, child: child);
  }
}

// Large button for modal sheet action
Widget adaptiveModalButton({
  required String text,
  Widget? icon,
  Color? color,
  required Function()? onPressed,
}) {
  return Padding(
    padding: const .symmetric(vertical: 8),
    child: Platform.isIOS
        ? CupertinoButton.filled(
            onPressed: onPressed,
            color: color,
            child: Text(text),
          )
        : TextButton.icon(icon: icon, label: Text(text), onPressed: onPressed),
  );
}
