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
// - Sheet app bar, dialog action, text button

import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Sheet app bar with behavior appropriate to platform
PreferredSizeWidget adaptiveSheetAppBar({
  required BuildContext context,
  required String title,
  required String dismissLabel,
}) {
  return AppBar(
    automaticallyImplyLeading: Platform.isIOS ? false : true,
    title: Text(title),
    actions: Platform.isIOS
        ? [
            // Dismiss button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: adaptiveButton(
                child: Text(dismissLabel),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ]
        : null,
  );
}

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
