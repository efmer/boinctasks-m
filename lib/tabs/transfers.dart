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
import 'package:boinctasks/tabs/misc/header.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';

class Transfers {

 updateHeader(columnText, columnWidth, newWidth,bWrite)
 {
  gHeaderInfo.mHeaderTransfersWidth[columnWidth] = newWidth; 
  if (bWrite)
  {
    gHeaderInfo.writeTransfers();      
  }
}

// _w width, _n number in sorting
getHeaderTransfers()
{
  headerTransfersMinMax();
  var tableItem = {
    cHeaderTab:cTypeTransfer,
    'col_1':txtHeaderComputer,
    'col_1_w': gHeaderInfo.mHeaderTransfersWidth['col_1_w'], 
    'col_1_n' :false,      
    'col_2':txtHeaderProject,
    'col_2_w': gHeaderInfo.mHeaderTransfersWidth['col_2_w'], 
    'col_2_n' :false,        
    'col_3':txtTransfersHeaderFile,
    'col_3_w': gHeaderInfo.mHeaderTransfersWidth['col_3_w'], 
    'col_3_n' :false,        
    'col_4':txtTransfersHeaderSize,
    'col_4_w': gHeaderInfo.mHeaderTransfersWidth['col_4_w'], 
    'col_4_n' :false,        
    'col_5':txtTransfersHeaderElapsed,
    'col_5_w': gHeaderInfo.mHeaderTransfersWidth['col_5_w'], 
    'col_5_n' :false,        
    'col_6':txtTransfersHeaderSpeed,
    'col_6_n' :true,        
    'col_6_w': gHeaderInfo.mHeaderTransfersWidth['col_6_w'], 
    'col_7':txtTransferHeaderProgress,
    'col_7_w': gHeaderInfo.mHeaderTransfersWidth['col_7_w'], 
    'col_7_n' :false,      
    'col_8':txtHeaderStatus,
    'col_8_w': gHeaderInfo.mHeaderTransfersWidth['col_8_w'], 
    'col_8_n' :false,        
  };
  return tableItem;
}

newData(state, computer, selected, data)
  {
    var header = {};
    var rows = [];
    var ret = [];
    try{
      var retProcess = process(computer, state, data);
      header = getHeaderTransfers();

      var lenSel = selected.length;
      var len = retProcess.length;
      for (var i=0;i<len;i++)
      {
        //var tableItem = [];
        var item = retProcess[i];
       
        var color = const Color.fromARGB(255, 234, 234, 234);
        var colorText = const Color.fromARGB(255, 0, 0, 0);        

        for(var s=0;s<lenSel;s++)
        {
          if (item[cTransfersPosFile] == selected[s][cTransfersFile])
          {
            color = const Color.fromARGB(255, 68, 68, 68);
            colorText = const Color.fromARGB(255, 255, 255, 255);
            break;
          }
        }

        if (i.isEven)
        {
          color = lighten(color);
        }
        rows.add({
          'row' : i,
          'color' : color,
          'colorStatus': color,
          'colorText': colorText,
          'type':cTypeTransfer,
          'computer':computer,
          'col_1':computer,
          'col_2':item[cTransfersPosProject],
          'col_3':item[cTransfersPosFile],
          'col_4':item[cTransfersPosSize],
          'col_5':item[cTransfersPosElapsed],
          'col_6':item[cTransfersPosSpeed], 
          'col_7':item[cTransfersPosProgress], 
          'col_8':item[cTransfersPosStatus],         
        });
      }
    } catch (error,s) {
      gLogging.addToLoggingError('Transfers (newData) $error,$s'); 
    }
    ret.add(header);    
    ret.add(rows);    
    return ret;
  }

  process(computer, state, data)
  {
    var transfersArray = [];    
    try{    
      var transfers = data['file_transfers'];
      if (!transfers.containsKey('file_transfer'))
      {
        return transfersArray;
      }

      var transfer = transfers['file_transfer'];
      var len = transfer.length;    

      for (var i=0;i<len;i++)
      {
        var item =  transfer[i];

        var project = item["project_name"]['\$t'];
        var wu = item["name"]['\$t'];

        double firstRequestTime = 0;
        var isUpload = "-1";
        double lastBytesXferred = 0;
        double nextRequestTime = 0;
        var numRetries = 0;
        double timeSoFar = 0;
        double xferSpeed = 0;

        if (item.containsKey("persistent_file_xfer"))
        {
          var persistant = item["persistent_file_xfer"];
          firstRequestTime = double.parse(persistant["first_request_time"]['\$t']);
          isUpload = persistant["is_upload"]['\$t'];
          lastBytesXferred = double.parse(persistant["last_bytes_xferred"]['\$t']);
          nextRequestTime = double.parse(persistant["next_request_time"]['\$t']);
          numRetries = int.parse(persistant["num_retries"]['\$t']);
          timeSoFar = double.parse(persistant["time_so_far"]['\$t']);
        }
        if (item.containsKey("file_xfer"))
        {
          var fileTransfer = item["file_xfer"];
          xferSpeed = double.parse(fileTransfer["xfer_speed"]['\$t']);
        }    

        double nbytes = double.parse(item["nbytes"]['\$t']);
        var progressS = "";
        if (lastBytesXferred > 0)
        {
          double perc = lastBytesXferred * 100;
          perc = perc / nbytes;
          if (perc > 100) perc = 100;
          var percS = perc.toStringAsFixed(3);   
          //var style = 'style="background-color:' + colorObj['#progress_bar'] + '!important;' + 'width:'+ perc + '%;">';    
          //item = '<div ' + style + percS + '</div>'
          progressS = percS;
        }

        double kbytes =  nbytes/1024;
        var kbytesS = "${kbytes.toStringAsFixed(2)} K";

//        var soFarS = "";
        if (timeSoFar > 0)
        {
 //         soFarS = getFormattedTimeInterval(timeSoFar.toInt());
        }

        var elapsedS = "";
        var elapsed = nextRequestTime - firstRequestTime;
        if (elapsed > 0) elapsedS = getFormattedTimeInterval(elapsed.toInt()); 
        
        var speedS = "";
        var speed = xferSpeed/1024;
        speedS = "${speed.toStringAsFixed(3)} KBps";
        
        var uploadDownload  = false;
        if (isUpload == '1') uploadDownload = true; 

        var statusS = "";
        if (item.containsKey("transfer.file_xfer"))
        {
          if (uploadDownload)
          {
            statusS += "Uploading";
          } else 
          {
            statusS += "Downloading";
          }
        }
        else
        {
          if (item.containsKey("project_backoff"))
          {            
            if (uploadDownload)
            {
             statusS += "Uploading";
            } else
            {
              statusS += "Downloading";
            }

            var projectBackoff = double.parse(item["project_backoff"]['\$t']);
            if (projectBackoff > 0)
            {
              statusS += " (Project backoff: ";
              statusS += getFormattedTimeInterval(projectBackoff.toInt());
              statusS += ") ";
            }                    
          }
          else
          {
            if (nextRequestTime > 0)
            {
              var nextS = getFormattedTimeDiff(nextRequestTime.toInt(),true);
              if (nextS != "")
              {
                statusS += "(Retry in: $nextS)";
              }
            }
            if (uploadDownload)
            {
              statusS += "Upload pending ";
            } else
            {
              statusS += "Download pending ";
            }
          }
        }
      
    
    if (numRetries > 0)
    {
      statusS += ",retried: $numRetries";
    } 
    var list = [cTransfers, project, wu, kbytesS, elapsedS, speedS, progressS,statusS] ;
    transfersArray.add(list);
    }
      
    }catch(error,s)
    {
      gLogging.addToLoggingError('Transfers (process) $error,$s');
      transfersArray = [];
    }
    return transfersArray;
  } 
}