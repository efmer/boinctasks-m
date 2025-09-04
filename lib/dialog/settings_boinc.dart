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

import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:flutter/material.dart';

class SettingsBoincData
{
  bool runOnBatteries = true;
  bool runIfUserActive = false;
  bool runGpuIfUserActive = false;  

  int startHour = 0;
  int endHour = 0;
  int netStartHour = 0;
  int netEndHour = 0;

  int idleTimeToRun = 3;
  int suspendCpuUsage = 0;
  bool leaveAppsInMemory = false;
  bool confirmBeforeConnecting = true;
  bool hangupIfDialed = false;
  bool dontVerifyImages = false;
  double workBufMinDays = 0.1;
  double workBufAdditionalDays = 0.25;
  int maxNcpusPct = 0;
  int cpuSchedulingPeriodMinutes = 60;
  int diskInterval = 60;
  int diskMaxUsedGb = 10;
  int diskMaxUsedPct = 50;
  int diskMinFreeGb = 1;
  int vmMaxUsedPct = 75;
  int ramMaxUsedBusyPct = 50;
  int ramMaxUsedIdlePct = 90;
  int maxBytesSecUp = 0;
  int maxBytesSecDown = 0;
  int cpuUsageLimit = 100;
  int dailyXferLimitMb = 0;
  int dailyXferPeriodDays = 0; 
}

class SettingsBoincDialog extends StatefulWidget {
  const SettingsBoincDialog({super.key});


  @override
  State<StatefulWidget> createState() {
    return SettingsBoincDialogState();
  }
}

class SettingsBoincDialogState extends State<SettingsBoincDialog> {
  bool bApplyEnabled = true;
  String mStatus = "";
  Color  mStatusColor = const Color.fromARGB(255, 247, 0, 0);
  late SettingsBoincData settings = SettingsBoincData();

  bool mBoincRunOnBatteries = false;
  bool mBoincRunIfUserActive = false;
  bool mBoincRunGpuIfUserActive = false;
  final TextEditingController mAfterIdleFor   = TextEditingController();
  final TextEditingController mWhileUsageLess = TextEditingController();
  final TextEditingController mMinWorkBuffer  = TextEditingController();
  final TextEditingController mAddWorkBuffer  = TextEditingController();
  final TextEditingController mUseAtMostPP    = TextEditingController();
  final TextEditingController mUseAtMostPC    = TextEditingController();

  late String mSelectedComputerValue = "Nothing";
  List<String> itemsComputer = ["Nothing"];

  dynamic getData(dynamic result,tag,def)
  {
    var ret = def;
    try {
      if (result == null)
      {
        return ret;
      }
      if (result.containsKey(tag))
      {
        var item = result[tag]["\$t"];
        if (def is bool)
        {
          if (item == "1")
          {
            return true;
          }
          else
          {
            return false;
          }
        }
        if (def is int)
        {
          var nr = double.parse(item);
          return nr.round();
        }
        if (def is double)
        {
          return double.parse(item);
        }
      }
    } catch (error,s) {
      gLogging.addToLoggingError('Settings Boinc (getData) $error,$s'); 
    }      
    return ret;
  }

  void setBusy(bool bBusy, bool bButton)
  {
    bApplyEnabled = bButton;  
    gRpc.mbBusySettings = bBusy;
    setState(() {      
    });
  }

  void replyBoinc2(dynamic data)
  {
    try {
      replyBoincProcess(data);
    } catch (error,s) {
      gLogging.addToLoggingError('Settings Boinc (replyBoinc2) $error,$s'); 
      setBusy(false,true);
    }      
  }

  void replyBoinc1(dynamic data)
  {
    try {
      var global = data['boinc_gui_rpc_reply'];
      var result = global['global_preferences'];
      if (result == null) // we get null if there never was a change. Now we use the default settings
      {
        gRpc.sendComputerBoincSettings(replyBoinc2,mSelectedComputerValue,"<get_global_prefs_working/>");
        gLogging.addToDebugLogging('Settings Boinc (replyBoinc1) Use default values');
        return;
      }
      replyBoincProcess(data);
    } catch (error,s) {
      gLogging.addToLoggingError('Settings Boinc (replyBoinc) $error,$s'); 
      setBusy(false,true);
    }      
  }

  void replyBoincProcess(dynamic data)
  {
    try {
      setBusy(false,true);
      var global = data['boinc_gui_rpc_reply'];
      var result = global['global_preferences'];

      settings.runOnBatteries     = getData(result,'run_on_batteries',true);
      mBoincRunOnBatteries        = settings.runOnBatteries;
      settings.runIfUserActive    = getData(result,'run_if_user_active',false);
      mBoincRunIfUserActive       = settings.runIfUserActive;
      settings.runGpuIfUserActive = getData(result,'run_gpu_if_user_active',false);  
      mBoincRunGpuIfUserActive    = settings.runGpuIfUserActive;
      settings.startHour          = getData(result,'start_hour',0);
      settings.endHour            = getData(result,'end_hour',0);
      settings.netStartHour       = getData(result,'net_start_hour',0);
      settings.netEndHour         = getData(result,'net_end_hour',0);
      settings.idleTimeToRun      = getData(result,'idle_time_to_run',3);
      mAfterIdleFor.text          = settings.idleTimeToRun.toString() ;
      settings.suspendCpuUsage    = getData(result,'suspend_cpu_usage',0);
      mWhileUsageLess.text        = settings.suspendCpuUsage.toString();   
      settings.leaveAppsInMemory  = getData(result,'leave_apps_in_memory',false);
      settings.confirmBeforeConnecting = getData(result,'confirm_before_connecting',true);
      settings.hangupIfDialed     = getData(result,'hangup_if_dialed',false);
      settings.dontVerifyImages   = getData(result,'dont_verify_images',false);
      settings.workBufMinDays     = getData(result,'work_buf_min_days',0.1);
      mMinWorkBuffer.text         = settings.workBufMinDays.toString();
      settings.workBufAdditionalDays = getData(result,'work_buf_additional_days',0.25);
      mAddWorkBuffer.text         = settings.workBufAdditionalDays.toString();
      settings.maxNcpusPct        = getData(result,'max_ncpus_pct',0);
      mUseAtMostPP.text           = settings.maxNcpusPct.toString();   

      settings.cpuSchedulingPeriodMinutes = getData(result,'cpu_scheduling_period_minutes',60);
      settings.diskInterval       = getData(result,'disk_interval',60);
      settings.diskMaxUsedGb      = getData(result,'disk_max_used_gb',10);
      settings.diskMaxUsedPct     = getData(result,'disk_max_used_pct',50);
      settings.diskMinFreeGb      = getData(result,'disk_min_free_gb',1);
      settings.vmMaxUsedPct       = getData(result,'vm_max_used_pct',75);
      settings.ramMaxUsedBusyPct  = getData(result,'ram_max_used_busy_pct',50);
      settings.ramMaxUsedIdlePct  = getData(result,'ram_max_used_idle_pct',90);
      settings.maxBytesSecUp      = getData(result,'max_bytes_sec_up',0);
      settings.maxBytesSecDown    = getData(result,'max_bytes_sec_down',0);
      settings.cpuUsageLimit      = getData(result,'cpu_usage_limit',100);   
      mUseAtMostPC.text           = settings.cpuUsageLimit.toString();      
      settings.dailyXferLimitMb   = getData(result,'daily_xfer_limit_mb',0);
      settings.dailyXferPeriodDays = getData(result,'daily_xfer_period_days',0);

      setState(() {        
      });
    } catch (error,s) {
      gLogging.addToLoggingError('Settings Boinc (replyBoinc) $error,$s'); 
    }  
  }

  String setData(dynamic data,tag,xx)
  {
    var str = "";
    if (data is bool)
    {
      if (data)
      {
        str = "1";
      }
      else
      {
        str = "0";
      }
    }
    else
    {
      str = data.toString();
    }

    var send = "<$tag>$str</$tag>\n";
    return send;
  } 

  void updateBoinc()
  {
    try {
      var send = "<set_global_prefs_override><global_preferences>\n";
      send += setData(settings.runOnBatteries ,'run_on_batteries',true);
      send += setData(settings.runIfUserActive ,'run_if_user_active',false);
      send += setData(settings.runGpuIfUserActive,'run_gpu_if_user_active',false);  
      send += setData(settings.startHour ,'start_hour',0);
      send += setData(settings.endHour  ,'end_hour',0);
      send += setData(settings.netStartHour ,'net_start_hour',0);
      send += setData(settings.netEndHour,'net_end_hour',0);
      send += setData(settings.idleTimeToRun,'idle_time_to_run',3);
      send += setData(settings.suspendCpuUsage,'suspend_cpu_usage',0);
      send += setData(settings.leaveAppsInMemory,'leave_apps_in_memory',false);
      send += setData(settings.confirmBeforeConnecting,'confirm_before_connecting',true);
      send += setData(settings.hangupIfDialed ,'hangup_if_dialed',false);
      send += setData(settings.dontVerifyImages,'dont_verify_images',false);
      send += setData(settings.workBufMinDays ,'work_buf_min_days',0.1);
      send += setData(settings.workBufAdditionalDays,'work_buf_additional_days',0.25);
      send += setData(settings.maxNcpusPct,'max_ncpus_pct',0);
      send += setData(settings.cpuSchedulingPeriodMinutes,'cpu_scheduling_period_minutes',60);
      send += setData(settings.diskInterval,'disk_interval',60);
      send += setData(settings.diskMaxUsedGb,'disk_max_used_gb',10);
      send += setData(settings.diskMaxUsedPct ,'disk_max_used_pct',50);
      send += setData(settings.diskMinFreeGb,'disk_min_free_gb',1);
      send += setData(settings.vmMaxUsedPct,'vm_max_used_pct',75);
      send += setData(settings.ramMaxUsedBusyPct ,'ram_max_used_busy_pct',50);
      send += setData( settings.ramMaxUsedIdlePct ,'ram_max_used_idle_pct',90);
      send += setData(settings.maxBytesSecUp,'max_bytes_sec_up',0);
      send += setData(settings.maxBytesSecDown,'max_bytes_sec_down',0);
      send += setData(settings.cpuUsageLimit ,'cpu_usage_limit',100);   
      send += setData(settings.dailyXferLimitMb,'daily_xfer_limit_mb',0);
      send += setData(settings.dailyXferLimitMb,'daily_xfer_period_days',0);
      send += "</global_preferences>\n</set_global_prefs_override>";

      setBusy(true,false);
      Timer(
        const Duration(seconds: 1),
        () {
          gRpc.sendComputerBoincSettings(replySendBoinc,mSelectedComputerValue,send);
        },
      );
    } catch (error,s) {
      gLogging.addToLoggingError('Settings Boinc (updateBoinc) $error,$s'); 
    }  
  }

  void replySendBoinc(dynamic data)
  {
    try { 
      if (data == null) // busy
      {
        mStatus = "Unable to update, try again";
        mStatusColor = const Color.fromARGB(255, 247, 0, 0);   
        setBusy(false,true);
        return;
      }

      var reply = data['boinc_gui_rpc_reply'];

      if (reply.containsKey('success'))
      {
        // start using the updated settings
        gRpc.sendComputerBoincSettings(replyBoincRead,mSelectedComputerValue,"<read_global_prefs_override/>");
        return;
      }
      if (reply.containsKey('error'))
      {
        mStatus =  reply['error']["\$t"];
        mStatusColor = const Color.fromARGB(255, 247, 0, 0);  
        setBusy(false,true);
      }
      setState(() {        
      });
    } catch (error,s) {
      gLogging.addToLoggingError('Settings Boinc (replySendBoinc) $error,$s'); 
    }     
  }

  void replyBoincRead(dynamic data)
  {
    var reply = data['boinc_gui_rpc_reply'];    
    if (reply.containsKey('success'))
    {
      mStatus = "Updated";
      mStatusColor = const Color.from(alpha: 1, red: 0, green: 0.969, blue: 0.145);          
    }
    if (reply.containsKey('error'))
    {
      mStatus =  reply['error']["\$t"];
      mStatusColor = const Color.fromARGB(255, 247, 0, 0);        
    }
    setBusy(false,false);
    Timer(
      const Duration(seconds: 2),
      () {
        mStatus = "";
        setBusy(false,true);
      },
    );     
  }

  void sendBoinc(String computer)
  {
    setBusy(true,false);
    gRpc.sendComputerBoincSettings(replyBoinc1,computer,"<get_global_prefs_override/>");
  }

  @override
  void initState() {
    var computers = getConnectedComputers(true);
    if (computers.isNotEmpty)
    {
      itemsComputer = computers;
      mSelectedComputerValue = itemsComputer[0];
      sendBoinc(mSelectedComputerValue);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(   
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.fromLTRB(10, 12.0, 10, 16.0),
      title: Text(txtSettingsBoincDialog),
      children: <Widget>[    

        // selected computer       
        Text(txtSettingsBoincComputer),        
        DropdownButtonHideUnderline(
          child: DropdownButton(
            hint: Text(""),
            value: mSelectedComputerValue,
            items: itemsComputer
                .map((item) =>
                DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                  ),
                ))
                .toList(),
            onChanged: (value) {
              setState(() {
                mSelectedComputerValue = value as String;                
              });
              mStatus = "";
              sendBoinc(mSelectedComputerValue);              
            },
          ),
        ),  

        // run on batteries
        CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),            
          title: Text(txtSettingsBoincRunBat),        
          value: mBoincRunOnBatteries,
          onChanged: (bool? newValue) {
            mBoincRunOnBatteries = !mBoincRunOnBatteries;   
            settings.runOnBatteries = mBoincRunOnBatteries;            
            setState(() {               
            });
          }
        ),

        // Run while user active
        CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),            
          title: Text(txtSettingsBoincInUse),        
          value: mBoincRunIfUserActive,
          onChanged: (bool? newValue) {
            mBoincRunIfUserActive = !mBoincRunIfUserActive;
            settings.runIfUserActive = mBoincRunIfUserActive;  
            setState(() {               
            });
          }
        ),   

        // Use GPU while user active
        CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),            
          title: Text(txtSettingsBoincGpuInUse),        
          value: mBoincRunGpuIfUserActive,
          onChanged: (bool? newValue) {
            mBoincRunGpuIfUserActive = !mBoincRunGpuIfUserActive;
            settings.runGpuIfUserActive = mBoincRunGpuIfUserActive;    
            setState(() {               
            });
          }
        ),   

        // When idle for
        Row(
          children: <Widget>[
            Expanded(
            child: TextField(            
              decoration: InputDecoration(
                labelText: txtSettingsBoincIdleFor,
              ),
              controller: mAfterIdleFor,
              onChanged: (name)
              { 
                settings.idleTimeToRun = double.parse(mAfterIdleFor.text).round();
                setState(() {});              
              },            
            ),
            ),
            Padding(            
              padding: EdgeInsets.only(top: 20),
              child: Text("Minutes"),
            ),
          ]
        ),

        // usage is less
        Row(
          children: <Widget>[
            Expanded(
            child: TextField(            
              decoration: InputDecoration(
                labelText: txtSettingsBoincUsageLess,
              ),
              controller: mWhileUsageLess,
              onChanged: (name)
              { 
                settings.suspendCpuUsage = double.parse(mWhileUsageLess.text).round();                
                setState(() {});              
              },            
            ),
            ),
            Padding(            
              padding: EdgeInsets.only(top: 20),
              child: Text("Percent"),
            ),                        
          ]
        ),

        // use at most % processor
                Row(
          children: <Widget>[
            Expanded(
            child: TextField(            
              decoration: InputDecoration(
                labelText: txtSettingsBoincUseAtMost,
              ),
              controller: mUseAtMostPP,
              onChanged: (name)
              { 
                settings.maxNcpusPct = double.parse(mUseAtMostPP.text).round();                  
                setState(() {});              
              },            
            ),
            ),
            Padding(            
              padding: EdgeInsets.only(top: 20),
              child: Text("Percent of processors"),
            ),                        
          ]
        ),

        // use at most % of CPU
        Row(
          children: <Widget>[
            Expanded(
            child: TextField(            
              decoration: InputDecoration(
                labelText: txtSettingsBoincUseAtMost,
              ),
              controller: mUseAtMostPC,
              onChanged: (name)
              { 
                settings.cpuUsageLimit = double.parse(mUseAtMostPC.text).round();                    
                setState(() {});              
              },            
            ),
            ),
            Padding(            
              padding: EdgeInsets.only(top: 20),
              child: Text("percent of CPU"),
            ),                        
          ]
        ),      

        // minimum work buffer
        Row(
          children: <Widget>[
            Expanded(
            child: TextField(            
              decoration: InputDecoration(
                labelText: txtSettingsBoincMinimumWB,
              ),
              controller: mMinWorkBuffer,
              onChanged: (name)
              { 
                settings.workBufMinDays = double.parse(mMinWorkBuffer.text);                    
                setState(() {});              
              },            
            ),
            ),
            Padding(            
              padding: EdgeInsets.only(top: 20),
              child: Text("Days"),
            ),                        
          ]
        ),

        // aditional work bufer
        Row(
          children: <Widget>[
            Expanded(
            child: TextField(            
              decoration: InputDecoration(
                labelText: txtSettingsBoincAdditianWB,
              ),
              controller: mAddWorkBuffer,
              onChanged: (name)
              { 
                settings.workBufAdditionalDays = double.parse(mAddWorkBuffer.text);                   
                setState(() {});              
              },            
            ),
            ),
            Padding(            
              padding: EdgeInsets.only(top: 20),
              child: Text("Days"),            
            ),
                 
          ]
        ),
        Padding(            
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: Text(mStatus,
            style: TextStyle(
              color: mStatusColor,
              fontWeight: FontWeight.bold,
            ),            
          ),
        ),                    

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                },
                child: const Text('Exit'),
              ),
              if(bApplyEnabled)
              ElevatedButton(                  
                onPressed: () {
                  updateBoinc();
                },
                child: const Text('Apply'),
              ),
              if(!bApplyEnabled)
              ElevatedButton(                  
                onPressed: null,
                child: const Text('Apply'),
              ),              

            ],
        ),          
      ],
    );
  }  
}