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
import 'package:boinctasks/main.dart';

Future<String> get _localPath async {
    final path = gLocalPath;
    return path;
}

Future<String> get _localPathHeader async {
    final path = await _localPath;
  return path;
}

Future<File> writeHeaderFile(fileName, String json) async {
  final path = await _localPathHeader;
  var file = File("$path/$fileName.json");
  return file.writeAsString(json);
}

Future<dynamic> readHeaderFile(fileName) async {
try {
  final path = await _localPathHeader;
  var file = File("$path/$fileName.json");
  // Read the file
  String contents = await file.readAsString();
  var data = jsonDecode(contents);   
  return data;
} catch (error) {
    gLogging.addToDebugLogging('No valid header file found: $fileName');
}
return [];
}
headerComputersMinMax()
{
  try {
  var len = gHeaderInfo.mHeaderComputersWidth.length;

  for (var i=1;i<len+1;i++)
  {
    // ignore: prefer_adjacent_string_concatenation
    var col = "col_$i" + "_w";
    var width = gHeaderInfo.mHeaderComputersWidth[col];
    if (width < cMinHeaderWidth)
    {
      gHeaderInfo.mHeaderComputersWidth[col] = cMinHeaderWidth;
    }
    if (width > cMaxHeaderWidth)
    {
      gHeaderInfo.mHeaderComputersWidth[col] = cMaxHeaderWidth;
    }
  }
  } catch (error,s) {
      gLogging.addToLoggingError('Header (headerComputersMinMax) $error,$s');
  }  
}

headerMessagesMinMax()
{
  try {
  var len = gHeaderInfo.mHeaderMessagesWidth.length;

  for (var i=1;i<len+1;i++)
  {
    // ignore: prefer_adjacent_string_concatenation
    var col = "col_$i" + "_w";
    var width = gHeaderInfo.mHeaderMessagesWidth[col];
    if (width < cMinHeaderWidth)
    {
      gHeaderInfo.mHeaderMessagesWidth[col] = cMinHeaderWidth;
    }
    if (width > cMaxHeaderWidth)
    {
      gHeaderInfo.mHeaderMessagesWidth[col] = cMaxHeaderWidth;
    }
  }
  } catch (error,s) {
      gLogging.addToLoggingError('Header (headerMessagesMinMax) $error,$s');
  }  
}


headerProjectsMinMax()
{
  try {
  var len = gHeaderInfo.mHeaderProjectsWidth.length;

  for (var i=1;i<len+1;i++)
  {
    // ignore: prefer_adjacent_string_concatenation
    var col = "col_$i" + "_w";
    var width = gHeaderInfo.mHeaderProjectsWidth[col];
    if (width < cMinHeaderWidth)
    {
      gHeaderInfo.mHeaderProjectsWidth[col] = cMinHeaderWidth;
    }
    if (width > cMaxHeaderWidth)
    {
      gHeaderInfo.mHeaderProjectsWidth[col] = cMaxHeaderWidth;
    }
  }
  } catch (error,s) {
      gLogging.addToLoggingError('Header (headerProjectsMinMax) $error,$s');
  }  
}

headerTasksMinMax()
{
  try {
    var len = gHeaderInfo.mHeaderTasksWidth.length;

    for (var i=1;i<len+1;i++)
    {
      // ignore: prefer_adjacent_string_concatenation
      var col = "col_$i" + "_w";
      var width = gHeaderInfo.mHeaderTasksWidth[col];
      if (width < cMinHeaderWidth)
      {
        gHeaderInfo.mHeaderTasksWidth[col] = cMinHeaderWidth;
      }
      if (width > cMaxHeaderWidth)
      {
        gHeaderInfo.mHeaderTasksWidth[col] = cMaxHeaderWidth;
      }
    }
  } catch (error,s) {
      gLogging.addToLoggingError('Header (headerProjectsMinMax) $error,$s');
  }    
}

headerTransfersMinMax()
{
  try {
    var len = gHeaderInfo.mHeaderTransfersWidth.length;

    for (var i=1;i<len+1;i++)
    {
      // ignore: prefer_adjacent_string_concatenation
      var col = "col_$i" + "_w";
      var width = gHeaderInfo.mHeaderTransfersWidth[col];
      if (width < cMinHeaderWidth)
      {
        gHeaderInfo.mHeaderTransfersWidth[col] = cMinHeaderWidth;
      }
      if (width > cMaxHeaderWidth)
      {
        gHeaderInfo.mHeaderTransfersWidth[col] = cMaxHeaderWidth;
      }
    }
  } catch (error,s) {
      gLogging.addToLoggingError('Header (headerTransfersMinMax) $error,$s');
  }    
}

var gHeaderInfo = HeaderInfo();

class HeaderInfo{
  var mHeaderComputersWidth = {};  
  var mHeaderMessagesWidth = {};  
  var mHeaderProjectsWidth = {};
  var mHeaderTasksWidth   = {};
  var mHeaderTransfersWidth = {};  

  init()
  {
    try{
      initComputersHeader();
      initMessagesHeader();
      initProjectsHeader();
      initTasksHeader();
      initTransfersHeader();
      readComputers();      
      readMessages();      
      readProjects();
      readTasks();
      readTransfers();      
    } catch (error,s) {
      gLogging.addToLoggingError('HeaderInfo (init) $error,$s');
      return;
    }    
  }

  readComputers()
  async {
    try{
      var data = await readHeaderFile(cFileNameHeaderComputersWidth);
      var len = data.length+1;
      var keyb = "col_";
      var keye = "_w";
      for (var i=1;i<len;i++)
      {
        var key = "$keyb$i$keye";
        if (data.containsKey(key))
        {      
          mHeaderComputersWidth[key] = data[key].toDouble();
        }
      }
    } catch (error,s) {
      gLogging.addToLoggingError('HeaderInfo (readComputers) $error,$s');
      return;
    }
  }

  readMessages()
  async {
    try{
      var data = await readHeaderFile(cFileNameHeaderMessagesWidth);
      var len = data.length+1;
      var keyb = "col_";
      var keye = "_w";
      for (var i=1;i<len;i++)
      {
        var key = "$keyb$i$keye";
        if (data.containsKey(key))
        {      
          mHeaderMessagesWidth[key] = data[key].toDouble();
        }
      }
    } catch (error,s) {
      gLogging.addToLoggingError('HeaderInfo (readMessages) $error,$s');
      return;
    }
  }

  readProjects()
  async {
    try{
      var data = await readHeaderFile(cFileNameHeaderProjectsWidth);
      var len = data.length+1;
      var keyb = "col_";
      var keye = "_w";
      for (var i=1;i<len;i++)
      {
        var key = "$keyb$i$keye";
        if (data.containsKey(key))
        {      
          mHeaderProjectsWidth[key] = data[key].toDouble();
        }
      }
    } catch (error,s) {
      gLogging.addToLoggingError('HeaderInfo (readProjects) $error,$s');
      return;
    }
  } 

  readTasks()
  async {
    try{
      var data = await readHeaderFile(cFileNameHeaderTasksWidth);
      var len = data.length+1;
      var keyb = "col_";
      var keye = "_w";
      for (var i=1;i<len;i++)
      {
        var key = "$keyb$i$keye";
        if (data.containsKey(key))
        {      
          mHeaderTasksWidth[key] = data[key].toDouble();
        }
      }
    } catch (error,s) {
      gLogging.addToLoggingError('HeaderInfo (readTasks) $error,$s');
      return;
    }
  }  

  readTransfers()
  async {
    try{
      var data = await readHeaderFile(cFileNameHeaderTransfersWidth);
      var len = data.length+1;
      var keyb = "col_";
      var keye = "_w";
      for (var i=1;i<len;i++)
      {
        var key = "$keyb$i$keye";
        if (data.containsKey(key))
        {      
          mHeaderTransfersWidth[key] = data[key].toDouble();
        }
      }
    } catch (error,s) {
      gLogging.addToLoggingError('HeaderInfo (readTransfers) $error,$s');
      return;
    }
  }

  initComputersHeader()
  {
    mHeaderComputersWidth['col_1_w'] = 40.0;
    mHeaderComputersWidth['col_2_w'] = 100.0; 
    mHeaderComputersWidth['col_3_w'] = 100.0; 
    mHeaderComputersWidth['col_4_w'] = 140.0; 
    mHeaderComputersWidth['col_5_w'] = 352.0;     
    mHeaderComputersWidth['col_6_w'] = 100.0;  
    mHeaderComputersWidth['col_7_w'] = 100.0;  
    mHeaderComputersWidth['col_8_w'] = 300.0;              
  }

  initMessagesHeader()
  {
    mHeaderMessagesWidth['col_1_w'] = 100.0;
    mHeaderMessagesWidth['col_2_w'] = 52.0; 
    mHeaderMessagesWidth['col_3_w'] = 152.0; 
    mHeaderMessagesWidth['col_4_w'] = 152.0; 
    mHeaderMessagesWidth['col_5_w'] = 352.0;     
  }

  initProjectsHeader()
  {
    mHeaderProjectsWidth['col_1_w'] = 100.0;
    mHeaderProjectsWidth['col_2_w'] = 150.0; 
    mHeaderProjectsWidth['col_3_w'] = 150.0; 
    mHeaderProjectsWidth['col_4_w'] = 150.0; 
  }

  initTasksHeader()
  {
    mHeaderTasksWidth['col_1_w'] = 110.0;
    mHeaderTasksWidth['col_2_w'] = 152.0;
    mHeaderTasksWidth['col_3_w'] = 152.0;
    mHeaderTasksWidth['col_4_w'] = 152.0;
    mHeaderTasksWidth['col_5_w'] = 152.0;
    mHeaderTasksWidth['col_6_w'] = 52.0;
    mHeaderTasksWidth['col_7_w'] = 152.0;
    mHeaderTasksWidth['col_8_w'] = 152.0;
  }
  
  initTransfersHeader()
  {
    mHeaderTransfersWidth['col_1_w'] = 110.0;
    mHeaderTransfersWidth['col_2_w'] = 152.0;
    mHeaderTransfersWidth['col_3_w'] = 152.0;
    mHeaderTransfersWidth['col_4_w'] = 50.0;
    mHeaderTransfersWidth['col_5_w'] = 152.0;
    mHeaderTransfersWidth['col_6_w'] = 100.0;
    mHeaderTransfersWidth['col_7_w'] = 100.0;
    mHeaderTransfersWidth['col_8_w'] = 400.0;    
  }

  writeComputers()
  {
    try{
      String json = jsonEncode(mHeaderComputersWidth);  
      writeHeaderFile(cFileNameHeaderComputersWidth,json);   
    } catch (error,s) {
      gLogging.addToLoggingError('HeaderInfo (writeComputers) $error,$s');
      return;
    }    
  }
  
  writeMessages()
  {
    try{
      String json = jsonEncode(mHeaderMessagesWidth);  
      writeHeaderFile(cFileNameHeaderMessagesWidth,json);   
    } catch (error,s) {
      gLogging.addToLoggingError('HeaderInfo (writeMessages) $error,$s');
      return;
    }    
  }

  writeProjects()
  {
    try{
      String json = jsonEncode(mHeaderProjectsWidth);  
      writeHeaderFile(cFileNameHeaderProjectsWidth,json);   
    } catch (error,s) {
      gLogging.addToLoggingError('HeaderInfo (writeProjects) $error,$s');
      return;
    }    
  }

  writeTasks()
  {
    try{    
    String json = jsonEncode(mHeaderTasksWidth);  
    writeHeaderFile(cFileNameHeaderTasksWidth,json);   
    } catch (error,s) {
      gLogging.addToLoggingError('HeaderInfo (writeTasks) $error,$s');
      return;
    }  
  }

  writeTransfers()
  {
    try{
      String json = jsonEncode(mHeaderTransfersWidth);  
      writeHeaderFile(cFileNameHeaderTransfersWidth,json);   
    } catch (error,s) {
      gLogging.addToLoggingError('HeaderInfo (writeTransfers) $error,$s');
      return;
    }    
  }
}
