/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    compare_manager.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Compare biorhythms manager widget

import 'package:biorhythmmm/common/buttons.dart';
import 'package:biorhythmmm/common/modals.dart';
import 'package:biorhythmmm/common/styles.dart';
import 'package:biorhythmmm/data/app_state.dart';
import 'package:biorhythmmm/data/localization.dart';
import 'package:biorhythmmm/data/prefs.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Open a modal to select a birthday to compare
Future<void> showCompareModal(BuildContext context) async {
  await showModal(context, const CompareManagerSheet());
}

// Compare modal sheet
class CompareManagerSheet extends StatelessWidget {
  const CompareManagerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: padding.bottom),
      child: SafeArea(
        child: BlocBuilder<AppStateCubit, AppState>(
          builder: (context, state) {
            final birthdays = state.birthdays;
            final selected = state.selectedBirthday;
            final compare = state.compareBirthday;

            // Size the sheet based on the number of birthdays
            return SizedBox(
              height: (birthdays.length - 1) * 55 + 160,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // Build a birthday manager
                children: [
                  sheetHeader(
                    context,
                    title: AppString.compareManageLabel.translate(),
                  ),
                  // List of birthdays to compare with
                  compareList(birthdays, compare, selected),
                  // Clear comparison button
                  if (compare != -1)
                    adaptiveModalButton(
                      text: AppString.compareClear.translate(),
                      icon: Icon(Icons.backspace),
                      color: Colors.red,
                      onPressed: () async {
                        context.read<AppStateCubit>().clearCompareBirthday();
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // List of birthdays to compare with
  Expanded compareList(
    List<BirthdayEntry> birthdays,
    int compare,
    int selected,
  ) {
    // Name of the selected birthday
    final String compareName = selected >= 0 && selected < birthdays.length
        ? birthdays[selected].name
        : AppString.birthdayDefaultName.translate();

    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: ListView.builder(
          itemCount: birthdays.length + (compare != -1 ? 1 : 0),
          itemBuilder: (context, index) {
            // Skip the currently selected birthday
            int birthdayIndex = index;
            if (index >= selected) {
              birthdayIndex = index + 1;
            }
            if (birthdayIndex >= birthdays.length) {
              return const SizedBox.shrink();
            }

            // Build each birthday entry
            final entry = birthdays[birthdayIndex];
            return ListTile(
              leading: Icon(
                birthdayIndex == compare
                    ? Icons.check_circle
                    : Icons.circle_outlined,
              ),
              title: Row(
                spacing: 8,
                children: [
                  Text(compareName, style: listTileText(context)),
                  Icon(Icons.sync_alt),
                  Text(entry.name, style: listTileText(context)),
                ],
              ),
              onTap: () {
                context.read<AppStateCubit>().setCompareBirthday(birthdayIndex);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }
}
