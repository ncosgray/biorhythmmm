/*
 *******************************************************************************
 Package:  biorhythmmm
 Class:    birthday_manager.dart
 Author:   Nathan Cosgray | https://www.nathanatos.com
 -------------------------------------------------------------------------------
 Copyright (c) 2024 Nathan Cosgray. All rights reserved.

 This source code is licensed under the BSD-style license found in LICENSE.txt.
 *******************************************************************************
*/

// Biorhythmmm
// - Birthday management widget

import 'dart:io' show Platform;

import 'package:biorhythmmm/common/helpers.dart';
import 'package:biorhythmmm/common/icons.dart';
import 'package:biorhythmmm/common/notifications.dart' show NotificationType;
import 'package:biorhythmmm/common/strings.dart';
import 'package:biorhythmmm/common/styles.dart';
import 'package:biorhythmmm/data/prefs.dart';
import 'package:biorhythmmm/data/app_state.dart';
import 'package:biorhythmmm/widgets/birthday_picker.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_bloc/flutter_bloc.dart';

const int birthdayNameMaxLength = 25;

// Open a modal to add, edit, or delete user birthdays
Future<void> showBirthdayManager(BuildContext context) async {
  if (Platform.isIOS) {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).canvasColor,
      builder: (_) => const BirthdayManagerSheet(),
    );
  } else {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const BirthdayManagerSheet(),
    );
  }
}

// Platform-specific birthday manager sheet
class BirthdayManagerSheet extends StatelessWidget {
  const BirthdayManagerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: padding.bottom),
      child: SafeArea(
        child: BlocBuilder<AppStateCubit, AppState>(
          builder: (context, state) {
            final birthdays = state.birthdays;
            final bool notify = state.notifications != NotificationType.none;
            // Size the sheet based on the number of birthdays
            return SizedBox(
              height: birthdays.length * 65 + 180,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Build a birthday manager
                  sheetHeader(context),
                  birthdayList(birthdays: birthdays, notify: notify),
                  addBirthday(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Platform-specific header for the birthday manager sheet
  Widget sheetHeader(BuildContext context) {
    return Platform.isIOS
        ? Padding(
            padding: const EdgeInsets.only(top: 12, left: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    Str.birthdayManageLabel,
                    style: listTileText(context),
                  ),
                ),
                CupertinoButton(
                  child: Text(Str.doneLabel),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(left: 12, top: 12, right: 12),
            child: ListTile(
              title: Text(
                Str.birthdayManageLabel,
                style: listTileText(context),
              ),
              trailing: IconButton(
                icon: Icon(Icons.close),
                tooltip: Str.doneLabel,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          );
  }

  // List of birthday tiles
  Widget birthdayList({
    required List<BirthdayEntry> birthdays,
    required bool notify,
  }) {
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: ListView.separated(
          itemCount: birthdays.length,
          separatorBuilder: (_, _) => Divider(height: 1),
          itemBuilder: (context, i) {
            final entry = birthdays[i];
            // Birthday entry
            return ListTile(
              leading: Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(Icons.cake_outlined),
              ),
              title: Text(entry.name, style: listTileText(context)),
              subtitle: Text(longDate(entry.date)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle notifications for a birthday
                  if (notify)
                    IconButton(
                      icon: Icon(entry.notify ? notifyOnIcon : notifyOffIcon),
                      tooltip: Str.editLabel,
                      onPressed: () async {
                        // Enable this only if disabled
                        if (!entry.notify) {
                          context.read<AppStateCubit>().toggleBirthdayNotify(i);
                        }
                      },
                    ),
                  // Edit this birthday entry
                  IconButton(
                    icon: Icon(editIcon),
                    tooltip: Str.editLabel,
                    onPressed: () async {
                      final updated = await showBirthdayEditDialog(
                        context,
                        initial: entry,
                      );
                      if (!context.mounted) return;
                      if (updated != null) {
                        context.read<AppStateCubit>().editBirthday(i, updated);
                      }
                    },
                  ),
                  // Delete this birthday entry
                  if (birthdays.length > 1)
                    IconButton(
                      icon: Icon(deleteIcon),
                      tooltip: Str.deleteLabel,
                      onPressed: () {
                        context.read<AppStateCubit>().removeBirthday(i);
                      },
                    ),
                ],
              ),
              onTap: () {
                context.read<AppStateCubit>().setSelectedBirthday(i);
                Navigator.of(context).maybePop();
              },
            );
          },
        ),
      ),
    );
  }

  // Button to add a new birthday
  Widget addBirthday(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Platform.isIOS
          ? CupertinoButton.filled(
              child: Text(Str.birthdayAddLabel),
              onPressed: () async {
                final newEntry = await showBirthdayEditDialog(context);
                if (!context.mounted) return;
                if (newEntry != null) {
                  context.read<AppStateCubit>().addBirthday(newEntry);
                }
              },
            )
          : TextButton.icon(
              icon: Icon(Icons.add),
              label: Text(Str.birthdayAddLabel),
              onPressed: () async {
                final newEntry = await showBirthdayEditDialog(context);
                if (!context.mounted) return;
                if (newEntry != null) {
                  context.read<AppStateCubit>().addBirthday(newEntry);
                }
              },
            ),
    );
  }
}

// Show a dialog to add or edit a birthday entry
Future<BirthdayEntry?> showBirthdayEditDialog(
  BuildContext context, {
  BirthdayEntry? initial,
}) async {
  final nameController = TextEditingController(text: initial?.name ?? '');
  DateTime? selectedDate = initial?.date;

  return await showDialog<BirthdayEntry>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Pick a new date
          Future<void> pickDate() async {
            final picked = await adaptiveBirthdayPicker(
              context,
              initialDate: selectedDate,
            );
            if (picked != null) {
              setState(() {
                selectedDate = picked;
              });
            }
          }

          // Build the dialog based on the platform
          return Platform.isIOS
              ? CupertinoAlertDialog(
                  title: Text(
                    initial == null
                        ? Str.birthdayAddLabel
                        : Str.birthdayEditLabel,
                  ),
                  // Name field and date picker button
                  content: Column(
                    children: [
                      SizedBox(height: 12),
                      CupertinoTextField(
                        style: listTileText(context),
                        controller: nameController,
                        placeholder: Str.birthdayNameLabel,
                        maxLength: birthdayNameMaxLength,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            birthdayNameMaxLength,
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      CupertinoButton.filled(
                        sizeStyle: CupertinoButtonSize.small,
                        onPressed: pickDate,
                        child: Text(
                          selectedDate == null
                              ? Str.dateSelectLabel
                              : longDate(selectedDate!),
                        ),
                      ),
                    ],
                  ),
                  // Cancel or save changes
                  actions: [
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      child: Text(Str.cancelLabel),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text(Str.okLabel),
                      onPressed: () {
                        if (nameController.text.trim().isEmpty ||
                            selectedDate == null) {
                          return;
                        }
                        Navigator.of(context).pop(
                          BirthdayEntry(
                            name: nameController.text.trim(),
                            date: selectedDate!,
                          ),
                        );
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text(
                    initial == null
                        ? Str.birthdayAddLabel
                        : Str.birthdayEditLabel,
                  ),
                  // Name field and date picker button
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: Str.birthdayNameLabel,
                        ),
                        maxLength: birthdayNameMaxLength,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            birthdayNameMaxLength,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            selectedDate == null
                                ? Str.dateNoneLabel
                                : longDate(selectedDate!),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: pickDate,
                            child: Text(Str.dateSelectLabel),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Cancel or save changes
                  actions: [
                    TextButton(
                      child: Text(Str.cancelLabel),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    FilledButton.tonal(
                      child: Text(Str.okLabel),
                      onPressed: () {
                        if (nameController.text.trim().isEmpty ||
                            selectedDate == null) {
                          return;
                        }
                        Navigator.of(context).pop(
                          BirthdayEntry(
                            name: nameController.text.trim(),
                            date: selectedDate!,
                          ),
                        );
                      },
                    ),
                  ],
                );
        },
      );
    },
  );
}
