/*
    BoincTasks-M to show and control one or multiple BOINC clients.
    Copyright (C) 2024-now  eFMer

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String dlgTitle;
  final String dlgText;

  const ConfirmDialog({super.key, required this.onConfirm, required this.dlgText, required this.dlgTitle});

  final Function(bool value) onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      actions: [
        ElevatedButton(
          onPressed: () { // Cancel
            onConfirm(false);
            Navigator.of(context).pop(); // close dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () { // OK
            onConfirm(true);
            // Handle the selected item here           
            Navigator.of(context).pop(); // close dialog
          },
          child: const Text('OK'),
        ),
      ],
      title: Text(dlgTitle),
      content: Text(dlgText),             
      );    
  }
}