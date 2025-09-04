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


Future<File> get _localFileSetTabs async {
  final path = await gLocalPath;
  return File('$path/$cFileNameSetTab');
}

Future<File> writeSetTab(String setTab) async {
  final file = await _localFileSetTabs;
  // Write the file
  return file.writeAsString(setTab);
}

Future<void> readSetTabFile() async {
  try {
    final file = await _localFileSetTabs;

    // Read the file
    final contents = await file.readAsString();
    //https://docs.flutter.dev/data-and-backend/serialization/json
    gsetTab = jsonDecode(contents);
    gbsetTabRead = true;
    return;
//    return contents.toString();
  } catch (error) {
      gLogging.addToDebugLogging('Warning: No valid setTab file found');
      gbsetTabRead = true; // true otherwise things get stuck on a loop.
    return;
  }
}

void getsetTab()
{
  // Warning we get here twice
  try {
    if (gsetTab.isEmpty)
    {
      return;
    }

    var len = gsetTab.length;

    for (var i=0;i<len;i++)
    {
      var item = gsetTab[i];
      if (item.containsKey(cSetTabDeadline))
      {  
        gdeadline = item[cSetTabDeadline];
      }  
      if (item.containsKey(cSetTabOneLine))
      {  
        var one = item[cSetTabOneLine];
        if (one > 2)
        {
          one = 2;
        }
        if (one < 1)
        {
          one = 1;
        }
        gOneLine = one;
      }        
    }
  }
    catch(error,s)
    {
      gLogging.addToLoggingError('setTab (getsetTab) $error,$s'); 
    }
}

class SetTabDialog extends StatefulWidget {
  const SetTabDialog({super.key});

  @override
  State<StatefulWidget> createState() {
    return SetTabDialogState();
  }
}

class SetTabDialogState extends State<SetTabDialog> {
  
  late String mSelectedDeadlineValue;
  List<String> itemsDeadline = [
    cSetTabDeadlineNever,    
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9'
  ];

  @override
  void initState() {
    mSelectedDeadlineValue = gdeadline;
    if (!itemsDeadline.contains(mSelectedDeadlineValue))
    {
      mSelectedDeadlineValue = cSetTabDeadlineNever;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(   
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.fromLTRB(10, 12.0, 10, 16.0),
      title: Text(txtsetTabDialog),
      children: <Widget>[

        // one or two lines in rows
        CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),            
          title: Text(txtsetTabOneLine),        
          value: gOneLine == 1,
          onChanged: (bool? newValue) {
            setState(() {              
              if (newValue!)
              {
                gOneLine = 1;                
              }
              else 
              {
                gOneLine = 2;
              }
            });
          }
        ),

        // Deadline in days
        Text(txtsetTabDeadline),        
        DropdownButtonHideUnderline(
          child: DropdownButton(
            hint: Text(""),
            value: mSelectedDeadlineValue,
            items: itemsDeadline
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
                mSelectedDeadlineValue = value as String;
              });
            },
          ),
        ),  
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Handle the selected item here           
                  var setTab = [];
                  gdeadline = mSelectedDeadlineValue;
                  setTab.add ({cSetTabDeadline: mSelectedDeadlineValue});
                  setTab.add ({cSetTabOneLine: gOneLine});
                  String json = jsonEncode(setTab);
                  writeSetTab(json);
    
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
