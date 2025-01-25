/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    home_page.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - App home page

import 'package:biorhythmmm/app_state.dart';
import 'package:biorhythmmm/helpers.dart';
import 'package:biorhythmmm/strings.dart';
import 'package:biorhythmmm/styles.dart';
import 'package:biorhythmmm/widgets/about_text.dart';
import 'package:biorhythmmm/widgets/biorhythm_chart.dart';

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        // Prompt user once if birthday is unset
        if (context.mounted && !context.read<AppStateCubit>().isBirthdaySet) {
          context.read<AppStateCubit>().saveBirthday();
          adaptiveBirthdayPicker(context);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(Str.appName),
        // About button
        leading: IconButton(
          icon: Icon(helpIcon),
          onPressed: () => showAboutDialog(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Reset button
                BlocSelector<AppStateCubit, AppState, bool>(
                  selector: (state) => state.showResetButton,
                  builder: (context, showResetButton) => Visibility.maintain(
                    visible: showResetButton,
                    child: TextButton.icon(
                      onPressed: () => context.read<AppStateCubit>().reload(),
                      label: Text(
                        Str.resetLabel,
                        style: labelText,
                      ),
                      icon: Icon(todayIcon, size: labelText.fontSize),
                      iconAlignment: IconAlignment.start,
                    ),
                  ),
                ),
                // Birthday setting
                BlocSelector<AppStateCubit, AppState, DateTime>(
                  selector: (state) => state.birthday,
                  builder: (context, birthday) => TextButton.icon(
                    onPressed: () => adaptiveBirthdayPicker(context),
                    label: Text(
                      '${Str.birthdayLabel} ${longDate(birthday)}',
                      style: labelText,
                    ),
                    icon: Icon(editIcon, size: labelText.fontSize),
                    iconAlignment: IconAlignment.end,
                  ),
                ),
                // Toggle extra biorhythms
                BlocSelector<AppStateCubit, AppState, bool>(
                  selector: (state) => state.showExtraPoints,
                  builder: (context, showExtraPoints) => TextButton.icon(
                    onPressed: () =>
                        context.read<AppStateCubit>().toggleExtraPoints(),
                    label: Text(
                      Str.toggleExtraLabel,
                      style: labelText,
                    ),
                    icon: Icon(
                      showExtraPoints ? visibleIcon : invisibleIcon,
                      size: labelText.fontSize,
                    ),
                    iconAlignment: IconAlignment.end,
                  ),
                ),
              ],
            ),
            // Chart
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: BiorhythmChart(),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  child: Text(
                    Str.birthdaySelectText,
                    style: titleText,
                  ),
                ),
              ),
              // Date picker
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (picked) =>
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

  // About Biorhythms dialog
  Future<void> showAboutDialog(BuildContext context) {
    return showAdaptiveDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (_, setDialogState) {
            return AlertDialog.adaptive(
              // About Biorthythms
              title: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(Str.aboutTitle),
              ),
              content: SingleChildScrollView(
                child: aboutText(
                  textColor: Theme.of(context).textTheme.bodyMedium!.color!,
                ),
              ),
              actions: [
                // Dismiss dialog button
                adaptiveDialogAction(
                  text: Str.okLabel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
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
}

// Platform aware icons
IconData get helpIcon =>
    Platform.isIOS ? CupertinoIcons.question_circle : Icons.help_outline;

IconData get todayIcon =>
    Platform.isIOS ? CupertinoIcons.calendar_today : Icons.calendar_today;

IconData get editIcon =>
    Platform.isIOS ? CupertinoIcons.square_pencil_fill : Icons.edit;

IconData get visibleIcon =>
    Platform.isIOS ? CupertinoIcons.eye : Icons.visibility;

IconData get invisibleIcon =>
    Platform.isIOS ? CupertinoIcons.eye_slash : Icons.visibility_off;
