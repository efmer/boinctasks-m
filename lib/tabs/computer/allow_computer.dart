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
import 'package:boinctasks/constants.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:flutter/material.dart';

class AllowComputer extends StatefulWidget {
    const AllowComputer({super.key, required this.onConfirm});

  @override
  State<StatefulWidget> createState() {
    return AllowDialogState();
  }
  final Function(String value) onConfirm;
}

class AllowDialogState extends State<AllowComputer> {
  String mSelectedComputer = "";
  String mSelectedCpu = txtComputersAllowPref;
  String mSelectedGpu = txtComputersAllowPref;
  String mSelectedNetwork = txtComputersAllowPref;

  late List mComputers;

  List mAllowCpu = [txtComputersAllowPref, txtComputersAllowAlways, txtComputersAllowNever] ;
  List mAllowGpu =  [txtComputersAllowPref, txtComputersAllowAlways, txtComputersAllowNever] ;
  List mAllowNetwork = [txtComputersAllowPref, txtComputersAllowAlways, txtComputersAllowNever] ;

  List mMode = [];

  final TextEditingController mAllowDurationCpu = TextEditingController();
  final TextEditingController mAllowDurationGpu = TextEditingController();
  final TextEditingController mAllowDurationNetwork = TextEditingController();

  String mTxtAllowDurationCpu = txtComputersAllowSnooze;
  String mTxtAllowDurationGpu = txtComputersAllowSnooze;
  String mTxtAllowDurationNetwork = txtComputersAllowSnooze; 

  bool bCpuSnooze = true;   
  bool bGpuSnooze = true;   
  bool bNetworkSnooze = true;   

  late Timer mTimerAllow;

  getComputers()
  {
  try {    
    mComputers = getConnectedComputers();
    if (mComputers.isNotEmpty)
    {
      mSelectedComputer = mComputers[0];
    }
    else
    {
      mSelectedComputer = "";
    }
    } catch (error,s) {
      gLogging.addToLoggingError('AllowComputers (getComputers) $error,$s');
    }    
  }

  List modeItem = [];

  updateAllow(time)
  {
    mTimerAllow.cancel();
    getAllow(time, true);
  }


  // time = initial wait time in .1 second, bChanged = allow all to update now
  getAllow(time, bChanged)
  {
    try { 
      int mActive = time;
      mTimerAllow = Timer.periodic(Duration(milliseconds: 100), (timer)
      {
        if (mActive-- < 0)
        {
          mActive = 40;               // 4 seconds
          modeItem = [];
          var rpc = gRpc.mRpc;
          var len = rpc.length;
          for (var i=0;i<len;i++)
          {
            var item = rpc[i];
            modeItem.add(item.mComputer);
            var status = item.getStatus();
            var statusCc = status["cc_status"];      
            modeItem.add(statusCc);
          }
          len = modeItem.length;
          for (var i=0;i<len;i+=2)
          {
            var computer = modeItem[i];
            if (computer == mSelectedComputer)
            {
              var item = modeItem[i+1];
              var delay = item["task_mode_delay"]['\$t'];
              var delayR = double.parse(delay)/60;
              int delayI = delayR.ceil();
              if (delayI == 0)
              {
                mAllowDurationCpu.text = "";
                mTxtAllowDurationCpu = txtComputersAllowSnooze;
                bCpuSnooze = false;   
              }
              else
              {
                var str = delayI.toString();
                mAllowDurationCpu.text = str;                
                mTxtAllowDurationCpu = "$txtComputersAllowSnooze ($str min)";
                bGpuSnooze = true;                
              }
              var taskModePerm = item["task_mode"]['\$t']; // WARNING task_mode_perm not used
              var newMode = getMode(taskModePerm);
              if (newMode != mSelectedCpu)
              {
                mSelectedCpu = newMode;
                bChanged = true;
              }
              
              delay = item["gpu_mode_delay"]['\$t'];
              delayR = double.parse(delay)/60;
              delayI = delayR.ceil();
              if (delayI == 0)
              {
                mAllowDurationGpu.text = "";
                mTxtAllowDurationGpu = txtComputersAllowSnooze;
                bGpuSnooze = false;
              }
              else
              {
                var str = delayI.toString();
                mAllowDurationGpu.text = str;
                mTxtAllowDurationGpu = "$txtComputersAllowSnooze ($str min)";
                bGpuSnooze = true;                
              }              
              var gpuModePerm = item["gpu_mode"]['\$t'];
              newMode = getMode(gpuModePerm);
              if (newMode != mSelectedGpu)
              {
                mSelectedGpu = newMode;
                bChanged = true;
              }

              delay = item["network_mode_delay"]['\$t'];
              delayR = double.parse(delay)/60;
              delayI = delayR.ceil();
              if (delayI == 0)
              {
                mAllowDurationNetwork.text = "";
                mTxtAllowDurationNetwork = txtComputersAllowSnooze;  
                bNetworkSnooze = false;
              }
              else
              {
                var str = delayI.toString();             
                mAllowDurationNetwork.text = str;
                mTxtAllowDurationNetwork = "$txtComputersAllowSnooze ($str min)";  
                bNetworkSnooze = true;                                
              }              
              var networkModePerm = item["network_mode"]['\$t'];
              newMode = getMode(networkModePerm);
              if (newMode != mSelectedNetwork)
              {
                mSelectedNetwork = newMode;
                bChanged = true;
              }
             // if (bChanged)
              {
                setState(() {
                });
                bChanged = false;
              }
            }
          }    
        }
      });
    } catch (error,s) {
      gLogging.addToLoggingError('AllowComputers (getAllow) $error,$s');
      updateAllow(10);
    } 
  }

  getMode(mode)
  {
    try { 
      switch(mode)
      {
        case "1":
          return txtComputersAllowAlways;
        case "2":
          return txtComputersAllowPref;
        default:
          return txtComputersAllowNever;
      }
    } catch (error,s) {
      gLogging.addToLoggingError('AllowComputers (getMode) $error,$s');
    }    
    return txtComputersAllowPref;    
  }

  setAllowCpu()
  {
    var durationI = 0;
    try { 
      var duration = mAllowDurationCpu.text;
      durationI = int.parse(duration);  
    }
    catch(e)
    {
      durationI = 0;
    }
    var mode = getModeBoinc(mSelectedCpu);
    sendCommand(mSelectedComputer, cTabAllow, "set_run_mode", mode, durationI, context);
  }

  snoozeCpu()
  {
    if (!bCpuSnooze)
    {
      sendCommand(mSelectedComputer, cTabAllow, "set_run_mode", "<never/>\n", 3600, context);
    }
  }

  snoozeGpu()
  {
    if (!bGpuSnooze)
    { 
      sendCommand(mSelectedComputer, cTabAllow, "set_gpu_mode", "<never/>\n", 3600, context);
    }
  }

  snoozeNetwork()
  {
    if (!bNetworkSnooze)
    {    
      sendCommand(mSelectedComputer, cTabAllow, "set_network_mode", "<never/>\n", 3600, context);
    }
  }

  setAllowGpu()
  {
    var durationI = 0;
    try { 
      var duration = mAllowDurationGpu.text;
      durationI = int.parse(duration);  
    }
    catch(e)
    {
      durationI = 0;
    }
    var mode = getModeBoinc(mSelectedGpu);
    sendCommand(mSelectedComputer, cTabAllow, "set_gpu_mode", mode, durationI, context);
  }

  setAllowNetwork()
  {
    var durationI = 0;
    try { 
      var duration = mAllowDurationNetwork.text;
      durationI = int.parse(duration);  
    }
    catch(e)
    {
      durationI = 0;
    }
    var mode = getModeBoinc(mSelectedNetwork);
    sendCommand(mSelectedComputer, cTabAllow, "set_network_mode", mode, durationI, context);
  }

  sendCommand(computer, tab, tag, mode, duration, context)
  {
    var begin = "<$tag>";
    var end = "</$tag>";

    String command = "$begin$mode<duration>$duration</duration>\n$end"; 
    gRpc.commandSingleComputer(mSelectedComputer,tab,command, context);    
  }

  getModeBoinc(mode)
  {
    try { 
      switch(mode)
      {
        case txtComputersAllowAlways:
          return "<always/>\n";
        case txtComputersAllowPref:
          return "<auto/>\n";
        default:
          return "<never/>\n"; //txtComputersAllowNever;
      }
    } catch (error,s) {
      gLogging.addToLoggingError('AllowComputers (getModeBoinc) $error,$s');
    }    
    return txtComputersAllowPref;    
  }

  @override
  void initState() {  
    getComputers();
    getAllow(2,true);
    super.initState();
  }

  @override
  void dispose()
  {
    mTimerAllow.cancel();
    widget.onConfirm("dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {  
    return SimpleDialog(
      insetPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.fromLTRB(10, 12.0, 10, 16.0),
      title: Text(txtComputersAllow),          
      children: <Widget>[                
        SizedBox(
        width: 500,
        child: Table(
          border: TableBorder(horizontalInside: BorderSide(width: 1, color: Colors.blue, style: BorderStyle.solid)),
          defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
          children: [  
            TableRow(
              children: <Widget>[  
                Padding(            
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(txtComputersAllowComputer),
                ),
                DropdownButtonHideUnderline(              
                  child: DropdownButton(
                    alignment: Alignment.topLeft,
                    value: mSelectedComputer,
                    items: mComputers
                        .map((item) =>
                        DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                          ),
                        ))
                        .toList(),
                    onChanged: (value) {
                      mSelectedComputer = value!;
                      setState(() {
                      });                        
                      updateAllow(2);
                    },
                  ),
                ),
                Padding(            
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(""),
                ),                
              ],
            ),
            
            TableRow(
            //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[       
                Padding(            
                  padding: EdgeInsets.only(bottom: 10),                       
                  child: Text(txtComputersAllowCPU),
                ),
                DropdownButtonHideUnderline(              
                  child: DropdownButton(
                    value: mSelectedCpu,
                    items: mAllowCpu
                        .map((item) =>
                        DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                          ),
                        ))
                        .toList(),
                      onChanged: (value) {
                      mSelectedCpu = value!;
                      setState(() {
                      });                      
                      setAllowCpu();
                      updateAllow(10); 
                    },
                  ),
                ),
                Padding(            
                    padding: EdgeInsets.only(bottom: 8),  
                    child: ElevatedButton(
                  onPressed: bCpuSnooze ? null :  () {
                      snoozeCpu();
                      bCpuSnooze = true;
                    },
                    child: Text(mTxtAllowDurationCpu),
                    ),
                  ),
              ]
            ),

            TableRow(
             // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[ 
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(txtComputersAllowGPU),
                ),
                DropdownButtonHideUnderline(              
                  child: DropdownButton(
                    value: mSelectedGpu,
                    items: mAllowGpu
                        .map((item) =>
                        DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                          ),
                        ))
                        .toList(),
                      onChanged: (value) {
                      mSelectedGpu = value!;
                      setState(() {
                      });                      
                      setAllowGpu();
                      updateAllow(10);                       
                    },
                  ),
                ),
                Padding(            
                    padding: EdgeInsets.only(bottom: 8),  
                    child: ElevatedButton(
                  onPressed: bGpuSnooze ? null :  () {
                      snoozeGpu();
                      bGpuSnooze = true;                      
                    },
                    child: Text(mTxtAllowDurationGpu),
                    ),
                  ),   
              ]
            ),

            TableRow(             
              children: <Widget>[ 
                Padding(
                  padding: EdgeInsets.only(bottom: 10),                
                  child: Text(txtComputersAllowNetwork),
                ),
                DropdownButtonHideUnderline(              
                  child: DropdownButton(
                    value: mSelectedNetwork,
                    items: mAllowNetwork
                        .map((item) =>
                        DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                          ),
                        ))
                        .toList(),
                      onChanged: (value) {
                      mSelectedNetwork = value!;                        
                      setState(() {
                      });
                      setAllowNetwork();
                      updateAllow(10);                       
                    },
                  ),
                ),
                Padding(            
                  padding: EdgeInsets.only(bottom: 8),  
                  child: ElevatedButton(
                  onPressed: bNetworkSnooze ? null :  () {
                    snoozeNetwork();
                    bNetworkSnooze = true;                    
                  },
                  child: Text(mTxtAllowDurationNetwork),
                  ),
                ),   
              ]
            ),
          ],
        ),
      ),
      Padding(            
        padding: EdgeInsets.only(top: 20),       
      ),      
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
          ElevatedButton(
            onPressed: () {
              widget.onConfirm("OK");
              Navigator.of(context).pop(); // close dialog              
            },
          child: const Text('OK'),
          ),
          ],
        ),                    
      ],                             
    );
  }
}