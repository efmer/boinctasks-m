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

//https://pub.dev/documentation/flex_color_picker/latest/#dialog-colorpicker-method

import 'dart:convert';
import 'dart:io';

import 'package:boinctasks/constants.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

var colorInit = Colors.white;
var gColors = [];
List <Color> gColorList = [colorInit,colorInit,colorInit,colorInit,colorInit,colorInit,colorInit,colorInit,colorInit,colorInit,colorInit,colorInit,colorInit,colorInit];

Future<File> get _localFileColors async {
    final path = await gLocalPath;
  return File('$path/$cFileNameColors');
}

Future<File> writeColorFile(String colors) async {
    final file = await _localFileColors;
  // Write the file
  return file.writeAsString(colors);
  }
Future<void> readColorsFile() async {
  try {
    final file = await _localFileColors;

    // Read the file
    String contents = await file.readAsString();
    mBtColors.gotColors(contents);
    //https://docs.flutter.dev/data-and-backend/serialization/json
    gbcolorsRead = true;
    return;
//    return contents.toString();
  } catch (error) {
      gLogging.addToDebugLogging('No valid color file found');
      gbcolorsRead = true; // true otherwise things get stuck on a loop.
    return;
  }
}

class BtColors
{
  void init()
  {
    gColorList[indexColorTasksSuspendedBack] = defColorTasksSuspendedBack;
    gColorList[indexColorTasksRunningBack] = defColorTasksRunningBack;
    gColorList[indexColorTasksDownloadingBack] = defColorTasksDownloadingBack;
    gColorList[indexColorTasksReadyToStartBack] = defColorTasksReadyToStartBack;
    gColorList[indexColorTasksComputationErrorBack] = defColorTasksComputationErrorBack;
    gColorList[indexColorTasksUploadingBack] = defColorTasksUploadingBack;
    gColorList[indexColorTasksReadyToReportBack] = defColorTasksReadyToReportBack;
    gColorList[indexColorTasksWaitingToRunBack] = defColorTasksWaitingToRunBack;
    gColorList[indexColorTasksSuspendedByUserBack] = defColorTasksSuspendedByUserBack;
    gColorList[indexColorTasksAbortedBack] = defColorTasksAbortedBack;
  }

  void gotColors(String contents)
  {

    try {
      gColors = jsonDecode(contents); 
      if (gColors.isEmpty)
      {
        return;
      }
      gColors.map((colorRead) {    
        gColorList[indexColorTasksSuspendedBack]  = Color(int.parse(colorRead[cColorTasksSuspendedBack].toString(), radix: 16));
        gColorList[indexColorTasksRunningBack]  = Color(int.parse(colorRead[cColorTasksRunningBack].toString(), radix: 16));         
        gColorList[indexColorTasksDownloadingBack]  = Color(int.parse(colorRead[cColorTasksDownloadingBack].toString(), radix: 16));    
        gColorList[indexColorTasksReadyToStartBack]  = Color(int.parse(colorRead[cColorTasksReadyToStartBack].toString(), radix: 16));    
        gColorList[indexColorTasksComputationErrorBack]  = Color(int.parse(colorRead[cColorTasksComputationErrorBack].toString(), radix: 16));    
        gColorList[indexColorTasksUploadingBack]  = Color(int.parse(colorRead[cColorTasksUploadingBack].toString(), radix: 16));    
        gColorList[indexColorTasksReadyToReportBack]  = Color(int.parse(colorRead[cColorTasksReadyToReportBack].toString(), radix: 16));    
        gColorList[indexColorTasksWaitingToRunBack]  = Color(int.parse(colorRead[cColorTasksWaitingToRunBack].toString(), radix: 16));    
        gColorList[indexColorTasksSuspendedByUserBack]  = Color(int.parse(colorRead[cColorTasksSuspendedByUserBack].toString(), radix: 16));    
        gColorList[indexColorTasksAbortedBack]  = Color(int.parse(colorRead[cColorTasksAbortedBack].toString(), radix: 16));       
      }).toList();      
    } catch (error,s) {
      gLogging.addToLoggingError('BtColors (gotColors) $error,$s');
      return;
    }
  }

  void openDialog(context) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
      return const ColorPickerDemo();
    },
    fullscreenDialog: true));
  }
}

class ColorPickerDemo extends StatefulWidget {
  const ColorPickerDemo({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ColorPickerDemoState createState() => _ColorPickerDemoState();
}

class _ColorPickerDemoState extends State<ColorPickerDemo> {
  Color currentColor = const Color.fromARGB(255, 255, 255, 255); // Initial color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BoincTasks select color'),
        backgroundColor: currentColor,
      ),
      body: Center(
        child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            insertColor(txtTasksRunning, indexColorTasksRunningBack, Colors.black),
            insertColor(txtTasksDownloading, indexColorTasksDownloadingBack, Colors.black),            
            insertColor(txtTasksReadyToStart, indexColorTasksReadyToStartBack, Colors.black), 
            insertColor(txtTasksComputationError, indexColorTasksComputationErrorBack, Colors.black), 
            insertColor(txtTasksUploading, indexColorTasksUploadingBack, Colors.black), 
            insertColor(txtTasksReadyToReport, indexColorTasksReadyToReportBack, Colors.black), 
            insertColor(txtTasksWaitingToRun, indexColorTasksWaitingToRunBack, Colors.black), 
            insertColor(txtTasksSuspendedByUser, indexColorTasksSuspendedByUserBack, Colors.black), 
            insertColor(txtTasksAborted, indexColorTasksAbortedBack, Colors.black), 
          ],
        ),
      ),
    );
  }

  // Function to open the color picker dialog
  Future _openColorPicker(int colorIndex) async {
    bool pickedColor = await ColorPicker(
      color: gColorList[colorIndex],
      onColorChanged: (Color newColor) {
        setState(() {
          currentColor = newColor;
        });
      },
      width: 40,
      height: 40,
      borderRadius: 20,
      spacing: 10,
      runSpacing: 10,
      heading: const Text('Pick a color'),
      
     // subheading: const Text('Select a color for your widget'),
      wheelDiameter: 200,
      wheelWidth: 20,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.wheel: true,
      },
      showColorCode: false,
      
    ).showPickerDialog(context);
    if (pickedColor) // pressed OK
    {
      gColorList[colorIndex] = currentColor;      
      writeColor(); 
      setState(() {});   
    }
  }
  
  Widget insertColor(String txt, int colorIndex, Color txtColor) {      
    return InkWell(
      onTap: (){
        currentColor =  gColorList[colorIndex];
        _openColorPicker(colorIndex) ;
      },
      child: Container(color:gColorList[colorIndex] , width: double.infinity, padding:const EdgeInsets.only(left:10, right:10), child:Align(alignment:Alignment.centerLeft, child:Text(txt, style:TextStyle(fontSize:20, color:txtColor)) ) )
    );    
  }
  
  void writeColor() {
    var colorsMap = [];
    colorsMap.add({
      cColorTasksSuspendedBack : gColorList[indexColorTasksSuspendedBack].hexAlpha.toString(),
      cColorTasksRunningBack : gColorList[indexColorTasksRunningBack].hexAlpha.toString(),
      cColorTasksDownloadingBack : gColorList[indexColorTasksDownloadingBack].hexAlpha.toString(),
      cColorTasksReadyToStartBack : gColorList[indexColorTasksReadyToStartBack].hexAlpha.toString(),
      cColorTasksComputationErrorBack : gColorList[indexColorTasksComputationErrorBack].hexAlpha.toString(),
      cColorTasksUploadingBack : gColorList[indexColorTasksUploadingBack].hexAlpha.toString(),
      cColorTasksReadyToReportBack : gColorList[indexColorTasksReadyToReportBack].hexAlpha.toString(),
      cColorTasksWaitingToRunBack : gColorList[indexColorTasksWaitingToRunBack].hexAlpha.toString(),
      cColorTasksSuspendedByUserBack : gColorList[indexColorTasksSuspendedByUserBack].hexAlpha.toString(),
      cColorTasksAbortedBack : gColorList[indexColorTasksAbortedBack].hexAlpha.toString(),
    });
    String json = jsonEncode(colorsMap);  
    writeColorFile(json);    
  }  
}