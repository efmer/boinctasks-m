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
import 'package:boinctasks/main.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Properties {
  bool mbFirst = true;
  // ignore: prefer_typing_uninitialized_variables
  var mSelected;
  // ignore: prefer_typing_uninitialized_variables
  var mRpc;
  // ignore: prefer_typing_uninitialized_variables
  var mState;
  List<DataRow> mRows = [];
  String mRowsTxt = "";

  first()
  {
    mbFirst = true;    
    mRows = [];
    mRowsTxt = "";
  }

  properties(context,tab,computer,selected, rpc)
  {
    try{
      mSelected = selected;
      mRpc = rpc;
      mState = rpc.mState;

      switch (tab)
      {
        case cTabTasks:
          taskProperties(context,computer);
        case cTabProjects:
          projectProperties(context,computer);
      }            
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('Properties (properties) $error,$s'); 
    }      

  }

  last(context)
  {
    propertiesShowDialog(context); 
  }

  taskProperties(context,computer)
  {
    var len = mSelected.length;
    for (var i=0;i<len;i++)             
    {
      if (!mbFirst)
      {
        addInfo("==============", "==============");  
      }

      var sel = mSelected[i];
      var  wu = sel['wu'];
      addInfo("Computer",computer);
      var project = sel[cTasksProject];
      var projectUrl = mState.getProjectUrl(project);
      addInfo("Project", "$projectUrl, project");

      if (wu.contains(cTextFilter))
      {
        addInfo("Error", "You can not add a filter, Open the filter");      
        return;
      }

      var retWu = mState.getWuName(wu);
      var name = retWu['name']['\$t'];
      var wuName = retWu['wu_name']['\$t'];
      var version = retWu['version_num']['\$t'];
      var retApp =  mState.getAppUfriendly(wuName);
      var appUf = retApp['user_friendly_name']['\$t'];
      var app = retApp['name']['\$t'];      
      addInfo("Application", "$app,  $appUf");
      addInfo("App Version", version);
      addInfo("Wu","$name, $wuName");

      
      var tasks = mRpc.mtasksClass;
      var table = tasks.mTasksTable;
      var tableList = table[1];

      var lenTable = tableList.length;
      for (i=0;i<lenTable;i++)
      {
        if (tableList[i]["col_4"] == name) 
        {
          var tableHeader = table[0];
          var col5h = tableHeader["col_5"];
          var col5l = tableList[i]["col_5"];
          addInfo(col5h, col5l);      
          var col6h = tableHeader["col_6"];
          var col6l = tableList[i]["col_6"];
          addInfo(col6h, col6l);
          var col7h = tableHeader["col_7"];
          var col7l = tableList[i]["col_7"];
          addInfo(col7h, col7l);
          var col8h = tableHeader["col_8"];
          var col8l = tableList[i]["col_8"];       
          addInfo(col8h, col8l);
        }
      }
      var receivedS = getFormattedTimeFullKey(retWu, "received_time");
      addInfo("Recieved", receivedS);       
      var remainingS = getFormattedTimeIntervalKey(retWu,"estimated_cpu_time_remaining");
      addInfo("Remaining", remainingS); 
      var deadlineS = getFormattedTimeFullKey(retWu,"report_deadline");
      addInfo("Deadline", deadlineS);      

      mbFirst = false;
    }
  }

  projectProperties(context,computer)
  {
  var len = mSelected.length;
    for (var i=0;i<len;i++)             
    {
      if (!mbFirst)
      {
        addInfo("==============", "==============");  
      }

      var sel = mSelected[i];
      var item = mState.getProjectName(sel["project"]);
      var projectName = item["project_name"]['\$t'];      
      addInfo("Project name", projectName);  

      var projects = mRpc.mprojectsClass;
      var table = projects.mProjectTable;
      var tableList = table[1];

      var lenTable = tableList.length;
      for (i=0;i<lenTable;i++)
      {
        if (tableList[i]["col_2"] == projectName) 
        {
          var tableHeader = table[0];
          var col3h = tableHeader["col_3"];
          var col3l = tableList[i]["col_3"];
          addInfo(col3h, col3l);      
          var col4h = tableHeader["col_4"];
          var col4l = tableList[i]["col_4"];
          addInfo(col4h, col4l);
        }
      }


      var masterUrl = item["master_url"]['\$t'];
      addInfo("Url", masterUrl);
      var userName = item["user_name"]['\$t'];
      addInfo("Usere name", userName);        
      var teamName = item["team_name"]['\$t'];
      addInfo("Team", teamName);        
      var hostVenue = item["host_venue"]['\$t'];
      addInfo("Venue", hostVenue);        
      var userTotalCredit = item["user_total_credit"]['\$t'];
      addInfo("User total credit", userTotalCredit);        
      var userExpavgCredit = item["user_expavg_credit"]['\$t'];
      addInfo("User average credit", userExpavgCredit);        
      var hostTotalCredit = item["host_total_credit"]['\$t'];
      addInfo("Host total credit", hostTotalCredit);        
      var hostExpavgCredit = item["host_expavg_credit"]['\$t'];      
      addInfo("Host average credit", hostExpavgCredit);        

/*
prop += addInfo("Project name", project.project_name);
                prop += addInfo("Master Url", project.master_url);
                prop += addInfo("Directory", project.project_dir);                
                prop += addInfo("Cross project ID", project.cross_project_id);
                prop += addInfo("User name", project.user_name);
                prop += addInfo("Team", project.team_name);
                prop += addInfo("Venue", project.host_venue);
                prop += addInfo("Resource share", project.resource_share);

                prop += addInfo("Jobs completed", project.njobs_success);
                prop += addInfo("Jobs error", project.njobs_error);
                prop += addInfo("Jobs failure", project.nrpc_failures);
                prop += addInfo("Host id", project.hostid);
                prop += addInfo("User id", project.userid);
                prop += addLine();

                prop += addInfo("Duration correction factor", project.duration_correction_factor);
                prop += addInfo("Scheduling priority", project.sched_priority);

                prop += addLine();
                prop += addInfo("Disk desired", project.desired_disk_usage);
                prop += addInfo("Disk shared", project.disk_share);
                prop += addInfo("Disk usage", project.disk_usage);
                prop += addLine();

                prop += addInfo("User avg credit", project.user_expavg_credit);
                prop += addInfo("User total credit", project.user_total_credit);
                prop += addInfo("Host avg credit", project.host_expavg_credit);
                prop += addInfo("Host total credit", project.host_total_credit);
              }
              */

      mbFirst = false;
    }
  }

  addInfo(item1,item2)
  {
    mRows.add(
      DataRow(cells: <DataCell>[
        DataCell(Text(item1)),
        DataCell(Text(item2)),
      ]),
    );
      mRowsTxt += "\n$item1  $item2";    
  }

  propertiesShowDialog(context)
  async {          
        showDialog(
        context: context,
        builder: (myApp) {     
          return ShowPropertiesDlg(title: 'Properties', rows: mRows, rowsTxt: mRowsTxt,);
        }
      );        
  }
}

class ShowPropertiesDlg extends StatefulWidget {
  const ShowPropertiesDlg({super.key, required this.title, required this.rows,required this.rowsTxt});
  final String title;
  final List<DataRow> rows;
  final dynamic rowsTxt;
  
  @override
  State<StatefulWidget> createState() {
    return _ShowPropertiesState();
  }

  clipboardCopy()
  {
    Clipboard.setData(ClipboardData(text: rowsTxt));
  } 
}

class _ShowPropertiesState extends State<ShowPropertiesDlg> {
  final ScrollController _controller = ScrollController();
  @override
  void initState() { 
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),      
      body: Center(
        child: SingleChildScrollView(
          controller: _controller,   
          scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,               
              child: DataTable(columns: [
              DataColumn(label: Text('')),
              DataColumn(label: Text('')),
            ], rows: widget.rows),
          ),
        ),
      ),      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.clipboardCopy,
        label: Text('Clipboard'),
      //  backgroundColor: Colors.green,
      ),
      );    
  }
}