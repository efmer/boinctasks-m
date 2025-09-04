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
import 'package:boinctasks/functions.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';

var gColors = [];
List <Color> gColorList = [];       // colors in use
List <Color> gColorListMain = [];   // all the light and dark colors
var gColorStriping = cColorStripingNormal;

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
    mBtColors.gotColorsToMain(contents);
    mBtColors.switchColorDarkOrLight();
  
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
    try {    
      for (var i=0; i<=indexColorMainLast;i++ )
      {
        gColorListMain.add(Colors.grey);        
      }
      for (var i=0; i<=indexColorMainLast;i++ )
      {
        gColorList.add(Colors.grey);        
      }

      // Light
      gColorListMain[indexColorMainTasksSuspendedBack]        = defColorTasksSuspendedBack;
      gColorListMain[indexColorMainTasksRunningBack]          = defColorTasksRunningBack;
      gColorListMain[indexColorMainTasksDownloadingBack]      = defColorTasksDownloadingBack;
      gColorListMain[indexColorMainTasksReadyToStartBack]     = defColorTasksReadyToStartBack;
      gColorListMain[indexColorMainTasksComputationErrorBack] = defColorTasksComputationErrorBack;
      gColorListMain[indexColorMainTasksUploadingBack]        = defColorTasksUploadingBack;
      gColorListMain[indexColorMainTasksReadyToReportBack]    = defColorTasksReadyToReportBack;
      gColorListMain[indexColorMainTasksWaitingToRunBack]     = defColorTasksWaitingToRunBack;
      gColorListMain[indexColorMainTasksSuspendedByUserBack]  = defColorTasksSuspendedByUserBack;
      gColorListMain[indexColorMainTasksAbortedBack]          = defColorTasksAbortedBack;
      gColorListMain[indexColorMainTasksHighPriorityBack]     = defColorTasksHighPriority;    
      gColorListMain[indexColorMainTasksText]                 = defColorTasksText;
      gColorListMain[indexColorMainTasksCollapsed]            = defColorTasksCollapsed;

      // Dark
      gColorListMain[indexColorMainDarkTasksSuspendedBack]        = defDarkColorTasksSuspendedBack;
      gColorListMain[indexColorMainDarkTasksRunningBack]          = defDarkColorTasksRunningBack;
      gColorListMain[indexColorMainDarkTasksDownloadingBack]      = defDarkColorTasksDownloadingBack;
      gColorListMain[indexColorMainDarkTasksReadyToStartBack]     = defDarkColorTasksReadyToStartBack;
      gColorListMain[indexColorMainDarkTasksComputationErrorBack] = defDarkColorTasksComputationErrorBack;
      gColorListMain[indexColorMainDarkTasksUploadingBack]        = defDarkColorTasksUploadingBack;
      gColorListMain[indexColorMainDarkTasksReadyToReportBack]    = defDarkColorTasksReadyToReportBack;
      gColorListMain[indexColorMainDarkTasksWaitingToRunBack]     = defDarkColorTasksWaitingToRunBack;
      gColorListMain[indexColorMainDarkTasksSuspendedByUserBack]  = defDarkColorTasksSuspendedByUserBack;
      gColorListMain[indexColorMainDarkTasksAbortedBack]          = defDarkColorTasksAbortedBack;
      gColorListMain[indexColorMainDarkTasksHighPriorityBack]     = defDarkColorTasksHighPriority;    
      gColorListMain[indexColorMainDarkTasksText]                 = defDarkColorTasksText;
      gColorListMain[indexColorMainTasksCollapsed]                = defDarkColorTasksCollapsed;     
    } catch (error,s) {
        gLogging.addToLoggingError('BtColors (init) $error,$s');
      return;
    }    
  }

  void gotColorsToMain(String contents)
  {
    try {
      gColors = jsonDecode(contents); 
      if (gColors.isEmpty)
      {
        return;
      }      
      gColors.map((colorRead) {    
        getColorfromMap(indexColorMainTasksSuspendedBack,       colorRead,cColorTasksSuspendedBack);
        getColorfromMap(indexColorMainTasksRunningBack,         colorRead,cColorTasksRunningBack);         
        getColorfromMap(indexColorMainTasksDownloadingBack,     colorRead,cColorTasksDownloadingBack);    
        getColorfromMap(indexColorMainTasksReadyToStartBack,    colorRead,cColorTasksReadyToStartBack);    
        getColorfromMap(indexColorMainTasksComputationErrorBack,colorRead,cColorTasksComputationErrorBack);    
        getColorfromMap(indexColorMainTasksUploadingBack,       colorRead, cColorTasksUploadingBack);    
        getColorfromMap(indexColorMainTasksReadyToReportBack,   colorRead, cColorTasksReadyToReportBack);    
        getColorfromMap(indexColorMainTasksWaitingToRunBack,    colorRead, cColorTasksWaitingToRunBack);    
        getColorfromMap(indexColorMainTasksSuspendedByUserBack, colorRead, cColorTasksSuspendedByUserBack);    
        getColorfromMap(indexColorMainTasksAbortedBack,         colorRead, cColorTasksAbortedBack);       
        getColorfromMap(indexColorMainTasksHighPriorityBack,    colorRead ,cColorTasksHighPriority);
        getColorfromMap(indexColorMainTasksText,                colorRead, cColorTasksText);
        getColorfromMap(indexColorMainTasksCollapsed,           colorRead, cColorTasksCollapsed);        

        getColorfromMap(indexColorMainDarkTasksSuspendedBack,       colorRead, cDarkColorTasksSuspendedBack);
        getColorfromMap(indexColorMainDarkTasksRunningBack ,        colorRead, cDarkColorTasksRunningBack);         
        getColorfromMap(indexColorMainDarkTasksDownloadingBack,     colorRead, cDarkColorTasksDownloadingBack);    
        getColorfromMap(indexColorMainDarkTasksReadyToStartBack,    colorRead, cDarkColorTasksReadyToStartBack);    
        getColorfromMap(indexColorMainDarkTasksComputationErrorBack,colorRead, cDarkColorTasksComputationErrorBack);    
        getColorfromMap(indexColorMainDarkTasksUploadingBack,       colorRead, cDarkColorTasksUploadingBack);    
        getColorfromMap(indexColorMainDarkTasksReadyToReportBack,   colorRead, cDarkColorTasksReadyToReportBack);    
        getColorfromMap(indexColorMainDarkTasksWaitingToRunBack,    colorRead, cDarkColorTasksWaitingToRunBack);    
        getColorfromMap(indexColorMainDarkTasksSuspendedByUserBack, colorRead, cDarkColorTasksSuspendedByUserBack);    
        getColorfromMap(indexColorMainDarkTasksAbortedBack,         colorRead, cDarkColorTasksAbortedBack);       
        getColorfromMap(indexColorMainDarkTasksHighPriorityBack,    colorRead, cDarkColorTasksHighPriority);
        getColorfromMap(indexColorMainDarkTasksText,                colorRead, cDarkColorTasksText);
        getColorfromMap(indexColorMainDarkTasksCollapsed,           colorRead, cDarkColorTasksCollapsed);

        if (colorRead.containsKey(cColorStriping))
        {
          gColorStriping = colorRead[cColorStriping];
        }
        else
        {
          gColorStriping = cColorStripingNormal;
        }
        setStripingFactor();

      }).toList();      
    } catch (error,s) {
      gLogging.addToLoggingError('BtColors (gotColors) $error,$s');
      return;
    }
  }

  void getColorfromMap(dynamic key,colorRead,index)
  {
    try{
      if (colorRead.containsKey(index))
      {
        Color colorSet = Color(int.parse(colorRead[index].toString(), radix: 16));
        gColorListMain[key] = colorSet;
      }
    } catch (error,s) {
      gLogging.addToLoggingError('BtColors (getColorfromMap) $error,$s');
    }
  }

  void switchColorDarkOrLight()
  {
    try {
      if (gbDarkMode)
      {
        // dark
        gColorList[indexColorTasksSuspendedBack]      = gColorListMain[indexColorMainDarkTasksSuspendedBack];
        gColorList[indexColorTasksRunningBack]        = gColorListMain[indexColorMainDarkTasksRunningBack];
        gColorList[indexColorTasksDownloadingBack]    = gColorListMain[indexColorMainDarkTasksDownloadingBack];
        gColorList[indexColorTasksReadyToStartBack]   = gColorListMain[indexColorMainDarkTasksReadyToStartBack];
        gColorList[indexColorTasksComputationErrorBack] = gColorListMain[indexColorMainDarkTasksComputationErrorBack];
        gColorList[indexColorTasksUploadingBack]      = gColorListMain[indexColorMainDarkTasksUploadingBack];
        gColorList[indexColorTasksReadyToReportBack]  = gColorListMain[indexColorMainDarkTasksReadyToReportBack];
        gColorList[indexColorTasksWaitingToRunBack]   = gColorListMain[indexColorMainDarkTasksWaitingToRunBack];
        gColorList[indexColorTasksSuspendedByUserBack]= gColorListMain[indexColorMainDarkTasksSuspendedByUserBack];
        gColorList[indexColorTasksAbortedBack]        = gColorListMain[indexColorMainDarkTasksAbortedBack];
        gColorList[indexColorTasksHighPriorityBack]   = gColorListMain[indexColorMainDarkTasksHighPriorityBack];
        gColorList[indexColorTasksText]               = gColorListMain[indexColorMainDarkTasksText];
        gColorList[indexColorTasksCollapsed]          = gColorListMain[indexColorMainDarkTasksCollapsed];        
      }
      else
      {
        // light
        gColorList[indexColorTasksSuspendedBack]      = gColorListMain[indexColorMainTasksSuspendedBack];
        gColorList[indexColorTasksRunningBack]        = gColorListMain[indexColorMainTasksRunningBack];
        gColorList[indexColorTasksDownloadingBack]    = gColorListMain[indexColorMainTasksDownloadingBack];
        gColorList[indexColorTasksReadyToStartBack]   = gColorListMain[indexColorMainTasksReadyToStartBack];
        gColorList[indexColorTasksComputationErrorBack] = gColorListMain[indexColorMainTasksComputationErrorBack];
        gColorList[indexColorTasksUploadingBack]      = gColorListMain[indexColorMainTasksUploadingBack];
        gColorList[indexColorTasksReadyToReportBack]  = gColorListMain[indexColorMainTasksReadyToReportBack];
        gColorList[indexColorTasksWaitingToRunBack]   = gColorListMain[indexColorMainTasksWaitingToRunBack];
        gColorList[indexColorTasksSuspendedByUserBack]= gColorListMain[indexColorMainTasksSuspendedByUserBack];
        gColorList[indexColorTasksAbortedBack]        = gColorListMain[indexColorMainTasksAbortedBack];
        gColorList[indexColorTasksHighPriorityBack]   = gColorListMain[indexColorMainTasksHighPriorityBack];
        gColorList[indexColorTasksText]               = gColorListMain[indexColorMainTasksText];
        gColorList[indexColorTasksCollapsed]          = gColorListMain[indexColorMainTasksCollapsed];
      }
    } catch (error,s) {
      gLogging.addToLoggingError('BtColors (switchColorDarkOrLight) $error,$s');
    }    
  }


  void openDialog(dynamic context) {
    Navigator.of(context).push(MaterialPageRoute<Null>(
      builder: (BuildContext context) {
      return const ColorPickerBt();
    },
    fullscreenDialog: true));
  }
}

class ColorPickerBt extends StatefulWidget {
  const ColorPickerBt({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ColorPickerDemoState createState() => _ColorPickerDemoState();
}

class _ColorPickerDemoState extends State<ColorPickerBt> {
  Color currentColor = const Color.fromARGB(255, 181, 180, 180); // Initial color

  String selectedValue = txtColorStripingNormal;
  List<String> items = [
    txtColorStripingNone,
    txtColorStripingLow ,
    txtColorStripingNormal,
    txtColorStripingHigh,
  ];

  void setStriping(dynamic striping)
  {
    switch(striping)
    {
      case txtColorStripingNone:
        gColorStriping = cColorStripingNone;
      case txtColorStripingLow:
        gColorStriping = cColorStripingLow;
      case txtColorStripingHigh:
        gColorStriping = cColorStripingHigh;
      default:  // txtColorStripingNormal
        gColorStriping = cColorStripingNormal;
    }
    setStripingFactor();
    writeColor();
  }

  String getSettingBox()
  {
    if (gColorStriping == cColorStripingNone) return txtColorStripingNone;
    if (gColorStriping == cColorStripingLow) return txtColorStripingLow;
    if (gColorStriping == cColorStripingNormal) return txtColorStripingNormal;
    if (gColorStriping == cColorStripingHigh) return txtColorStripingHigh;  
    return txtColorStripingNormal;
  }

  @override
  void initState() {
    selectedValue = getSettingBox();    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var colorText = gColorList[indexColorTasksText];
    var modeText = "";
    if (gbDarkMode)
    {
        modeText += " Dark Mode";
    }
    else 
    {
      modeText += "Light Mode";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Select color: $modeText"),
        backgroundColor: currentColor,       
      ),
      body:
        SingleChildScrollView(        
          child: Column(
            children: [
              Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(left: 10),
                child: DropdownButtonHideUnderline(                
                  child: DropdownButton(
                    hint: Text(""),
                    value: selectedValue,
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
                      selectedValue = value as String;
                      setStriping(value);
                      setState(() {

                      });
                    },
                 ),
                ),       
              ),
              Padding(padding: EdgeInsets.all(16.0)),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Table(
                  children: [                   
                    TableRow(
                      children: <Widget>[  
                        Container(child: insertColorLR(txtTasksRunning, indexColorTasksRunningBack, colorText,false)),
                        Container(child: insertColorLR(txtTasksRunning, indexColorTasksRunningBack, colorText,true)),                      
                      ],
                    ),
                    TableRow(
                      children: <Widget>[  
                        Container(child: insertColorLR(txtTasksDownloading, indexColorTasksDownloadingBack, colorText,false)),
                        Container(child: insertColorLR(txtTasksDownloading, indexColorTasksDownloadingBack, colorText,true)),                      
                      ],                                     
                    ),
                    TableRow(
                      children: <Widget>[  
                        Container( child: insertColorLR(txtTasksReadyToStart, indexColorTasksReadyToStartBack, colorText,false)),
                        Container( child: insertColorLR(txtTasksReadyToStart, indexColorTasksReadyToStartBack, colorText,true)), 
                      ],                                     
                    ),
                    TableRow(
                      children: <Widget>[  
                        Container( child: insertColorLR(txtTasksComputationError, indexColorTasksComputationErrorBack, colorText,false)),
                        Container( child: insertColorLR(txtTasksComputationError, indexColorTasksComputationErrorBack, colorText,true)), 
                      ],                                     
                    ),
                                      TableRow(
                      children: <Widget>[  
                        Container( child: insertColorLR(txtTasksUploading, indexColorTasksUploadingBack, colorText,false)),
                        Container( child: insertColorLR(txtTasksUploading, indexColorTasksUploadingBack, colorText,true)), 
                      ],                                     
                    ),
                    TableRow(
                      children: <Widget>[  
                        Container( child: insertColorLR(txtTasksReadyToReport, indexColorTasksReadyToReportBack, colorText,false)),
                        Container( child: insertColorLR(txtTasksReadyToReport, indexColorTasksReadyToReportBack, colorText,true)), 
                      ],                                     
                    ),
                    TableRow(
                      children: <Widget>[  
                        Container( child: insertColorLR(txtTasksWaitingToRun, indexColorTasksWaitingToRunBack, colorText,false)),
                        Container( child: insertColorLR(txtTasksWaitingToRun, indexColorTasksWaitingToRunBack, colorText,true)), 
                      ],                                     
                    ),
                    TableRow(
                      children: <Widget>[  
                        Container( child: insertColorLR(txtTasksSuspendedByUser, indexColorTasksSuspendedByUserBack, colorText,false)),
                        Container( child: insertColorLR(txtTasksSuspendedByUser, indexColorTasksSuspendedByUserBack, colorText,true)), 
                      ],                                     
                    ),
                    TableRow(
                      children: <Widget>[  
                        Container( child: insertColorLR(txtTasksAborted, indexColorTasksAbortedBack, colorText,false)),
                        Container( child: insertColorLR(txtTasksAborted, indexColorTasksAbortedBack, colorText,true)),
                      ],                                                         
                    ),
                    TableRow(
                      children: <Widget>[  
                        Container( child: insertColorLR(txtTasksHighPriority, indexColorTasksHighPriorityBack, colorText,false)),
                        Container( child: insertColorLR(txtTasksHighPriority, indexColorTasksHighPriorityBack, colorText,true)), 
                      ],                                     
                    ),
                    TableRow(
                      children: <Widget>[  
                        Container( child: insertColorLR(txtTasksCollapsed, indexColorTasksCollapsed, colorText,false)),  
                        Container( child: insertColorLR(txtTasksCollapsed, indexColorTasksCollapsed, colorText,true)), 
                      ],                                     
                    ),
                    TableRow(
                      children: <Widget>[  
                        Container( child: insertColorLR(txtTasksText, indexColorTasksText, const Color.fromARGB(255, 174, 174, 174),false)),
                        Container( child: insertColorLR(txtTasksText, indexColorTasksText, const Color.fromARGB(255, 174, 174, 174),true)), 
                      ],                                     
                    )                                                      
                  ],
                ),
              ), 
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
      child: Container(color:gColorList[colorIndex] , width: double.infinity, padding:const EdgeInsets.only(left:40, right:40), child:Align(alignment:Alignment.centerLeft, child:Text(txt, style:TextStyle(fontSize:20, color:txtColor)) ) )
    );    
  }

  Widget insertColorLR(String txt,int colorIndex, Color txtColor, bDarken) { 
    Color colorLR;
    if (bDarken)
    {
      colorLR = darken(gColorList[colorIndex]);
    }
    else
    {
      colorLR = lighten(gColorList[colorIndex]);
    }

    return InkWell(
      onTap: (){
        currentColor = gColorList[colorIndex];
        _openColorPicker(colorIndex) ;
      },      
      child: Container(color: colorLR, width: double.infinity, padding:const EdgeInsets.only(left:40, right:40), child:Align(alignment:Alignment.centerLeft, child:Text(txt, style:TextStyle(fontSize:20, color:txtColor)) ) )
    );    
  }

  void copyColorToMain()
  {
    if (gbDarkMode)
    {
      // dark
      gColorListMain[indexColorMainDarkTasksSuspendedBack]      = gColorList[indexColorTasksSuspendedBack];
      gColorListMain[indexColorMainDarkTasksRunningBack]        = gColorList[indexColorTasksRunningBack];
      gColorListMain[indexColorMainDarkTasksDownloadingBack]    = gColorList[indexColorTasksDownloadingBack];
      gColorListMain[indexColorMainDarkTasksReadyToStartBack]   = gColorList[indexColorTasksReadyToStartBack];
      gColorListMain[indexColorMainDarkTasksComputationErrorBack] = gColorList[indexColorTasksComputationErrorBack];
      gColorListMain[indexColorMainDarkTasksUploadingBack]      = gColorList[indexColorTasksUploadingBack];
      gColorListMain[indexColorMainDarkTasksReadyToReportBack]  = gColorList[indexColorTasksReadyToReportBack];
      gColorListMain[indexColorMainDarkTasksWaitingToRunBack]   = gColorList[indexColorTasksWaitingToRunBack];
      gColorListMain[indexColorMainDarkTasksSuspendedByUserBack]= gColorList[indexColorTasksSuspendedByUserBack];
      gColorListMain[indexColorMainDarkTasksAbortedBack]        = gColorList[indexColorTasksAbortedBack];
      gColorListMain[indexColorMainDarkTasksHighPriorityBack]   = gColorList[indexColorTasksHighPriorityBack];
      gColorListMain[indexColorMainDarkTasksText]               = gColorList[indexColorTasksText];
      gColorListMain[indexColorMainDarkTasksCollapsed]          = gColorList[indexColorTasksCollapsed];
    }
    else
    {
      // light
      gColorListMain[indexColorMainTasksSuspendedBack]      = gColorList[indexColorTasksSuspendedBack];
      gColorListMain[indexColorMainTasksRunningBack]        = gColorList[indexColorTasksRunningBack];
      gColorListMain[indexColorMainTasksDownloadingBack]    = gColorList[indexColorTasksDownloadingBack];
      gColorListMain[indexColorMainTasksReadyToStartBack]   = gColorList[indexColorTasksReadyToStartBack];
      gColorListMain[indexColorMainTasksComputationErrorBack] = gColorList[indexColorTasksComputationErrorBack];
      gColorListMain[indexColorMainTasksUploadingBack]      = gColorList[indexColorTasksUploadingBack];
      gColorListMain[indexColorMainTasksReadyToReportBack]  = gColorList[indexColorTasksReadyToReportBack];
      gColorListMain[indexColorMainTasksWaitingToRunBack]   = gColorList[indexColorTasksWaitingToRunBack];
      gColorListMain[indexColorMainTasksSuspendedByUserBack]= gColorList[indexColorTasksSuspendedByUserBack];
      gColorListMain[indexColorMainTasksAbortedBack]        = gColorList[indexColorTasksAbortedBack];
      gColorListMain[indexColorMainTasksHighPriorityBack]   = gColorList[indexColorTasksHighPriorityBack];
      gColorListMain[indexColorMainTasksText]               = gColorList[indexColorTasksText];
      gColorListMain[indexColorMainTasksCollapsed]               = gColorList[indexColorTasksCollapsed];
    }
  }
  
  void writeColor() {
    copyColorToMain();
    var colorsMap = [];
    colorsMap.add({
      cColorTasksSuspendedBack        : gColorListMain[indexColorMainTasksSuspendedBack].hexAlpha.toString(),
      cColorTasksRunningBack          : gColorListMain[indexColorMainTasksRunningBack].hexAlpha.toString(),
      cColorTasksDownloadingBack      : gColorListMain[indexColorMainTasksDownloadingBack].hexAlpha.toString(),
      cColorTasksReadyToStartBack     : gColorListMain[indexColorMainTasksReadyToStartBack].hexAlpha.toString(),
      cColorTasksComputationErrorBack : gColorListMain[indexColorMainTasksComputationErrorBack].hexAlpha.toString(),
      cColorTasksUploadingBack        : gColorListMain[indexColorMainTasksUploadingBack].hexAlpha.toString(),
      cColorTasksReadyToReportBack    : gColorListMain[indexColorMainTasksReadyToReportBack].hexAlpha.toString(),
      cColorTasksWaitingToRunBack     : gColorListMain[indexColorMainTasksWaitingToRunBack].hexAlpha.toString(),
      cColorTasksSuspendedByUserBack  : gColorListMain[indexColorMainTasksSuspendedByUserBack].hexAlpha.toString(),
      cColorTasksAbortedBack          : gColorListMain[indexColorMainTasksAbortedBack].hexAlpha.toString(),
      cColorTasksHighPriority         : gColorListMain[indexColorMainTasksHighPriorityBack].hexAlpha.toString(),
      cColorTasksText                 : gColorListMain[indexColorMainTasksText].hexAlpha.toString(),
      cColorTasksCollapsed            : gColorListMain[indexColorMainTasksCollapsed].hexAlpha.toString(),      

      cDarkColorTasksSuspendedBack        : gColorListMain[indexColorMainDarkTasksSuspendedBack].hexAlpha.toString(),
      cDarkColorTasksRunningBack          : gColorListMain[indexColorMainDarkTasksRunningBack].hexAlpha.toString(),
      cDarkColorTasksDownloadingBack      : gColorListMain[indexColorMainDarkTasksDownloadingBack].hexAlpha.toString(),
      cDarkColorTasksReadyToStartBack     : gColorListMain[indexColorMainDarkTasksReadyToStartBack].hexAlpha.toString(),
      cDarkColorTasksComputationErrorBack : gColorListMain[indexColorMainDarkTasksComputationErrorBack].hexAlpha.toString(),
      cDarkColorTasksUploadingBack        : gColorListMain[indexColorMainDarkTasksUploadingBack].hexAlpha.toString(),
      cDarkColorTasksReadyToReportBack    : gColorListMain[indexColorMainDarkTasksReadyToReportBack].hexAlpha.toString(),
      cDarkColorTasksWaitingToRunBack     : gColorListMain[indexColorMainDarkTasksWaitingToRunBack].hexAlpha.toString(),
      cDarkColorTasksSuspendedByUserBack  : gColorListMain[indexColorMainDarkTasksSuspendedByUserBack].hexAlpha.toString(),
      cDarkColorTasksAbortedBack          : gColorListMain[indexColorMainDarkTasksAbortedBack].hexAlpha.toString(),
      cDarkColorTasksHighPriority         : gColorListMain[indexColorMainDarkTasksHighPriorityBack].hexAlpha.toString(),
      cDarkColorTasksText                 : gColorListMain[indexColorMainDarkTasksText].hexAlpha.toString(), 
      cDarkColorTasksCollapsed            : gColorListMain[indexColorMainDarkTasksCollapsed].hexAlpha.toString(),

      cColorStriping                      : gColorStriping
    });
    String json = jsonEncode(colorsMap);  
    writeColorFile(json);    
  }  
}