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

import 'package:boinctasks/dialog/color.dart';
import 'package:boinctasks/functions.dart';
import 'package:boinctasks/header.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import '../constants.dart';

class Tasks {
  var cInit = "Initializing....";
  var cStateUpdate = "State needs to update";

  var mTasksTable = [];

  updateHeader(columnText, columnWidth, newWidth,bWrite)
  {
    gHeaderInfo.mHeaderTasksWidth[columnWidth] = newWidth; 
    if (bWrite)
    {
      gHeaderInfo.writeTasks();
    }
  }

// _w width, _n number in sorting
  getHeaderTasks()
  {
    headerTasksMinMax();
    var tableItem = {
      cHeaderTab:cTypeResult,       
      'col_1':txtHeaderComputer,
      'col_1_w': gHeaderInfo.mHeaderTasksWidth['col_1_w'],
      'col_1_n' :false,      
      'col_2':txtTasksHeaderApp,
      'col_2_w': gHeaderInfo.mHeaderTasksWidth['col_2_w'],
      'col_2_n' :false,        
      'col_3':txtHeaderProject,
      'col_3_w': gHeaderInfo.mHeaderTasksWidth['col_3_w'],
      'col_3_n' :false,        
      'col_4':txtTasksHeaderName,
      'col_4_w': gHeaderInfo.mHeaderTasksWidth['col_4_w'],
      'col_4_n' :false,        
      'col_5':txtTasksHeaderElapsed,
      'col_5_w': gHeaderInfo.mHeaderTasksWidth['col_5_w'],
      'col_5_n' :false, 
      'col_6':txtTasksHeaderCpu,      
      'col_6_w': gHeaderInfo.mHeaderTasksWidth['col_6_w'],
      'col_6_n' :false,       
      'col_7':txtTasksHeaderProgress,
      'col_7_w': gHeaderInfo.mHeaderTasksWidth['col_7_w'],
      'col_7_n' :true,      
      'col_8':txtHeaderStatus,
      'col_8_w': gHeaderInfo.mHeaderTasksWidth['col_8_w'],
      'col_8_n' :false,        
    }; 
    return tableItem;
  }

  newData(statec, computer, filterRemove, selected, ccStatusIn, data)
  {
    var header = {};
    var rows = [];
    var ret = [];
    try{
      var retProcess = process(statec, computer, filterRemove, ccStatusIn, data);
      header = getHeaderTasks();
  
      if (retProcess == null)
      {
        return;
      }

      var lenSel = selected.length;
      var len = retProcess.length;
      for (var i=0;i<len;i++)
      {
        var item = retProcess[i];
        var retf = processItem(item,i,lenSel,selected);
        var color = retf[0];
        var colorText = retf[1];
    
        if (item[cTasksPosName].contains(cTextFilter))
        {
          //color = const Color.fromARGB(255, 240, 20, 20);
        }
        var type = item[0];
        // ignore: avoid_init_to_null
        var filter = null;
        if (type == cTypeFilter)
        {
          var frows = [];
          filter = item[cTasksPosFilter]; // array of wu in filter
          if (filter != null)
          {
            var lenwu = filter.length;
            for (var f=0;f<lenwu;f++)
            {
              var itemf = filter[f];
              var retwu = processItem(itemf,f,lenSel,selected);
              var colorf = retwu[0];
              var colorTextf = retwu[1];
              frows.add({          
                'row': i,
                'color': colorf,
                'colorText': colorTextf,
                'type': cTypeResult,
                'computer':computer,
                'col_1':computer,          
                'col_2':itemf[cTasksPosApp],
                'col_3':itemf[cTasksPosProject],
                'col_4':itemf[cTasksPosName],
                'col_5':itemf[cTasksPosElapsed],
                'col_6':itemf[cTasksPosCpu],
                'col_7':itemf[cTasksPosProgress],
                'col_8':itemf[cTasksPosStatus],                
              });      
            }
            filter = frows; // add the wu to the filter
            type = cTypeFilterWuArr; // filter with wu array
          }
        }

        rows.add({          
          'row': i,
          'color': color,
          'colorText': colorText,
          'type': type,
          'computer':computer,
          'col_1':computer,          
          'col_2':item[cTasksPosApp],
          'col_3':item[cTasksPosProject],
          'col_4':item[cTasksPosName],
          'col_5':item[cTasksPosElapsed],
          'col_6':item[cTasksPosCpu],          
          'col_7':item[cTasksPosProgress],
          'col_8':item[cTasksPosStatus],
          'filter': filter,
        });      
      }

    } catch (error,s) {
      gLogging.addToLoggingError('Results (newData) $error,$s'); 
    }
    ret.add(header);    
    ret.add(rows);
    mTasksTable = ret;
    return ret;
  }

  processItem(item,i,lenSel,selected)
  {
    var status = item[cTasksPosStatus];

    var colorText = const Color.fromARGB(255, 0, 0, 0);
    var color = const Color.fromARGB(255, 234, 234, 234);
    if (status.contains(txtTasksSuspended)) {
      color = gColorList[indexColorTasksSuspendedBack];
    } else {
      if (status.contains(txtTasksRunning)) {
          color = gColorList[indexColorTasksRunningBack];
      }else {
        if (status.contains(txtTasksDownloading)) {
          color = gColorList[indexColorTasksDownloadingBack];
        }else {
          if (status.contains(txtTasksReadyToStart)) {
            color = gColorList[indexColorTasksReadyToStartBack];
          } else {
            if (status.contains(txtTasksComputationError)){
              color = gColorList[indexColorTasksComputationErrorBack];
            } else {
              if (status.contains(txtTasksUploading)) { 
                color = gColorList[indexColorTasksUploadingBack];
              } else {
                if (status.contains(txtTasksReadyToReport)){
                  color = gColorList[indexColorTasksReadyToReportBack];
                } else {
                  if (status.contains(txtTasksWaitingToRun)){
                    color = gColorList[indexColorTasksWaitingToRunBack];
                  } else {
                    if (status.contains(txtTasksSuspendedByUser)){
                      color = gColorList[indexColorTasksSuspendedByUserBack];
                    } else {
                      if (status.contains(txtTasksAborted)) color = gColorList[indexColorTasksAbortedBack];
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    for(var s=0;s<lenSel;s++)
    {
      if (item[cTasksPosName] == selected[s][cTasksWu])
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
    var ret = [color,colorText];
    return ret;
  }

  process(statec, computer, filterRemove, ccStatusIn, data)
  {
    var resultsArray = [];    
    try{
      var filter = [];
      var result = data['results']['result'];
      var ccStatus = ccStatusIn['cc_status'];
      if (result == null)
      {
        return;
      }
   
      try{          
        var len = result.length;
        for (var i=0;i<len;i++)
        {
          var item =  result[i];
          var version = int.parse(item['version_num']['\$t']) / 100;
          var wu = item['wu_name']['\$t'];
          var wuName = item['name']['\$t'];
          var projectUrl = item['project_url']['\$t'];
          var project = projectUrl;
          // ignore: unused_local_variable
          var nonCpuIntensive = false;
          var ret = statec.getAppUfriendly(wu);
          var app = "";
          if (ret != null)
          {
            app = ret['user_friendly_name']['\$t'];
            var nonCpuIntensiveS = ret['non_cpu_intensive']['\$t'];
            if (nonCpuIntensiveS == "1")  
            {
              nonCpuIntensive = true;
            }        
          }
          else
          {
            app = "State needs to update";
          }

          var cpuTime = double.parse(item['final_cpu_time']['\$t']);

          ret = statec.getProject(projectUrl);
          if (ret != null)
          {
            project = ret;
          }
          var versionApp = "$version$app";
          double elapsedTime = double.parse(item['final_elapsed_time']['\$t']);
          var fraction = 0.0;
          var iState = int.parse(item['state']['\$t']);
          if (iState > 2)
          {
            fraction = 100;
          }

          var sState = "0";
          var aState = "0";
          var bActive = false;
          if (item.containsKey('active_task'))
          {
            bActive = true;
            var active = item['active_task'];
            fraction = double.parse(active['fraction_done']['\$t'])*100;
            elapsedTime = double.parse(active['elapsed_time']['\$t']);

            sState =  active['scheduler_state']['\$t'];
            aState =  active['active_task_state']['\$t'];

            cpuTime = double.parse(active['current_cpu_time']['\$t']);
          }
          else
          {
            elapsedTime = 100.0;
          }

          var cpu = 0.0;
          if (cpuTime <= 0.0 || elapsedTime <= 0.0)
          {
            cpu = 0.0;
          } 
          else 
          {             
            cpu = (cpuTime/elapsedTime) * 100;
            if (cpu > 100) cpu = 100.0;
          }
          var cpuS = cpu.toStringAsFixed(3);        

          var fractionS= "";
          if (fraction > 0)
          {
            fractionS = fraction.toStringAsFixed(3);
          }

          var elapsedS = getFormattedTimeInterval(elapsedTime.round()); 

          var hpState = "0";
          if (item.containsKey('edf_scheduled'))
          {
            hpState = "1";
          }

          var state = "0";
          if (item.containsKey('suspended_via_gui'))
          {
            state = "1";
          }
            
          var status = getStatus(item, ccStatus, hpState, state+aState+sState+iState.toString());

          // filter
          //if (status != cStatusRunning )
          if (!bActive)
          {
            var filterIndex = computer+versionApp+status;
            var filterLen = filter.length;
            var filterFound = -1;
            for (var f=0;f< filterLen;f++)
            {
              if (filter[f][cFilterArrayPosId] == filterIndex)
              {
                filterFound = f;
                break;
              }
            }
            if (filterFound == -1)
            {
              var item = [];            
              item.add(filterIndex); //cFilterArrayPosId
              item.add(1); // items
              item.add(versionApp);
              item.add(project);
              item.add(wuName);
              item.add(elapsedTime);
              item.add(cpuS);            
              item.add(fractionS);
              item.add(status);
              filter.add(item);
            }
            else
            {
              var item = filter[filterFound];
              item[cFilterArrayPosCount]++;
              item[cFilterArrayPosElapsed] += elapsedTime;
            }
          }

          var list = [cTypeResult, versionApp, project, wuName, elapsedS, cpuS, fractionS,status];
          resultsArray.add(list);
        } // for
//      }catch(error, s)
//      {
//        gLogging.addToLoggingError('Results (process for) $error,$s');        
//        resultsArray = [];
//      }      
//      try{
      // add filters
      var filterLen = filter.length;
      for (var f=0;f< filterLen;f++)
      {
        var itemf = filter[f];
        if (itemf[cFilterArrayPosCount] == 1)
        {
          // ignore: unused_local_variable
          var ii = 1;
        }
        if (itemf[cFilterArrayPosCount] > 1) // nr of wu in filter
        {
          var statusRemove = filter[f][cFilterArrayPosId]; // like Fred7.61Mapping Cancer MarkersReady to report | user active
          var filterRemoveActive = false;
          if (statusRemove == filterRemove)
          {
            filterRemoveActive = true;
          }

          // remove all wu in filter
          var filterWu = [];

          var lenResults = resultsArray.length;
          for (var i=0;i< lenResults;i++)
          {
            var itemRemove = resultsArray[i];
            if (itemRemove[cTasksPosType] == cTypeResult)
            {
              var filter = computer+itemRemove[cTasksPosApp]+itemRemove[cTasksPosStatus];
              if (filter == statusRemove)
              {
                if (filterRemoveActive)
                {
                  // if the filter is active copy the wu first before removing.
                  filterWu.add(resultsArray[i]);
                }                
                resultsArray.removeAt(i);  
                i -= 1;              
                lenResults -=1;
              }
            }
          }
          //var fractionDone = 
          var elapsedS = getFormattedTimeInterval(itemf[cFilterArrayPosElapsed].round()); 
          var filterCnt = itemf[cFilterArrayPosCount];
          var list = [cTypeFilter, itemf[2], itemf[3], "▼$cTextFilter$filterCnt", elapsedS, itemf[cFilterArrayPosCpu], itemf[cFilterArrayPosProgress], itemf[cFilterArrayPosStatus], null];
          var lenfa = filterWu.length;
          if (lenfa == 0)
          {
            resultsArray.add(list);
          }
          else
          {
            var filterArray = [];
            for (var fa=0;fa<lenfa;fa++)
            {
              var itemfw = filterWu[fa];
              var list = [cTypeFilterWU, itemfw[cFilterArrayPosCount], itemfw[2], itemfw[3], itemfw[4], itemfw[5], itemfw[cTasksPosProgress], itemfw[cTasksPosStatus]];
              filterArray.add(list);           
            }
            list = [cTypeFilter, itemf[2], itemf[3], "▼$cTextFilter$filterCnt", elapsedS, itemf[cFilterArrayPosCpu], itemf[cFilterArrayPosProgress], itemf[cFilterArrayPosStatus],filterArray];
            resultsArray.add(list); // keep the filter items sepperate for correct sorting.
          }
        }
      }
    }catch(error, s)
    {
      gLogging.addToLoggingError('Results (process filter) $error,$s');        
      resultsArray = [];
    }
    }catch(error, s)
    {
      gLogging.addToLoggingError('Results (process) $error,$s');        
      resultsArray = [];
    }  
  return resultsArray;
  }

  getStatus(item, ccStatus, hp, state)
  {
    const suspendReasonBatteries = 1;
    const suspendReasonUserActive = 2;
    const suspendReasonUserReq = 4;
    const suspendReasonTimeOfDay = 8;
    const suspendReasonBenchmarks = 16;
    const suspendReasonDiskSize = 32;
    const suspendReasonCpuThrottle = 64;
    const suspendReasonNoRecentInput = 128;
    const suspendReasonInitialDelay = 256;
    const suspendReasonExclusiveAppRunning = 512;
    const suspendReasonCpuUsage = 1024;

    var statusS = "";
//    var statusN = -1;
//    var bReport = false;
    var bSuspend = false;
    try {
      var suspendReason = ccStatus['task_suspend_reason']['\$t'];
        var iSuspendReason = int.parse(suspendReason);      
        var sSuspendReason = "";

        if (iSuspendReason > 0)
        {
            bSuspend = true;

            if (iSuspendReason & suspendReasonBatteries > 0)			    { sSuspendReason += "on batteries";}
            if (iSuspendReason & suspendReasonUserActive > 0)		      { sSuspendReason += 'user active';}
            if (iSuspendReason & suspendReasonUserReq > 0)				    { sSuspendReason += 'user request';}
            if (iSuspendReason & suspendReasonTimeOfDay > 0)			    { sSuspendReason += 'time of day';}
            if (iSuspendReason & suspendReasonBenchmarks > 0)			    { sSuspendReason += 'benchmarks';}
            if (iSuspendReason & suspendReasonDiskSize> 0 )				    { sSuspendReason += 'disk size';}
            if (iSuspendReason & suspendReasonCpuThrottle > 0)		    { sSuspendReason += "-";}
            if (iSuspendReason & suspendReasonNoRecentInput > 0)	    { sSuspendReason += 'no recent input';}
            if (iSuspendReason & suspendReasonInitialDelay > 0)		    { sSuspendReason += 'initial delay';}
            if (iSuspendReason & suspendReasonExclusiveAppRunning > 0){ sSuspendReason += 'exclusive app running';}
            if (iSuspendReason & suspendReasonCpuUsage > 0)				    { sSuspendReason += 'CPU usage';}     
            
            if (sSuspendReason == "")
            {
                sSuspendReason += 'Unknown suspend reason';
            }
        }

        if (item.containsKey('too_large'))
        {
            bSuspend = true;
            sSuspendReason += ' mem too large';
        }
        if (item.containsKey('needs_shmem'))
        {
            bSuspend = true;
            sSuspendReason += ' mem need shmem';
        }
        if (item.containsKey('gpu_mem_wait'))
        {
            bSuspend = true;
            sSuspendReason += ' mem GPU';
        }        
        if (item.containsKey('scheduler_wait'))
        {
            bSuspend = true;            
            sSuspendReason = item['scheduler_wait_reason'].toString();
        }

        switch (state) {
            case "0122":
            case "122":
            case "0922":
                if (bSuspend)
                {
                    statusS = txtTasksSuspended;
                   // statusN = btC.TASK_STATUS_SUSPENDED_N;                 
                }
                else
                {
                    statusS = txtTasksRunning;
                   // statusN = btC.TASK_STATUS_RUNNING_N;
                }
            case "0001":
                statusS = txtTasksDownloading;
                //statusN = btC.TASK_STATUS_DOWNLOADING_N;            
            case "0002":
                statusS = txtTasksReadyToStart;
                //statusN = btC.TASK_STATUS_READY_START_N;
            case "0003":
                statusS = txtTasksComputationError;
                //statusN = btC.TASK_STATUS_COMPUTATION_N;
                //bReport = true;
            case "0004":
                statusS = txtTasksUploading;
                //statusN = btC.TASK_STATUS_UPLOADING_N;
            case "0005":               
                statusS = txtTasksReadyToReport;
                //statusN = btC.TASK_STATUS_READY_REPORT_N;
               // bReport = true;
            case "0012":
            case "0812": 
            case "0912":
                statusS = txtTasksWaitingToRun;
                //statusN = btC.TASK_STATUS_WAITING_N;
            case "0022": 
            case "1922":
            case "922":
                statusS = txtTasksSuspended;
                //statusN = btC.TASK_STATUS_SUSPENDED_N;        
            case "005":
            case "002":
            case "912":
            case "022":
            case "012":
            case "812":
            case "1002":
            case "1012":
            case "1812":
            case "1912":
            case "1005":
                statusS = txtTasksSuspendedByUser;
                //statusN = btC.TASK_STATUS_SUSPENDED_USER_N;
            case "0006":
                statusS = txtTasksAborted;
                //statusN = btC.TASK_STATUS_ABORT_N; 
                //bReport = true;           
            default: statusS = "State: $state";
        }
//        resultItem.report = bReport;
//        resultItem.statusI = status;                
//        resultItem.statusN = statusN;         
        if (hp == '1') 
        {
            statusS += ',Hp';
//            resultItem.hp = true;
        }
        else
        {
//            resultItem.hp = false;
        }

        if (sSuspendReason == "" )
        {
//        resultItem.statusS = status;            
          return statusS;
        }
        statusS += " | $sSuspendReason";            
    } catch (error,s) {
        gLogging.addToLoggingError('Results (getStatus) $error, $s');    
    }    
    return statusS;
  }
  
}
