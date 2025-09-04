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

import 'package:boinctasks/constants.dart';
import 'package:boinctasks/functions.dart';
import 'package:boinctasks/tabs/header/header.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:flutter/services.dart';

class Messages {
  var mSelectedLines = "";
  var mSeqnoHigh = 0;
  var mMessagesArray = [];  
  var cInit = "Initializing....";

  void updateHeader(String columnText, columnWidth, newWidth,bWrite)
  {
    gHeaderInfo.mHeaderMessagesWidth[columnWidth] = newWidth; 
    if (bWrite)
    {
      gHeaderInfo.writeMessages();      
    }
  }

  void init()
  {
    mSeqnoHigh = 0;
    mMessagesArray = [];      
  }

  int getSeqno()
  {
    return mSeqnoHigh;
  }

 Map<String, dynamic> getHeaderMessages()
  {
    headerMessagesMinMax();    
    var tableItem = {  
        cHeaderTab:cTypeMessage,        
        'col_1':txtHeaderComputer,
        'col_1_w': gHeaderInfo.mHeaderMessagesWidth['col_1_w'], 
        'col_1_n' :false,
        'col_1_s' :false,
        'col_2':txtMessagesHeaderNr,
        'col_2_w': gHeaderInfo.mHeaderMessagesWidth['col_2_w'], 
        'col_2_n' :true,
        'col_2_s' :false,        
        'col_3':txtHeaderProject,
        'col_3_w': gHeaderInfo.mHeaderMessagesWidth['col_3_w'], 
        'col_3_n' :false,
        'col_3_s' :false,        
        'col_4':txtMessagesHeaderTime,
        'col_4_w': gHeaderInfo.mHeaderMessagesWidth['col_4_w'], 
        'col_4_n' :false,
        'col_4_s' :false,        
        'col_5':txtMessagesHeaderMessage,
        'col_5_w': gHeaderInfo.mHeaderMessagesWidth['col_5_w'], 
        'col_5_n' :false,
        'col_5_s' :false,        
      }; 
    return tableItem;
  } 

  List newData(String computer, selected, data)
  {
    var header = {};
    var rows = [];
    var ret = [];
    try{
      var ret = process(computer, data);
      header = getHeaderMessages();
      var lenSel = selected.length;  
      mSelectedLines = "";

      var len = ret.length;
      for (var i=0;i<len;i++)
      {
        var item = ret[i];
        
        var color = gSystemColor.rowColor;
        var colorText = gSystemColor.rowColorText;

        for(var s=0;s<lenSel;s++)
        {          
          if (item[cMessagesPosNr] == selected[s][cMessagesNr])
          {
            var nr = item[cMessagesPosNr];
            var project = item[cMessagesPosProject];
            var time = item[cMessagesPosTime];
            var msg = item[cMessagesPosMsg];

            mSelectedLines += "$computer $nr $project $time $msg\n\r";
            color = gSystemColor.rowColorSel;
            colorText = gSystemColor.rowColorTextSel;
            break;
          }
        }

        rows.add({
          'row' : i,
          'color' : color,
          'colorStatus': color,          
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

  List process(String computer, data)
  {
    try{
      if (data != null)
      {
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
              var list = [cTypeMessage, seqno,project,timeS,body ];
              mMessagesArray.add(list);    

              if (mSeqnoHigh< seqnoi)
              {
                mSeqnoHigh = seqnoi;
              }
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

  dynamic getProject(dynamic state,url)
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

  void copyToClipboard()
  {
    try{    
      Clipboard.setData(ClipboardData(text: mSelectedLines));     
    }catch(error,s)
    {
      gLogging.addToLoggingError('Messages (copyToClipboard) $error,$s');
    }
  }
}