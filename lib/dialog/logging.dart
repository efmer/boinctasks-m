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

import 'dart:async';
import 'dart:io';
import 'package:boinctasks/constants.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

String gLogTxt = "";
String gLogTxtError = "";  
String gLogTxtDebug = "";

class BtLogging
{
//  bool mbDebug = false;
  String mGotVersion = "";
//  String mLogTxt = "";

  Future<void> init()
  async {
    var txt = "BoincTasks-M, ";
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;    
    if (kDebugMode)
    {
      version += " dbg";
    }    
    mGotVersion = version;
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String buildNumber = packageInfo.buildNumber;
    String info = "App name: $appName, Package name: $packageName, Version: $version, Build: $buildNumber ";
    txt+= info;
    String platformTxt = "Platform: ";
    if (Platform.isWindows)
    {
      platformTxt += "Windows";
    }
    else
    {
      if (Platform.isAndroid){
        platformTxt += "Android";
      }
      else
      {
  	    platformTxt += "iOS";
      }
    }
    addToLogging(txt,true);
    addToLoggingError(txt,true);
    addToLogging(platformTxt,false);
    addToLoggingError(platformTxt,false);
  }

  String getVersion()
  {
    return mGotVersion;
  }

  void addToLogging(String addTxt, [bFirst = false])
  {
    var log = "";
    var time = '\n';
    time += getTime();
    log+= time;
    log+= addTxt;

    if (bFirst)
    {
      gLogTxt = log + gLogTxt;
    }
    else
    {
      gLogTxt+= log;
    }
    addToDebugLogging(addTxt, bFirst);
  }

  void addToDebugLogging(String addTxt, [bFirst = false])
  {
    var log = "";
    var time = getTime();
    log+= time;
    log+= addTxt;

    if (bFirst)
    {
      gLogTxtDebug = log + gLogTxtDebug;
    }
    else
    {
      gLogTxtDebug+= log;
    }
    gLogTxtDebug += "\n";
    if (kDebugMode) {
      debugPrint(log);
    }
  }

  void addToLoggingError(String addTxt, [bFirst = false])
  {
    var log = "";
    var time = getTime();
    log+= time;
    log+= addTxt;

    if (bFirst)
    {
      gLogTxtError = log + gLogTxtError;
    }
    else
    {
      gLogTxtError+= log;
    }
    gLogTxtError += "\n";
    if (kDebugMode) {
      debugPrint(log);
    }
  }

  String getTime()
  {
    //https://api.flutter.dev/flutter/intl/DateFormat-class.html
    DateTime now = DateTime.now();  
    String formattedDate = DateFormat('kk:mm:s ').format(now);
    return formattedDate;
  }

  Future<void> openDialog(dynamic context) 
  async {
     await showDialog(
      context: context,
      builder: (myApp) {     
        return LoggingDialog();
      }
     );
  }
}

class LoggingDialog extends StatefulWidget {
  const LoggingDialog({super.key});

  @override
  State<StatefulWidget> createState() {
    return LoggingDialogState();
  }
}

class LoggingDialogState extends State<LoggingDialog> { 
  final ScrollController _controller = ScrollController();
  late Timer timer;
  int? selectedOption = 1;
  var loggingMode = cLoggingNormal;

  @override
  void initState() { 
    super.initState();
    timer = Timer.periodic(Duration(seconds: 3), (Timer t)
    {
      setState(() {
      });
    });
  }
  @override
  void dispose()
  {
    super.dispose();
    timer.cancel();    
  }

  @override
  Widget build(BuildContext context) {
    var txt = "?";
    var titleLog = txtLoggingDialogName;

    switch (loggingMode)
    {
      case cLoggingNormal:
        txt = gLogTxt;         
      case cLoggingDebug:
        txt = gLogTxtDebug; 
        titleLog += " Debug";
      case cLoggingError:
        txt = gLogTxtError;  
        titleLog += " Error";             
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titleLog),
        backgroundColor: gSystemColor.pageHeaderColor,
      ),
      body: SingleChildScrollView(
        controller: _controller,        
        child: Column(
          children:[
            Table(                   
              children: [                   
                TableRow(
                  children: <Widget>[  
                    RadioListTile<int>(
                      title: const Text('Logging'),
                      value: 1,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = 1;
                          loggingMode = cLoggingNormal;                    
                        });
                      },              
                    ), 
                    RadioListTile<int>(
                      title: const Text('Debug'),
                      value: 2,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = 2;
                          loggingMode = cLoggingDebug;                   
                        });
                      },              
                    ),                                
                    RadioListTile<int>(
                      title: const Text('Error'),
                      value: 3,
                      groupValue: selectedOption,
                      onChanged: (int? value) {
                        setState(() {
                          selectedOption = 3;
                          loggingMode = cLoggingError;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: txt));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'Copied')));
              },                                
              child: Text(txtLoggingButtonShare),
            ), 
            DecoratedBox(
              decoration: BoxDecoration(color: gSystemColor.viewBackgroundColor),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(txt),
              ),
            ),
          
            Container(height: 40, width: 1, color: Colors.grey, margin: const EdgeInsets.only(left: 10.0, right: 10.0),),
            ElevatedButton(
              onPressed: () {
                switch (loggingMode)
                {
                  case cLoggingNormal:
                    gLogTxt = "";
                  case cLoggingDebug:
                    gLogTxtDebug = "";
                  case cLoggingError:
                    gLogTxtError = "";                    
                }
                setState(() {                  
                });
                },
              child: Text(txtLoggingClear),
            ),
          ],
        ),
      )
    );
  }
}