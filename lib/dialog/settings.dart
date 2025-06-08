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

import 'dart:convert';
import 'dart:io';

import 'package:boinctasks/constants.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:flutter/material.dart';


Future<File> get _localFileSettings async {
  final path = await gLocalPath;
  return File('$path/$cFileNameSettings');
}

Future<File> writeSettings(String settings) async {
  final file = await _localFileSettings;
  // Write the file
  return file.writeAsString(settings);
}

Future<void> readSettingsFile() async {
  try {
    final file = await _localFileSettings;

    // Read the file
    final contents = await file.readAsString();
    //https://docs.flutter.dev/data-and-backend/serialization/json
    gsettings = jsonDecode(contents);
    gbsettingRead = true;
    return;
//    return contents.toString();
  } catch (error) {
      gLogging.addToDebugLogging('Warning: No valid settings file found');
      gbsettingRead = true; // true otherwise things get stuck on a loop.
    return;
  }
}

getSettings()
{
  try {
    if (gsettings.isEmpty)
    {
      gsettings.add({cSettingsRefresh:3});
    }

    gsettings.map((settings) {     
      if (settings.containsKey(cSettingsRefresh))
      {  
        grefreshRate = settings[cSettingsRefresh];
      }
      if (settings.containsKey(cSettingsDebug))
      {  
        gbDebug = settings[cSettingsDebug];
      }     

    }).toList(); 
  }
    catch(error,s)
    {
      gLogging.addToLoggingError('settings (getSettings) $error,$s'); 
    }
}

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<StatefulWidget> createState() {
    return SettingsDialogState();
  }
}

class SettingsDialogState extends State<SettingsDialog> {
  String? selectedValue;
  List<String> items = [
    '1',
    '2',
    '3',
    '4',
    '5',
  ];

  @override
  void initState() {
//    settingsDefault();
    selectedValue = grefreshRate.toString();    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // close dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Handle the selected item here
            if (selectedValue != null) {
              var iselectedValue = int.parse(selectedValue!);
              grefreshRate = iselectedValue;              
              var settings = [];
              settings.add ({cSettingsRefresh: iselectedValue});
              settings.add ({cSettingsDebug: gbDebug});
              gsettings = settings;
              String json = jsonEncode(gsettings);
              writeSettings(json);
              gLogging.debugMode(gbDebug);
              //gsettings.add[{cSettingsRefresh:1};  //selectedValue;
            }
            Navigator.of(context).pop(); // close dialog
          },
          child: const Text('OK'),
        ),
      ],


      titlePadding: const EdgeInsets.only(top: 20, left: 15, right: 15, bottom: 5),
      contentPadding: const EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: 5
      ),
      title: Text(
          txtSettingsRefreshTime,
      ),
      content: SizedBox(
        width: double.infinity,
        height: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton(
                hint: Text(
                  txtSettingsRefreshSelect,
                ),
                value: selectedValue,
//                value:refreshRate,
                items: items
                    .map((item) =>
                    DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                      ),
                    ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedValue = value as String;
                    //Navigator.of(context).pop();
                  });
                  //print(value);

                  // selectedValue = value as String;
                },
              ),
            ),
            CheckboxListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),            
            title: Text(txtSettingsDebugEnabled),        
            value: gbDebug,
            onChanged: (bool? newValue) {
              setState(() {
                gbDebug = newValue!;
              });
            }
          ),
          ],
        ),
      )        
    );
  }
}