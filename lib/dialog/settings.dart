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

void getSettings()
{
  // Warning we get here twice
  try {
    if (gsettings.isEmpty)
    {
      gsettings.add({cSettingsRefresh:3});
      grefreshRate = 3;
      return;
    }

    var len = gsettings.length;

    for (var i=0;i<len;i++)
    {
      var item = gsettings[i];
      if (item.containsKey(cSettingsRefresh))
      {  
        grefreshRate = item[cSettingsRefresh];
      }  
      if (item.containsKey(cSettingsMaxBusy))
      {  
        gMaxBusySec = item[cSettingsMaxBusy];
      }

      if (item.containsKey(cSettingsSocketTimeout))
      {  
        gSocketTimeout = item[cSettingsSocketTimeout];
      } 

      if (item.containsKey(cSettingsReconnect))
      {  
        gReconnectTimeout = item[cSettingsReconnect];
      } 

      if (item.containsKey(cSettingsDarkMode))
      {  
        gbDarkMode = item[cSettingsDarkMode];      
      }
    }
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
  String mTextStatus = "";

  bool bDark = gbDarkMode;
  late String mSelectedValue;
  List<String> items = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ];

  late String mSelectedMaxBusyValue;
  List<String> itemsMaxBusy = [
    '10',    
    '15',
    '30',    
  ];


  late String mSelectedTimeoutValue;
  List<String> itemsTimeout = [
    '5',
    '10',
    '15',
    '30',    
  ];

  late String mSelectedReconnectValue;
  List<String> itemsReconnect = [
    '10',
    '15',
    '30',    
  ];

  @override
  void initState() {
    mSelectedValue = grefreshRate.toString();
    if (!mSelectedValue.contains(mSelectedValue))
    {
      mSelectedValue = '3';
    }

    mSelectedMaxBusyValue = gMaxBusySec.toString(); 
    if (!itemsMaxBusy.contains(mSelectedMaxBusyValue))
    {
      mSelectedMaxBusyValue = '15';
    }

    mSelectedTimeoutValue = gSocketTimeout.toString(); 
    if (!itemsTimeout.contains(mSelectedTimeoutValue))
    {
      mSelectedTimeoutValue = '15';
    }

    mSelectedReconnectValue = gReconnectTimeout.toString(); 
    if (!itemsReconnect.contains(mSelectedReconnectValue))
    {
      mSelectedReconnectValue = '30';
    }

    super.initState();
  }

  @override
  void dispose()
  {
    mBtColors.switchColorDarkOrLight();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SimpleDialog(   
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.fromLTRB(10, 12.0, 10, 16.0),
      title: Text(txtSettingsDialog),
      children: <Widget>[    
        Text(txtSettingsRefreshTime),        
        DropdownButtonHideUnderline(
          child: DropdownButton(
            hint: Text(""),
            value: mSelectedValue,
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
                mSelectedValue = value as String;
              });
            },
          ),
        ),  
        CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),            
          title: Text(txtSettingsDarkMode),        
          value: gbDarkMode,
          onChanged: (bool? newValue) {
            if (newValue == true)
            {
              appThemeProvider.setDark();
            }
            else
            {
              appThemeProvider.setLight();              
            }                
            setState(() {   
              gbDarkMode = newValue!;              
            });
          }
        ),
// ------------------------------------------------------------------------

        const Divider(height: 10, thickness: 5, indent: 0.1, endIndent: 0),
          Padding(
            padding: const EdgeInsets.only(left: 0, top:0, bottom: 20),
            child: Text(txtSettingsAdvanced),            
          ),

        // Max main loop time in mSec
        Text(txtSettingsBusyTimeout),
        DropdownButtonHideUnderline(
          child: DropdownButton(
            hint: Text(""),
            value: mSelectedMaxBusyValue,
            items: itemsMaxBusy
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
                mSelectedMaxBusyValue = value as String;
              });
            },
          ),
        ),


        // Socket timeout
        Text(txtSettingsSocketTimeout),
        DropdownButtonHideUnderline(
          child: DropdownButton(
            hint: Text(""),
            value: mSelectedTimeoutValue,
            items: itemsTimeout
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
                mSelectedTimeoutValue = value as String;
              });
            },
          ),
        ),

        // Reconnect delay
        Text(txtSettingsReconnect),
        DropdownButtonHideUnderline(
          child: DropdownButton(
            hint: Text(""),
            value: mSelectedReconnectValue,
            items: itemsReconnect
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
                mSelectedReconnectValue = value as String;
              });
            },
          ),
        ),   

        Text(mTextStatus,
          style: TextStyle(
            color: const Color.fromARGB(255, 247, 0, 0),
            fontWeight: FontWeight.bold,
          ),            
        ),     

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  if (bDark != gbDarkMode)
                  {
                      gbDarkMode = bDark;
                      if (gbDarkMode == true)
                      {
                        appThemeProvider.setDark();
                      }
                      else
                      {
                        appThemeProvider.setLight();              
                      }                              
                  }
                  Navigator.of(context).pop(); // close dialog
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle the selected item here
                  var iselectedValue = int.parse(mSelectedValue);
                  grefreshRate = iselectedValue; 
                  var issocketMaxBusyValue = int.parse(mSelectedMaxBusyValue);
                  var issocketTimeoutValue = int.parse(mSelectedTimeoutValue);
                  var isReconnectValue = int.parse(mSelectedReconnectValue);
                  if (issocketTimeoutValue >= isReconnectValue)
                  {
                    mTextStatus = txtSettingsTime;
                    setState(() {   
                    });                      
                    return;
                  }

                  if (isReconnectValue < issocketMaxBusyValue)
                  {
                    mTextStatus = txtSettingsMaxBusy;
                    setState(() {   
                    });                      
                    return;
                  }

                  gMaxBusySec = issocketMaxBusyValue;
                  gSocketTimeout = issocketTimeoutValue;
                  gReconnectTimeout = isReconnectValue;                  
                  var settings = [];               
                  settings.add ({cSettingsRefresh: iselectedValue});
                  settings.add ({cSettingsMaxBusy: issocketMaxBusyValue});                     
                  settings.add ({cSettingsSocketTimeout: issocketTimeoutValue});              
                  settings.add ({cSettingsReconnect: isReconnectValue});    
                  settings.add ({cSettingsDarkMode: gbDarkMode});              
                  gsettings = settings;
                  String json = jsonEncode(gsettings);
                  writeSettings(json);

                  //gsettings.add[{cSettingsRefresh:1};  //selectedValue;          
                  Navigator.of(context).pop(); // close dialog
                },
                child: const Text('OK'),
              ),  
            ],
        ),          
      ],
    );
  }  
}