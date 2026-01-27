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

import 'package:biorhythmmm/common/buttons.dart';
import 'package:biorhythmmm/common/helpers.dart';
import 'package:biorhythmmm/common/icons.dart';
import 'package:biorhythmmm/common/notifications.dart' show NotificationType;
import 'package:biorhythmmm/common/modals.dart';
import 'package:biorhythmmm/common/styles.dart';
import 'package:biorhythmmm/data/localization.dart';
import 'package:biorhythmmm/data/prefs.dart';
import 'package:biorhythmmm/data/app_state.dart';
import 'package:biorhythmmm/widgets/birthday_picker.dart';

import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_bloc/flutter_bloc.dart';

const int birthdayNameMaxLength = 25;

// Open a modal to add, edit, or delete user birthdays
Future<void> showBirthdayManager(BuildContext context) async {
  await showModal(context, const BirthdayManagerSheet());
}

// Birthday manager sheet
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
              height: birthdays.length * 55 + 180,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Build a birthday manager
                  sheetHeader(
                    context,
                    title: AppString.birthdayManageLabel.translate(),
                  ),
                  birthdayList(birthdays: birthdays, notify: notify),
                  // Button to add a new birthday
                  adaptiveModalButton(
                    text: AppString.birthdayAddLabel.translate(),
                    icon: Icon(Icons.add),
                    onPressed: () async {
                      final newEntry = await showBirthdayEditDialog(context);
                      if (!context.mounted) return;
                      if (newEntry != null) {
                        context.read<AppStateCubit>().addBirthday(newEntry);
                      }
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
              leading: Icon(Icons.cake_outlined),
              title: Text(entry.name, style: listTileText(context)),
              subtitle: Text(longDate(entry.date)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Toggle notifications for a birthday
                  if (notify)
                    IconButton(
                      icon: Icon(entry.notify ? notifyOnIcon : notifyOffIcon),
                      tooltip: AppString.notificationsLabel.translate(),
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
                    tooltip: AppString.editLabel.translate(),
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
                      tooltip: AppString.deleteLabel.translate(),
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
    barrierDismissible: false,
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
                        ? AppString.birthdayAddLabel.translate()
                        : AppString.birthdayEditLabel.translate(),
                  ),
                  // Name field and date picker button
                  content: SizedBox(
                    height: 120,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 12),
                          CupertinoTextField(
                            style: listTileText(context),
                            controller: nameController,
                            placeholder: AppString.birthdayNameLabel
                                .translate(),
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
                                  ? AppString.dateSelectLabel.translate()
                                  : longDate(selectedDate!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Cancel or save changes
                  actions: [
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      child: Text(AppString.cancelLabel.translate()),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text(AppString.okLabel.translate()),
                      onPressed: () {
                        if (nameController.text.trim().isEmpty ||
                            selectedDate == null) {
                          return;
                        }
                        Navigator.of(context).pop(
                          BirthdayEntry(
                            name: nameController.text.trim(),
                            date: selectedDate!,
                            notify: initial?.notify ?? false,
                          ),
                        );
                      },
                    ),
                  ],
                )
              : AlertDialog(
                  title: Text(
                    initial == null
                        ? AppString.birthdayAddLabel.translate()
                        : AppString.birthdayEditLabel.translate(),
                  ),
                  // Name field and date picker button
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: AppString.birthdayNameLabel.translate(),
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
                                ? AppString.dateNoneLabel.translate()
                                : longDate(selectedDate!),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: pickDate,
                            child: Text(AppString.dateSelectLabel.translate()),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Cancel or save changes
                  actions: [
                    TextButton(
                      child: Text(AppString.cancelLabel.translate()),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    FilledButton.tonal(
                      child: Text(AppString.okLabel.translate()),
                      onPressed: () {
                        if (nameController.text.trim().isEmpty ||
                            selectedDate == null) {
                          return;
                        }
                        Navigator.of(context).pop(
                          BirthdayEntry(
                            name: nameController.text.trim(),
                            date: selectedDate!,
                            notify: initial?.notify ?? false,
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
