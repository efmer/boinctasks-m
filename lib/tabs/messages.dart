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

import 'dart:ui';
import 'package:boinctasks/constants.dart';
import 'package:boinctasks/functions.dart';
import 'package:boinctasks/header.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';

class Messages {
  var mSeqnoHigh = 0;
  var mMessagesArray = [];  
  var cInit = "Initializing....";

  updateHeader(columnText, columnWidth, newWidth,bWrite)
  {
    gHeaderInfo.mHeaderMessagesWidth[columnWidth] = newWidth; 
    if (bWrite)
    {
      gHeaderInfo.writeMessages();      
    }
  }

  init()
  {
    mSeqnoHigh = 0;
    mMessagesArray = [];      
  }

  getSeqno()
  {
    return mSeqnoHigh;
  }

 getHeaderMessages()
  {
    headerMessagesMinMax();    
    var tableItem = {  
        cHeaderTab:cTypeMessage,        
        'col_1':txtHeaderComputer,
        'col_1_w': gHeaderInfo.mHeaderMessagesWidth['col_1_w'], 
        'col_1_n' :false,
        'col_2':txtMessagesHeaderNr,
        'col_2_w': gHeaderInfo.mHeaderMessagesWidth['col_2_w'], 
        'col_2_n' :true,
        'col_3':txtHeaderProject,
        'col_3_w': gHeaderInfo.mHeaderMessagesWidth['col_3_w'], 
        'col_3_n' :false,
        'col_4':txtMessagesHeaderTime,
        'col_4_w': gHeaderInfo.mHeaderMessagesWidth['col_4_w'], 
        'col_4_n' :false,
        'col_5':txtMessagesHeaderMessage,
        'col_5_w': gHeaderInfo.mHeaderMessagesWidth['col_5_w'], 
        'col_5_n' :false,
      }; 
    return tableItem;
  } 

  newData(computer, data)
  {
    var header = {};
    var rows = [];
    var ret = [];
    try{
      var ret = process(computer, data);
      header = getHeaderMessages();

      var len = ret.length;
      for (var i=0;i<len;i++)
      {
        var item = ret[i];
        
        var color = const Color.fromARGB(255, 234, 234, 234);
        var colorText = const Color.fromARGB(255, 0, 0, 0);

        if (i.isEven)
        {
          color = lighten(color);
        }
        rows.add({
          'row' : i,
          'color' : color,
          'colorText': colorText,          
          'type':item[0],
          'computer':computer,
          'col_1':computer,
          'col_2':item[1],
          'col_3':item[2],
          'col_4':item[3],
          'col_5':item[4],
        });  
      }

    } catch (error,s) {
      gLogging.addToLoggingError('Messages (newData) $error,$s'); 
    }
    ret.add(header);    
    ret.add(rows);
    return ret;
  }

  process(computer, data)
  {
    try{
      if (data.containsKey('msgs'))
      {
        var msgs = data['msgs'];
        if (msgs.containsKey('msg'))
        {
          var messages = msgs['msg'];
          var len = messages.length;
          for (var i=0;i<len;i++)
          {
            var item = messages[i];
            if (item == null) // if we have only one.
            {
              item = messages;
              len = 1;
            }
            var project = item['project']['\$t'];
            project ??= ""; // if null
            var seqno = item['seqno']['\$t'];
            var seqnoi= int.parse(seqno);
            var body = item['body']['__cdata'];
            body = body.replaceAll('\\n', '').trim();
            body = body.replaceAll('\\', '').trim();
            var time = int.parse(item['time']['\$t']);
            var timeS = getFormattedTimeFull(time);
            var list = [-1, seqno,project,timeS,body ];
            mMessagesArray.add(list);    

            if (mSeqnoHigh< seqnoi)
            {
              mSeqnoHigh = seqnoi;
            }
          }
        }
      }
    }catch(error,s)
    {
      gLogging.addToLoggingError('Messages (process) $error,$s');
      mMessagesArray = [];
      mSeqnoHigh = 0;
    }
    return mMessagesArray;
  }

  getProject(state,url)
  {
    var projects = state['client_state']['project'];
    var len = projects.length;
    for (var i=0;i<len;i++)
    {
      var item =  projects[i];
      if (item['master_url']['\$t'] == url)
      { 
        var project = item['project_name']['\$t'];
        return project;
      }
    }
//    bStateNeedsUpdate = true;
    return null;
  }

}