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

import 'dart:io';

import 'package:boinctasks/dialog/find_computers.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get_ip_address/get_ip_address.dart';

String findComputerAndroidIos(context)
{
  try
  {
    if (Platform.isAndroid){
      findComputersAndroid(context);
    }
    else
    {
//	  getLocalIpIos(context);
    }
    }catch(error,s) {
        gLogging.addToLoggingError('get_ip (getLocalIp) $error,$s'); 
    }
    return "";
}

findComputersAndroid(context)
async 
  {
    String? ip = "";    
    try
    {
      //https://pub.dev/packages/permission_handler
      //https://medium.com/@dudhatkirtan/how-to-use-permission-handler-in-flutter-db964943237e
      final permission = Permission.locationWhenInUse;
      var ask = await permission.shouldShowRequestRationale;
      if (ask)
      {
        await okDialog("permission",txtComputersFindRationale,context);
      }     
      
      var granted = await permission.status.isGranted;
      if (granted)
      {
        final info = NetworkInfo();
        ip = await info.getWifiIP();
        ip ??= ""; // if null ""
        findComputerDialog(ip,context);
        return;
      } 
      else
      {
        openAppSettings();
        findComputerDialog("",context);
        return;
      }
    }catch(error,s) {
        gLogging.addToLoggingError('get_ip (getLocalIpAndroid) $error,$s'); 
    }
}
	
getLocalIpIos(context)
async {
	// ignore: unused_local_variable
	final info = NetworkInfo();
  //  String? ip = "";    
    try
    {
		var ipAddress = IpAddress(type: RequestType.json);

		/// Get the IpAddress based on requestType.
		// ignore: unused_local_variable
		dynamic data = await ipAddress.getIpAddress();
    findComputerDialog(ipAddress,context);      
		return "";
    }catch(error,s) {
        gLogging.addToLoggingError('get_ip (getLocalIpIos) $error,$s'); 
    }
    return  "";
}

Future okDialog(title, text, context)
async {
  await showDialog(
  context: context,
  builder: (myApp) {   
    return OkDialog(title,text, onConfirm: (bool ret) {
      return ret;
      },);
    }
  );
}