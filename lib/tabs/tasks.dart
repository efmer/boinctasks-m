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

import 'package:boinctasks/dialog/color/dlg_color.dart';
import 'package:boinctasks/functions.dart';
import 'package:boinctasks/tabs/header/arrange_header.dart';
import 'package:boinctasks/tabs/header/header.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import '../constants.dart';

class Tasks {
  var cInit = "Initializing....";
  var cStateUpdate = "State needs to update";

  var mTasksTable = [];

  void updateHeader(String columnText, columnWidth, newWidth,bWrite)
  {
    var id = gArrange.getKeyWidth(columnWidth);

    gHeaderInfo.mHeaderTasksWidth[id] = newWidth; 
    if (bWrite)
    {
      gHeaderInfo.writeTasks();
    }
  }

  List getHeaderTasksArray()
  {
    List table = [];

    var width = 0.0;
    var listE  = gArrange.getFullListEnable();
    if (listE[0]){ width = gHeaderInfo.mHeaderTasksWidth['col_1_w']; }
    else { width = 0.0; }
    table.add([ 
      txtHeaderComputer,
      width,
      false,
      cHeaderNormal,
      cHeaderNoPerc,
    ]);

    if (listE[1]){ width = gHeaderInfo.mHeaderTasksWidth['col_2_w']; }
    else { width = 0.0; }
    table.add([ // 2
      txtTasksHeaderApp,
      width,
      false,
      cHeaderNormal,
      cHeaderNoPerc,
    ]);

    if (listE[2]){ width = gHeaderInfo.mHeaderTasksWidth['col_3_w']; }
    else { width = 0.0; }    
    table.add([ // 3 
      txtHeaderProject,
      width,
      false,
      cHeaderNormal,
      cHeaderNoPerc,      
    ]);    

    if (listE[3]){ width = gHeaderInfo.mHeaderTasksWidth['col_4_w']; }
    else { width = 0.0; }      
    table.add([ // 4 
      txtTasksHeaderName,
      width,
      false,
      cHeaderNormal,
      cHeaderNoPerc,      
    ]);

    if (listE[4]){ width = gHeaderInfo.mHeaderTasksWidth['col_5_w']; }
    else { width = 0.0; }
    table.add([ // 5  
      txtTasksHeaderElapsed,
      width,
      false, 
      cHeaderNormal,
      cHeaderNoPerc,      
    ]);

    if (listE[5]){ width = gHeaderInfo.mHeaderTasksWidth['col_6_w']; }
    else { width = 0.0; }
    table.add([ // 6 
      txtTasksHeaderCpu,      
      width,
      false,
      cHeaderNormal,
      cHeaderPerc 
    ]);     

    if (listE[6]){ width = gHeaderInfo.mHeaderTasksWidth['col_7_w']; }
    else { width = 0.0; }     
    table.add([ // 7 
      txtTasksHeaderProgress,
      width,
      true,
      cHeaderNormal,
      cHeaderPerc,
    ]);

    if (listE[7]){ width = gHeaderInfo.mHeaderTasksWidth['col_8_w']; }
    else { width = 0.0; }
    table.add([ // 8
      txtHeaderStatus,
      width,
      false,
      cHeaderStatus,
      cHeaderNoPerc,      
    ]);

    if (listE[8]){ width = gHeaderInfo.mHeaderTasksWidth['col_9_w']; }
    else { width = 0.0; }
    table.add([ // 9
      txtTasksHeaderTimeLeft,
      width,
      false,
      cHeaderNormal,
      cHeaderNoPerc,      
    ]);

    if (listE[9]){ width = gHeaderInfo.mHeaderTasksWidth['col_10_w']; }
    else { width = 0.0; }
    table.add([ // 10
      txtTasksHeaderDeadline,
      width,
      false,
      cHeaderNormal,
      cHeaderNoPerc,      
    ]);

    if (listE[10]){ width = gHeaderInfo.mHeaderTasksWidth['col_11_w']; }
    else { width = 0.0; }
    table.add([ // 11
      txtTasksHeaderUse,
      width,
      false,
      cHeaderNormal,
      cHeaderNoPerc
    ]);                  
    return table;
  }

// _w width, _n number in sorting
  Map<String, dynamic> getHeaderTasks()
  {
    headerTasksMinMax();
    var table = getHeaderTasksArray();
    var tableItem = <String, dynamic> {cHeaderTab:cTypeResult};

    var len = table.length;
    for (var i=0;i<len;i++)
    {
      var ii = gArrange.getList(i);
      var ik = i+1;
      var key = "col_$ik";
      var keyw = "${key}_w";
      var keyn = "${key}_n";
      var keys = "${key}_s";
      var keyp = "${key}_p";        
      List item = List.of(table[ii]);
      var data = item[0];
      tableItem.addEntries({key:data}.entries);
      data = item[1];
      tableItem.addEntries({keyw:data}.entries);
      data = item[2];
      tableItem.addEntries({keyn:data}.entries);
      data = item[3];
      bool bStatus = false;
      if (data == cHeaderStatus)
      {
        bStatus = true;
      }
      tableItem.addEntries({keys:bStatus}.entries); 
      
      data = item[4];
      if (data == cHeaderPerc)
      {
        tableItem.addEntries({keyp:true}.entries);
      }     
    }
    return tableItem;
  }

  List arrangeTasks(List list)
  {
    var table = [];
    var len = list.length;
    for (var i=0;i<len;i++)
    {
      var ii = gArrange.getList(i);  
      table.add(list[ii]);
    }
    return table;
  }

  List newData(dynamic statec, computer, filterRemove, selected, ccStatusIn, data)
  {
    var header = {};
    var rows = [];
    var ret = [];
    try{
        var retProcess = process(statec, computer, filterRemove, ccStatusIn, data);
        header = gArrange.getArrangeTaskHeader(getHeaderTasks());
    
        var lenSel = selected.length;
        var lenResults = 0;

        if (retProcess.isNotEmpty)
        {
          lenResults = retProcess[0];
          retProcess.removeAt(0);
        }

        var len = retProcess.length;
        if (gRpc.isCollapsed(computer))
        {
          ret.add(header);
          var colorText = gColorList[indexColorTasksText];
          var color = gColorList[indexColorTasksCollapsed];
          var colorStatus = gColorList[indexColorTasksCollapsed];   

          var table =
          [
            computer,          
            lenResults.toString(),
            "",
            "▼ Open",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
          ];
          var tableA = arrangeTasks(table);

          rows.add({          
            'row': -1,
            'color': color,
            'colorStatus': colorStatus,
            'colorText': colorText,
            'type': cTypeResultCollapsed,
            'computer':computer,
            'col_1':tableA[0],          
            'col_2':tableA[1],  
            'col_3':tableA[2],  
            'col_4':tableA[3],  
            'col_5':tableA[4],  
            'col_6':tableA[5],  
            'col_7':tableA[6],  
            'col_8':tableA[7],   
            'col_9':tableA[8],   
            'col_10':tableA[9],   
            'col_11':tableA[10],                                             
            'filter': [],
          });           
          ret.add(rows);          
          mTasksTable = ret;
          return ret;
        }

        for (var i=0;i<len;i++)
        {
          var item = retProcess[i];
          var retf = processItem(item,i,lenSel,selected);
          var color = retf[0];
          var colorText = retf[1];
          var colorStatus = retf[2];
      
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
                var colorStatusf = retwu[2];

                var table =
                [
                  computer,
                  itemf[cTasksPosApp],
                  itemf[cTasksPosProject],
                  itemf[cTasksPosName],
                  itemf[cTasksPosElapsed],
                  itemf[cTasksPosCpu],
                  itemf[cTasksPosProgress],
                  itemf[cTasksPosStatus],
                  itemf[cTasksPosTimeLeft],
                  itemf[cTasksPosDeadline],
                  itemf[cTasksPosUse],
                ];

                var tableA = arrangeTasks(table);

                frows.add({          
                  'row': i,
                  'color': colorf,
                  'colorText': colorTextf,
                  'colorStatus': colorStatusf,
                  'type': cTypeResult,
                  'computer':computer,
                  'col_1':tableA[0],
                  'col_2':tableA[1],
                  'col_3':tableA[2],
                  'col_4':tableA[3],
                  'col_5':tableA[4],
                  'col_6':tableA[5],
                  'col_7':tableA[6],
                  'col_8':tableA[7],
                  'col_9':tableA[8],
                  'col_10':tableA[9],
                  'col_11':tableA[10],
                });      
              }
              filter = frows; // add the wu to the filter
              type = cTypeFilterWuArr; // filter with wu array
            }
          }

          var table =
          [
            computer,          
            item[cTasksPosApp],
            item[cTasksPosProject],
            item[cTasksPosName],
            item[cTasksPosElapsed],
            item[cTasksPosCpu],
            item[cTasksPosProgress],
            item[cTasksPosStatus],
            item[cTasksPosTimeLeft],
            item[cTasksPosDeadline],
            item[cTasksPosUse],
          ]; 

          var tableA = arrangeTasks(table);

          rows.add({          
            'row': i,
            'color': color,
            'colorStatus': colorStatus,
            'colorText': colorText,
            'type': type,
            'computer':computer,
            'col_1':tableA[0],
            'col_2':tableA[1],
            'col_3':tableA[2],
            'col_4':tableA[3],
            'col_5':tableA[4],
            'col_6':tableA[5],
            'col_7':tableA[6],
            'col_8':tableA[7],
            'col_9':tableA[8],
            'col_10':tableA[9],
            'col_11':tableA[10],              
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

    List<Color> processItem(dynamic item,i,lenSel,selected)
    {
      var colorText = gColorList[indexColorTasksText];
      var color = const Color.fromARGB(255, 234, 234, 234);   
      var colorStatus = const Color.fromARGB(255, 234, 234, 234);         
      var ret = [color,colorText,colorStatus];

      try{
        var status = item[cTasksPosStatus]; 
        if (status.contains(txtTasksSuspended)) {
          color = gColorList[indexColorTasksSuspendedBack];
        }else {
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
                          if (status.contains(txtTasksAborted)){
                            color = gColorList[indexColorTasksAbortedBack];
                           }                       
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }  
        bool bStatusColor = false;
        if (status.contains(txtTasksHighPriority)){
          colorStatus = gColorList[indexColorTasksHighPriorityBack];
          bStatusColor = true;
        }
        else
        {
          if (status.contains(txtTasksDeadline)){
            colorStatus = gColorList[indexColorTasksHighPriorityBack];
            bStatusColor = true;            
          }
        }

        for(var s=0;s<lenSel;s++)
        {
          if (item[cTasksPosName] == selected[s][cTasksWu])
          {
            if (gbDarkMode)
            {
              color = const Color.fromARGB(255, 255, 255, 255);
              colorText = const Color.fromARGB(255, 68, 68, 68);
              colorStatus = color;
              bStatusColor = false;
              break;
            }
              color = const Color.fromARGB(255, 68, 68, 68);
              colorStatus = color;              
              colorText = const Color.fromARGB(255, 255, 255, 255);
              bStatusColor = false;              
              break;
          }
        }
        if (!bStatusColor)
        {
          colorStatus = color;
        }
        ret = [color,colorText,colorStatus];
    } catch (error,s) {
      gLogging.addToLoggingError('Results (newData) $error,$s'); 
    }    
    return ret;
  }

  List process(dynamic statec, computer, filterRemove, ccStatusIn, data)
  {
    var resultsArray = [];
    var len = 0;    
    try{
      if (ccStatusIn == null)
      {
        return resultsArray;
      }

      var filter = [];
      var result = data['results']['result'];
      var ccStatus = ccStatusIn['cc_status'];
      if (result == null)
      {
        return resultsArray;
      }
   
      try{          
        len = result.length;
        for (var i=0;i<len;i++)
        {
          var item =  result[i];
          if (item == null) // a single item
          {
            item = result;
            i = len+1; 
            len = 1;             
          }
          var version = int.parse(item['version_num']['\$t']) / 100;
          var wu = item['wu_name']['\$t'];
          var wuName = item['name']['\$t'];
          var projectUrl = item['project_url']['\$t'];
          var app = statec.getAppUfriendly(wu);
          var cpuTime = double.parse(item['final_cpu_time']['\$t']);
          var project = statec.getProject(projectUrl);
          var versionApp = "$version $app";
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

            sState = active['scheduler_state']['\$t'];
            aState = active['active_task_state']['\$t'];

            cpuTime = double.parse(active['current_cpu_time']['\$t']);
          }
          else
          {
   //         elapsedTime = 0.0;
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

          var timeLeftS = "";
          var timeLeftD = 0.0;
          var remaining = item['estimated_cpu_time_remaining']['\$t'];
          if (remaining.isNotEmpty)
          {
            timeLeftD = double.parse(remaining);
            timeLeftS = getFormattedTimeInterval(timeLeftD.round());
          }

          var deadline = item['report_deadline']['\$t'];
          var deadlineD = double.parse(deadline);
          var deadlineS = getFormattedTimeDiff(deadlineD.round(),false);

          var use = "";
          if (item.containsKey('resources'))   
          {       
            var resources = item['resources']['\$t'];
            if (resources.length > 0)
            {
              use = getCpuGpu(resources);
            }
          }
        
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
              item.add(timeLeftS);
              item.add(deadlineS);
              item.add(use);                            

              filter.add(item);
            }
            else // the filter line with Filter nr
            {
              var item = filter[filterFound];
              item[cFilterArrayPosCount]++;
              item[cFilterArrayPosElapsed] += elapsedTime;         
            }
          }

          var list = [cTypeResult, versionApp, project, wuName, elapsedS, cpuS, fractionS,status,timeLeftS,deadlineS,use];
          resultsArray.add(list);
        }
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
            var list = [cTypeFilter, itemf[2], itemf[3], "▼$cTextFilter$filterCnt", elapsedS, itemf[cFilterArrayPosCpu], itemf[cFilterArrayPosProgress], itemf[cFilterArrayPosStatus], itemf[cFilterArrayPosTimeLeft], itemf[cFilterArrayPosDeadline], itemf[cFilterArrayPosUse],null];
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
                var list = [cTypeFilterWU, itemfw[cFilterArrayPosCount], itemfw[2], itemfw[3], itemfw[4], itemfw[5], itemfw[cTasksPosProgress], itemfw[cTasksPosStatus], itemfw[cTasksPosTimeLeft], itemfw[cTasksPosDeadline], itemfw[cTasksPosUse]];
                filterArray.add(list);           
              }
              list = [cTypeFilter, itemf[2], itemf[3], "▲$cTextFilter$filterCnt", elapsedS, itemf[cFilterArrayPosCpu], itemf[cFilterArrayPosProgress], itemf[cFilterArrayPosStatus], itemf[cFilterArrayPosTimeLeft], itemf[cFilterArrayPosDeadline], itemf[cFilterArrayPosUse],filterArray];
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
  resultsArray.insert(0, len);
  return resultsArray;
  }

  String getCpuGpu(String res)
  {
    if ((res.contains("GPU")) || (res.contains("CUDA")))
    {
      res = res.replaceAll(" CPUs","C");
      res = res.replaceAll(" CPU", "C");
      res = res.replaceAll(".00","");
      res = res.replaceAll(" NVIDIA GPUs","NV");
      res = res.replaceAll(" NVIDIA GPU","NV");
      res = res.replaceAll(" Nvidia GPU", "NV");
      res = res.replaceAll(" ATI GPUs","AMD");
      res = res.replaceAll(" AMD/ATI GPU", "AMD");
      res = res.replaceAll(" AMD / ATI GPU", "AMD");
    
      res = res.replaceAll(" intel GPU", "INT");
      res = res.replaceAll(" intel_gpu GPU","INT");
      res = res.replaceAll(" Intel GPU", "INT");
      res = res.replaceAll("device ","d");
      res = res.replaceAll("Device ", "d");
    }
    else
    {
      if (res.contains("Apple"))
      {
        res = res.replaceAll("Apple ", "A ");
      }
    }

    return res;
  }

  String getStatus(dynamic item, ccStatus, hp, state)
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

            if (iSuspendReason & suspendReasonBatteries > 0)			   { sSuspendReason += "on batteries";}
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
                }
                else
                {
                    statusS = txtTasksRunning;
                }
            case "0001":
                statusS = txtTasksDownloading;          
            case "0002":
                statusS = txtTasksReadyToStart;
            case "0003":
                statusS = txtTasksComputationError;
            case "0004":
                statusS = txtTasksUploading;
            case "0005":               
                statusS = txtTasksReadyToReport;
            case "0012":
            case "0812": 
            case "0912":
                statusS = txtTasksWaitingToRun;
            case "0022": 
            case "1922":
            case "922":
                statusS = txtTasksSuspended;      
            case "005":
            case "002":
            case "912":
            case "022":
            case "012":
            case "812":
            case "1002":
            case "1004":
            case "1005":            
            case "1012":
            case "1022":            
            case "1812":
            case "1912":
                statusS = txtTasksSuspendedByUser;
            case "0006":
                statusS = txtTasksAborted;      
            default: statusS = "State: $state";
        }      
        if (hp == '1') 
        {
            statusS += ",$txtTasksHighPriority";
        }

        try {
          if (gdeadline != cSetTabDeadlineNever)
          {
            var deadlineSet = double.parse(gdeadline)*86400;
            
            if (item.containsKey('report_deadline'))
            {
              var deadline = double.parse(item['report_deadline']['\$t']).round();
              var current = (DateTime.now().millisecondsSinceEpoch/1000).round();
              var diff = (deadline - current).round(); // day
              
              if (diff < deadlineSet)
              {
//              var timeTxt = getFormattedTimeInterval(diff); // do not ad time it messes up the filters.
                statusS += txtTasksDeadline;
              }
            }
          }
        } catch (error,s) {
          gLogging.addToLoggingError('Results (getStatus deadline) $error, $s');    
        }  

        if (sSuspendReason == "" )
        {          
          return statusS;
        }
        statusS += " | $sSuspendReason";            
    } catch (error,s) {
        gLogging.addToLoggingError('Results (getStatus) $error, $s');    
    }    
    return statusS;
  }
  
}
