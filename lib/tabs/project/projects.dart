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
import 'package:boinctasks/tabs/misc/header.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';

class Projects {
  var cInit = "Initializing....";

  var mProjectTable = [];


  updateHeader(columnText, columnWidth, newWidth,bWrite)
  {
    gHeaderInfo.mHeaderProjectsWidth[columnWidth] = newWidth; 
    if (bWrite)
    {
      gHeaderInfo.writeProjects();      
    }
  }

  getHeaderProjects()
  {
    headerProjectsMinMax();
    var tableItem = {
      cHeaderTab:cTypeProject,
      'col_1':txtHeaderComputer,
      'col_1_w': gHeaderInfo.mHeaderProjectsWidth['col_1_w'],
      'col_1_n' :false,  
      'col_2':txtHeaderProject,
      'col_2_w': gHeaderInfo.mHeaderProjectsWidth['col_2_w'], 
      'col_2_n' :false,  
      'col_3':txtProjectHeaderShare,
      'col_3_w': gHeaderInfo.mHeaderProjectsWidth['col_3_w'],
      'col_3_n' :false,        
      'col_4':txtProjectHeaderStatus,
      'col_4_w': gHeaderInfo.mHeaderProjectsWidth['col_4_w'] ,
      'col_4_n' :false,
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
      header = getHeaderProjects();
      var lenSel = selected.length;      

      var len = retProcess.length;
      for (var i=0;i<len;i++)
      {
        //var tableItem = [];
        var item = retProcess[i];
        // var status = item[3];
        
        var color = gSystemColor.rowColor;
        var colorText = gSystemColor.rowColorText;     

        for(var s=0;s<lenSel;s++)
        {          
          if (item[cProjectsPosProject] == selected[s][cProjectsProject])
          {
            color = gSystemColor.rowColorSel;
            colorText = gSystemColor.rowColorTextSel;
            break;
          }
        }

//        if (i.isEven)
//        {
//          color = lighten(color);
//        }
        rows.add({
          'row' : i,
          'color' : color,
          'colorStatus': color,          
          'colorText': colorText,
          'type':item[0], // type project
          'computer':computer,
          'col_1':computer,
          'col_2':item[1],
          'col_3':item[2],
          'col_4':item[3],
        });
      }
    } catch (error,s) {
      gLogging.addToLoggingError('Projects (newData) $error,$s'); 
    }
    ret.add(header);    
    ret.add(rows);
    mProjectTable = ret;    
    return ret;
  }

  process(computer, state, data)
  {
    var projectsArray = [];  
    try{
      if (data != null)
      {
        var project = data['projects']['project'];
        if (project != null)
        {
          var len = project.length;
          for (var i=0;i<len;i++)
          {
            var item =  project[i];
            if (item == null)
            {
              item = project; // when we have a single project
              i = len;
            }
            var projectName = "Initializing...";
            var projectUrl = item['master_url']['\$t'];  

            var ret = state.getProject(projectUrl);
            if (ret != null)
            {
              projectName = ret;
            }

    //       var account = item['user_name']['\$t']; 
            var team = item['team_name']['\$t']; 
            team ??= "";
    //       var credits = double.parse(item['user_total_credit']['\$t']);
    //       var creditsAvg = double.parse(item['user_expavg_credit']['\$t']);
    //       var creditsHost = double.parse(item['host_total_credit']['\$t']);
    //       var creditsHostAvg = double.parse(item['host_expavg_credit']['\$t']);                
            var sharei = double.parse(item['resource_share']['\$t']);
            var share = sharei.toStringAsFixed(3);

    //       var rec = double.parse(item['rec']['\$t']);
            var venue = item['host_venue']['\$t'];
            venue ??= "";
            var status = getStatus(item);
          
            var list = [cTypeProject, projectName, share, status];
            projectsArray.add(list);
          }
        }
      }
    }catch(error,s)
    {
      gLogging.addToLoggingError('Projects (process) $error,$s');
      projectsArray = [];
    }
    return projectsArray;
  }    
  
  getStatus(item)
  {
    var status = ""; 
    try {
        if (item.containsKey('suspended_via_gui'))
        {
            status += "Suspended ";
        }

        if (item.containsKey('dont_request_more_work'))
        {
            status += "No new work ";
        }

        if (item.containsKey('scheduler_rpc_in_progress'))
        {
           status += "In progress ";
        }

        if (item.containsKey('min_rpc_time'))
        {
            var minRrpcTimeS = item['min_rpc_time']['\$t'];
            var minRrpcTime = double.parse(minRrpcTimeS).round();        
            if (minRrpcTime > 0)
            {
                var deferred  = getFormattedTimeDiff(minRrpcTime,true);
                if (deferred != "") // can be negative...
                {
                    status += "Deferred for: $deferred ";
                }
            }
        }
        
        if (item.containsKey('sched_rpc_pending'))
        {
          var pending = int.tryParse(item['sched_rpc_pending']['\$t']) ?? 0;
          switch(pending)
          {
            case 0:
                // nothing
            break;
            case 1:
                status += "Updating";
            break;
            case 2:
                status += "Report completed tasks";
            break;
            case 3:
                status += "Fetch work";
            break;
            case 4:
                status += "Send trickle-up";
            break;
            case 5:
                if (item.containsKey('attached_via_acct_mgr'))
                {
                    status += "Updating account manager";
                }
                else
                {
                    status += "Initializing";
                }
            break;
            case 6:
                status += "Attaching to project";
            break;
            case 7:
                var key = 'scheduler_rpc_in_progress';
                if (item.containsKey(key))
                {
                  var rpcInProgressI = item['scheduler_rpc_in_progress'];
                  var rpcInProgress = int.parse(rpcInProgressI);
                  if (rpcInProgress == 0)
                  {
                    status += "Request by project";
                  }
                }
            break;
            default:
                status += "?? $pending";      
          }
        }
    }catch (error,s) {
      gLogging.addToLoggingError('Projects (getStatus) $error,$s');    
    }
    return status;
  }
}