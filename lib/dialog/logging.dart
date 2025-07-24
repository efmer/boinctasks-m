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
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

String gLogTxt = "";
String gLogTxtError = "";  

class BtLogging
{
  bool mbDebug = false;
  String mGotVersion = "";
//  String mLogTxt = "";

  Future<void> init()
  async {
    var txt = "BoincTasks-M, ";
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;    
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

  debugMode(bdebug)
  {
    if (mbDebug == bdebug)
    {
      return;
    }
    if (bdebug)
    {
      addToLogging(txtLoggingDebugMode,false); 
    }
    else
    {
      addToLogging(txtLoggingDebugModeNot,false);       
    }
    mbDebug = bdebug;
  }

  getVersion()
  {
    return mGotVersion;
  }

  addToLogging(String addTxt, [bFirst = false])
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
  }

  addToDebugLogging(String addTxt, [bFirst = false])
  {
    if (mbDebug)
    {      
      addToLogging("Debug: $addTxt",bFirst);
    }
  }

  addToLoggingError(String addTxt, [bFirst = false])
  {
    var log = "";
    var time = '\n';
    time += getTime();
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
  }

  String getTime()
  {
    //https://api.flutter.dev/flutter/intl/DateFormat-class.html
    DateTime now = DateTime.now();  
    String formattedDate = DateFormat('kk:mm:s ').format(now);
    return formattedDate;
  }

  Future<void> openDialog(loggingClass,context) 
  async {
     await showDialog(
      context: context,
      builder: (myApp) {     
        return LoggingDialog(dlgName: txtLoggingDialogName,dlgError: false,);
      }
     );
  }

  Future<void> openDialogError(context) 
  async {    
    await showDialog(
      context: context,
      builder: (myApp) {     
        return LoggingDialog(dlgName: txtLoggingErrorDialogName,dlgError: true,);
      }
     );
  }
}

class LoggingDialog extends StatefulWidget {
  final dynamic dlgName;
  final dynamic dlgError;
  const LoggingDialog({super.key, this.dlgName, this.dlgError});

  @override
  State<StatefulWidget> createState() {
    return LoggingDialogState();
  }
}

class LoggingDialogState extends State<LoggingDialog> { 
  final ScrollController _controller = ScrollController();
  
  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var txt = "?";
    if(widget.dlgError)
    {
      txt = gLogTxtError;
    }    
    else
    {
      txt = gLogTxt;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dlgName),
      ),
      body: Center(
        child: SingleChildScrollView(
          controller: _controller,
          child: Column(
          children:[                
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
            ElevatedButton(
              onPressed: () {
                setState(() {                  
                });
                },                                
              child: Text(txtLoggingRefresh),
            ),
            Container(height: 40, width: 1, color: Colors.grey, margin: const EdgeInsets.only(left: 10.0, right: 10.0),),
            ElevatedButton(
              onPressed: () {
                if (widget.dlgError)
                {
                  gLogTxtError = "";
                }
                else
                {
                  gLogTxt = "";
                }
                setState(() {                  
                });
                },
              child: Text(txtLoggingClear),
            ),
          ],
          ),
        ),
      )
      
       //Text(this.indata),
    );
  }

}