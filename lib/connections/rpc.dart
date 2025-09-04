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
import 'dart:convert';
import 'dart:io';
import 'package:boinctasks/constants.dart';
import 'package:boinctasks/dialog/general.dart';
import 'package:boinctasks/functions.dart';
import 'package:boinctasks/tabs/graph/graphs.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:boinctasks/tabs/header/sort_header.dart';
import 'package:boinctasks/state.dart';
import 'package:boinctasks/tabs/computer/computers.dart';
import 'package:boinctasks/tabs/messages.dart';
import 'package:boinctasks/tabs/misc/properties.dart';
import 'package:boinctasks/tabs/transfers.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:boinctasks/tabs/tasks.dart';
import 'package:boinctasks/tabs/project/projects.dart';

class RpcCombined {
  late Timer mTimeOutTimer;
  var emtyRpcCount = 2;
  dynamic mCallback;
  var mCurrentTab = "";
  var mRpc = [];
  var mRpcRequests = 0;
  // ignore: prefer_typing_uninitialized_variables, strict_top_level_inference
  late var mRes;
  bool mbBusy = false;
  bool mbBusyCommand = false;
  bool mbBusySettings = false;
  var mNrRpcCommand = 0;
  var mCommandTab = "";
  var mCommandCommand = "";
  var mCommandComputer = "";
  // ignore: prefer_typing_uninitialized_variables, strict_top_level_inference
  late var mCommandContext;

  var mSortMessage = "";
  var mSortProjects = "";
  var mSortTasksShort = "";
  bool mbSortTaskShort = false;
  var mSortTasksLong = "";
  bool mbSortTaskLong = false;

  String mMessageComputer = "";

  var mProperties = Properties();

  var mCollapsedComputers = [];

  void setBusy() {
    mbBusy = true;
  }

  void forceNotBusy()
  {
    abort();
    mbBusy = false;
    mbBusyCommand = false;    
    mbBusySettings = false;
  }

  bool getBusy() {
    if (mbBusyCommand)
    {
      return true;
    }
    if (mbBusySettings)
    {
      return true;
    }
    return mbBusy;
  }

  void collapseComputer(String computer)
  {
    try{
      bool bFound = false;
      int len = mCollapsedComputers.length;
      for (var i=0;i<len;i++)
      {
        if (mCollapsedComputers[i] == computer)
        {
          mCollapsedComputers.removeAt(i);
          bFound = true;
          break;
        }
      }
      if (!bFound)
      {
        mCollapsedComputers.add(computer);
      }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('rpcCombined (collapseComputer): $error,$s');
    }
  }

  bool isCollapsed(String computer)
  {
    try{
      int len = mCollapsedComputers.length;
      for (var i=0;i<len;i++)
      {
        if (mCollapsedComputers[i] == computer)
        {
          return true;
        }
      }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('rpcCombined (isCollapsed): $error,$s');
    }
    return false;  
  }

  void selectedWu(String computer,project,wu)
  {
    var lenRpc = mRpc.length;      
    for (var d=0;d<lenRpc;d++)
    {
      if (mRpc[d].mComputer == computer)
      {
        mRpc[d].selectedWu(project,wu);
      }
    }
  }

  bool isSelectedWu()
  {
    var lenRpc = mRpc.length;      
    for (var d=0;d<lenRpc;d++)
    {
      if (mRpc[d].mselectedWu.length > 0)
      {
        return true;
      }
    }
    return false;
  }

  void selectedProject(String computer,project)
  {
    var lenRpc = mRpc.length;      
    for (var d=0;d<lenRpc;d++)
    {
      if (mRpc[d].mComputer == computer)
      {
        mRpc[d].selectedProject(project);
      }
    }
  }

  bool isSelectedProjects()
    {
    var lenRpc = mRpc.length;      
    for (var d=0;d<lenRpc;d++)
    {
      if (mRpc[d].mselectedProject.length > 0)
      {
        return true;
      }
    }
    return false;
  }

  void selectedTransfer(String computer,project,wu)
  {
    var lenRpc = mRpc.length;      
    for (var d=0;d<lenRpc;d++)
    {
      if (mRpc[d].mComputer == computer)
      {
        mRpc[d].selectedTransfer(project,wu);
      }
    }
  } 

  bool isSelectedTransfers()
    {
    var lenRpc = mRpc.length;      
    for (var d=0;d<lenRpc;d++)
    {
      if (mRpc[d].mselectedTransfer.length > 0)
      {
        return true;
      }
    }
    return false;
  }

  void selectedMessages(String computer, nr)
  {
    var lenRpc = mRpc.length;      
    for (var d=0;d<lenRpc;d++)
    {
      if (mRpc[d].mComputer == computer)
      {
        mRpc[d].selectedMessages(nr);
      }
    }
  } 

  bool isSelectedMessages()
  {
    var lenRpc = mRpc.length;      
    for (var d=0;d<lenRpc;d++)
    {
      if (mRpc[d].mComputer == mMessageComputer)
      {
        if (mRpc[d].mselectedMessages.length > 0)
        {
          return true;
        }
      }
    }
    return false;
  }

  void copyToClipboard()
  {
    var lenRpc = mRpc.length;      
    for (var d=0;d<lenRpc;d++)
    {
      if (mRpc[d].mComputer == mMessageComputer)
      {
        mRpc[d].copyToClipboard();
        return;
      }
    }
  }

  void commandsTab(String tab,command,context)
  {
    try{
      if (cTabMessages == tab)
      {
        mMessageComputer = command;
        return;
      }

      mCommandTab = tab;
      mCommandCommand = command;
      mCommandContext = context;
      mCommandComputer = "";  // all computers
      commandsTab2();
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('rpcCombined (commandsTab): $error,$s');
    }    
  }

  void commandSingleComputer(String computer, tab, command, context)
  {
      mCommandTab = tab;
      mCommandCommand = command;
      mCommandContext = context; 
      mCommandComputer = computer; // single computer
      commandsTab2();      
  }

  void commandsTab2()
  {
    try{    
      if (mbBusy)
      {
        Timer(const Duration(microseconds: 200), commandsTabRetry);
        return;
      }
      
      mbBusyCommand = true;
      mCallback = null;
      var lenRpc = mRpc.length;      
      mNrRpcCommand = lenRpc;
      if (mCommandCommand == txtProperties)
      {
        mProperties.first();
      }
      for (var d=0;d<lenRpc;d++)
      {             
          if (mCommandComputer.isNotEmpty)
          {
            mNrRpcCommand = 1;
            if (mCommandComputer == mRpc[d].mComputer)
            {
              mRpc[d].commandsTab(mCommandTab,rpcReadyCommand,mCommandCommand,mCommandContext);
            }
          }
          else
          {
            mRpc[d].commandsTab(mCommandTab,rpcReadyCommand,mCommandCommand,mCommandContext);
          }
      }   
      if (mTimeOutTimer.isActive)
      {
        mTimeOutTimer.cancel();
      }    
      if (mCommandCommand == txtProperties)
      {
        mProperties.last(mCommandContext);
      }      
      mTimeOutTimer = Timer(Duration(seconds: gSocketTimeout+10), timeOut);
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('rpcCombined (commandsTab2): $error,$s');
    }      
  }

  void commandsTabRetry()
  {
    try{
      commandsTab2();
    } 
    catch(error,s)
    {
      gLogging.addToLoggingError('rpcCombined (commandsTabRetry): $error,$s'); 
    }     
  }

  int getLength()
  {
    return mRpc.length;
  }

  List<String> getComputers()
  {
    List<String> computers = [];
    var lenRpc = mRpc.length;
    for (var d=0;d<lenRpc;d++)
    {
      computers.add(mRpc[d].mComputer);
    } 
    return computers;
  }

  int getIndex(String computer)
  {
    var lenRpc = mRpc.length;
    for (var d=0;d<lenRpc;d++)
    {
      if (computer == mRpc[d].mComputer)
      {
        return d;
      }
    } 
    return -1;
  }

  void updateHeader(int tab, columnText, columnWidth, newWidth)
  {
    var lenRpc = mRpc.length;
    var bFirst = true;

    for (var d=0;d<lenRpc;d++)
    {
      mRpc[d].updateHeader(tab, columnText, columnWidth, newWidth,bFirst);
      bFirst = false;
    } 
  }

  bool send(dynamic mainCallback,currentTab, sort, String filterRemove, String data) {
    try{
      mTimeOutTimer = Timer(Duration(seconds: gSocketTimeout+10), timeOut);       
      mRes = null;
      mCallback = mainCallback;
      mCurrentTab = currentTab;
      if (!gComputerListRead)
      {
        return false;
      }
      var lenList = gComputerList.length;

      if (lenList == 0)
      {
        return false;
      }

      // check if Rpc still in the computer list and a complete match
      var lenRpc = mRpc.length;      
      for (var d=0;d<lenRpc;d++)
      {
        var bFound = false;
        for (var i=0;i<lenList;i++)
        {
          if (mRpc[d].mComputer == gComputerList[i][cComputerName])
          {
            if (mRpc[d].mIp == gComputerList[i][cComputerIp])
            {
              var portList = "31416";
              if (gComputerList[i][cComputerPort] != "")
              {
                portList = gComputerList[i][cComputerPort];
              }

              if (mRpc[d].mPort.toString() == portList)
              {
                if (mRpc[d].mPassword == gComputerList[i][cComputerPassword])
                {
                  bFound = true;
                }
              }
            }
          }
        }
        if (!bFound)
        {
          mRpc.removeAt(d);
          break;
        }
      }

      var enabledCount = 0; 
      mRpcRequests = 0;
      for (var i=0;i<lenList;i++)
      {
        var enabled = gComputerList[i][cComputerEnabled];
        var connected = gComputerList[i][cComputerConnected];      
        var computer = gComputerList[i][cComputerName];
        if (enabled == "1")
        {        
          enabledCount++;
          if (connected == cComputerConnectedAuthenticated)
          {
            var computerName = gComputerList[i][cComputerName];
            if (cTabMessages == currentTab)
            {
              if (mMessageComputer == "")
              {
                mMessageComputer = computerName;
              }
              if (computerName != mMessageComputer)
              {
                continue;
              }
            }

            // check if already there
            var lenRpc = mRpc.length;
            var iRpcIndex = -1;
            for (var d=0;d<lenRpc;d++)
            {
              if (mRpc[d].mComputer == computerName)
              {
                iRpcIndex = d;
                break;
              }
            }
            if (iRpcIndex < 0)
            {
              var rpc = Rpc();
              mRpc.add(rpc);
              iRpcIndex = lenRpc; 
            }

            mRpc[iRpcIndex].rpcSend(i,rpcReady,currentTab, sort, filterRemove, data);
            mRpcRequests++;            
          }
          else  // not connected
          {
            removeRpc(computer);
          }
        }
      }
      if (mRpc.isEmpty)
      {
        mbBusy = false; // nothing connected yet
        if (enabledCount == 0)
        {
          return true;  // Switches to the Computers tab if no computer is enabled, the default startup setting.
        }

        emtyRpcCount--;
        if (emtyRpcCount <= 0)
        {
          return true;
        }        
        return false;
      }
      else
      {
        emtyRpcCount = 2;
      }
      if (mTimeOutTimer.isActive)
      {
        mTimeOutTimer.cancel();
      } 
      mTimeOutTimer = Timer(Duration(seconds: gSocketTimeout+10), timeOut); // prevent bricking
      return false;
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCombine (send) $error,$s'); 
    }
    return false;
  }

  void removeRpc(String computer)
  {
    var len = mRpc.length;
    for(var i=0;i<len;i++)
    {
      if (mRpc[i].mComputer == computer)
      {
        mRpc.removeAt(i); 
        return;
      }
    }
  }

  void sendComputerProjects(dynamic mainCallback,computer, req)
  {
    try
    {
      var lenRpc = mRpc.length;
      for (var d=0;d<lenRpc;d++)
      {
        if (mRpc[d].mComputer == computer)
        {
          mRpc[d].sendComputerProjects(mainCallback,req);
//              mRpcRequests++;                
          return;
        }
      }
    }   
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCombined (sendComputer) $error,$s'); 
    } 
  }

  var gSendComputerBoincRetry = 2;
  void sendComputerBoincSettings(dynamic mainCallback,String computer, String req)
  {
    try
    {
      gSendComputerBoincRetry = 4;
      sendComputerBoincSettings1(mainCallback,computer, req);

    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCombined (sendComputerBoincSettings) $error,$s'); 
    }       
  }

  void sendComputerBoincSettings1(dynamic mainCallback, String computer, String req)
  {
    try
    {
      if (mbBusy)
      {
        if (gSendComputerBoincRetry-- > 0)
        {
          Timer(const Duration(seconds: 1), sendComputerBoincSettingsRetry(mainCallback,computer, req));
        }
        else
        {
          mainCallback(null);
        }
        return;        
      }

      var lenRpc = mRpc.length;
      for (var d=0;d<lenRpc;d++)
      {
        if (mRpc[d].mComputer == computer)
        {
          mRpc[d].sendComputerBoincSettings(mainCallback,req);
//              mRpcRequests++;                
          return;
        }
      }
    }   
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCombined (sendComputerBoincSettings1) $error,$s'); 
    } 
  }

  dynamic sendComputerBoincSettingsRetry(dynamic mainCallback,String computer, String req)  // is void
  {
    sendComputerBoincSettings1(mainCallback,computer, req);
  }

  void abort()
  {
    try
    {
      if (mTimeOutTimer.isActive)
      {
        mTimeOutTimer.cancel();
      }      

      var lenRpc = mRpc.length;      
      for (var d=0;d<lenRpc;d++)
      {
        mRpc[d].abort();        
      }
      mRpc = [];
      mbBusy = false;
    }   
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCombined (abort) $error,$s'); 
    }    
  }

  void timeOut()
  {
    if (mTimeOutTimer.isActive)
    {
      mTimeOutTimer.cancel();
    }
    gLogging.addToDebugLogging('RpcCombined (timeOut) Timeout');    
    mbBusy = false;
    mbBusyCommand = false;

    if (mCallback != null)
    {
      mCallback.gotTimeOut();
    }
    gDoConnectionCheck = true;
  }

  void rpcReadyCommand()
  {
    mNrRpcCommand--;
    if (mNrRpcCommand == 0)
    {
      mbBusy = false;
      mbBusyCommand = false;
    }
  }

  void rpcReady(int index,tab,res)
  {
    try{
      if (mCurrentTab != tab)
      {
        gLogging.addToDebugLogging('RpcCombined (rpcReady) This should not happen: Tab mismatch $mCurrentTab, $tab');    
      }

      mRpcRequests--;

      if (res != null)  // not connected
      {
        if (mRes == null)
        {
          mRes = res;          
        }
        else
        {
          if (tab == cTabGraph)
          {
            mRes.addAll(res);
          }
          else
          {
            if (res[1].length > 0)
            {
              mRes[1].addAll(res[1]);
            }
          }
        }
      }       

      if (mRpcRequests == 0)
      {
        if (mTimeOutTimer.isActive)
        {
          mTimeOutTimer.cancel();
        }
        //updateComputerList(false);
        if (mRes == null)
        {          
          timeOut();
          gLogging.addToDebugLogging('RpcCombined (rpcReady) No data');            
          return;
        }
        mRes = gSortHeader.sort(tab, mRes);
        switch(tab)
        {         
          case cTabProjects:
            mCallback.gotProjects(mRes);
          case cTabTasks:
            mCallback.gotResults(mRes);
          case cTabTransfers:
            mCallback.gotTransfers(mRes);          
          case cTabMessages:
            mCallback.gotMessages(mRes);  
          case cTabGraph:
            mCallback.gotGraphs(mRes);
          case cTabAllow:
            mCallback.gotAllow(mRes);                
        }
        mbBusy = false;
      }
    }
    catch(error,s)
    {
      mbBusy = false;
      gLogging.addToLoggingError('Rpc (rpcReady) $error,$s'); 
    }
  }
}

var mcomputersClass = Computers();

class Rpc {
  var mComputer = "Undefined";
  var mComputerIndex = -1;
  late Socket mRpcSocket;
  var mIp = "undefined";
  var mPort = 0;
  var mPassword = "";
  bool mbSocketValid = false;
//  var mSocketError = txtSocketUndefined;  
  bool mbBusy = false;
  bool mbAuthenticated = false;

  var messageType = 1;
  var mwhereTo = -1;
  var mdataBuffer = "";
  var mlistenData = "";
  var mfilterRemove = "";
  var msort = "";
  var mselectedWu = [];
  var mselectedProject = [];
  var mselectedTransfer = [];
  var mselectedMessages = [];
  var mCommandQueue = [];

  var mcurrentTab = cTabTasks;

  var mStateClass = BoincState();
  //dynamic mstate;
  //var mStateValid = false;
  dynamic mstatus;
  dynamic mstatusProjects;

  var mMessageComputer = "";

  var mmessagesClass = Messages();
  var mtasksClass = Tasks();
  var mprojectsClass = Projects();
  var mtransfersClass = Transfers();
  var mgraphClass = Graphs();  

  dynamic mCallback;
  dynamic mCallbackComputer;

  void selectedWu(String project,wu)
  {
    try
    {
      var item = {cTasksProject:project,cTasksWu:wu};
      var len = mselectedWu.length;
      for (var i=0;i<len;i++)
      {
        if (mselectedWu[i][cTasksProject] == item[cTasksProject])
        {
          if (mselectedWu[i][cTasksWu] == item[cTasksWu])
          {
            mselectedWu.removeAt(i);
            return;
          }
        }
      }
      mselectedWu.add(item);
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (selectedWu) $error,$s'); 
    }     
  }

  void selectedProject(String project)
  {
    try{
      var item = {cProjectsProject:project};
      var len = mselectedProject.length;
      for (var i=0;i<len;i++)
      {
        if (mselectedProject[i][cProjectsProject] == item[cProjectsProject])
        {
          mselectedProject.removeAt(i);
          return;
        }
      }
      mselectedProject.add(item);
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (selectedProject) $error,$s'); 
    }   
  }

  void selectedTransfer(String project,file)
  {
    try{
      var item = {cTransfersProject:project,cTransfersFile:file};
      var len = mselectedTransfer.length;
      for (var i=0;i<len;i++)
      {
        if (mselectedTransfer[i][cTransfersProject] == item[cTransfersProject])
        {
          if (mselectedTransfer[i][cTransfersFile] == item[cTransfersFile])
          {
            mselectedTransfer.removeAt(i);
            return;
          }
        }
      }
      mselectedTransfer.add(item);
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (selectedTransfer) $error,$s'); 
    } 
 }

  void selectedMessages(String nr)
  {
    try{
      var item = {cMessagesNr:nr};
      var len = mselectedMessages.length;
      for (var i=0;i<len;i++)
      {
        if (mselectedMessages[i][cMessagesNr] == item[cMessagesNr])
        {
          if (mselectedMessages[i][cMessagesNr] == item[cMessagesNr])
          {
            mselectedMessages.removeAt(i);
            return;
          }
        }
      }
      mselectedMessages.add(item);
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (selectedMessages) $error,$s'); 
    } 
 }


//https://github.com/BOINC/boinc/wiki/GuiRpcProtocol
  void commandsTab(String tab,callback,command,context) // tab,rpcReadyCommand,command,context
  {
    try
    {
      mCallback = callback;
      var bConfirm = false;
      switch(tab)
      {
        case cTabTasks:
          var len = mselectedWu.length;    
          if (len == 0)
          {
              mCallback();
              return;
          }
          var cmdTag = "";
          switch (command)
          {
            case txtTasksCommandSuspended:
              cmdTag = "suspend_result";          
            case txtTasksCommandResume:
              cmdTag = "resume_result";
            case txtTasksCommandAborted:
              cmdTag = "abort_result";
              bConfirm = true;          
            case txtProperties:              
              gRpc.mProperties.properties(context,tab,mComputer,mselectedWu, this);
          }            

          for (var i=0;i<len;i++)
          {        
            var project = mselectedWu[i][cTasksProject];
            var name = mselectedWu[i][cTasksWu];
            var url = mStateClass.getProjectUrl(project);

            var cmd = "<$cmdTag><project_url>$url</project_url><name>$name</name></$cmdTag>";
            mCommandQueue.add(cmd);
          }
          if (bConfirm)
          {
            confirmDialogTasks(txtTasksDialogAbort, len, context);
            return;
          }
          sendNextQueue();   

        case cTabProjects:
          var len = mselectedProject.length;    
          if (len == 0)
          {
            mCallback();
            return;
          }

          var cmdTag = "";
          if (command == txtProjectsCommandSuspended)
          {
            cmdTag = "project_suspend";   
          }
          if (command == txtProjectsCommandResume)
          {
            cmdTag = "project_resume";   
          }
          if (command == txtProjectCommandUpdate)
          {
            cmdTag = "project_update";   
          }
          if (command == txtProjectCommandNoMoreWork)
          {
            cmdTag = "project_nomorework";   
          }
          if (command == txtProjectCommandAllowMoreWork)
          {
            cmdTag = "project_allowmorework";   
          }
          if (command == txtProperties)
          {
              gRpc.mProperties.properties(context,tab,mComputer,mselectedProject, this); 
          }          

          for (var i=0;i<len;i++)
          {
            var project = mselectedProject[i][cProjectsProject];
            var url = mStateClass.getProjectUrl(project);
            var cmd = "<$cmdTag><project_url>$url</project_url></$cmdTag>";
            mCommandQueue.add(cmd);
          }   
          sendNextQueue();        

        case cTabTransfers:
          var len = mselectedTransfer.length;    
          if (len == 0)
          {
            mCallback();
            return;
          }
          var cmdTag = "";
          if (command == txtTransfersCommandRetry)
          {
            cmdTag = "retry_file_transfer";   
          }
          for (var i=0;i<len;i++)
          {
            var project = mselectedTransfer[i][cTransfersProject];
            var file = mselectedTransfer[i][cTransfersFile];
            var url = mStateClass.getProjectUrl(project);
            var cmd = "<$cmdTag><project_url>$url</project_url><filename>$file</filename></$cmdTag>";
            mCommandQueue.add(cmd);
          }   
          sendNextQueue();

          case cTabAllow:
            mCommandQueue.add(command);  
            sendNextQueue();      

          default:
            mCommandQueue = [];
            sendNextQueue();
      }
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (commandsTab) $error,$s'); 
    }       
  }

  Future<void> confirmDialogTasks(String title, nr, context)
  async {
    try{
     await showDialog(
      context: context,
      builder: (myApp) {            
        return ConfirmDialog(onConfirm: (bool ret) {         
          if (ret == true)
          {
            sendNextQueue();
          }
          else
          {
            mCommandQueue = [];
            sendNextQueue;
          }
         }, dlgTitle: title, dlgText: "$nr, on $mComputer");
      }
     );
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (confirmDialogTasks) $error,$s'); 
    }       
  }

  void sendNextQueue()
  {
    try{
      var len = mCommandQueue.length;
      if (len == 0)
      {
        mCallback();
      }
      else
      {
        var cmd = mCommandQueue[0];
        mCommandQueue.removeAt(0);
        setResults(cmd);
      }
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (sendNextQueue) $error,$s'); 
    }      
  }

  void updateHeader(int tab, columnText, columnWidth, newWidth,bWrite)
  {
    try {
      switch(tab)
      {
        case cTypeComputer:
          mcomputersClass.updateHeader(columnText, columnWidth, newWidth, bWrite);        
        case cTypeMessage:
          mmessagesClass.updateHeader(columnText, columnWidth, newWidth, bWrite);              
        case cTypeProject:
          mprojectsClass.updateHeader(columnText, columnWidth, newWidth, bWrite);
        case cTypeResult:
          mtasksClass.updateHeader(columnText, columnWidth, newWidth, bWrite);      
        case cTypeTransfer:
          mtransfersClass.updateHeader(columnText, columnWidth, newWidth, bWrite); 
      }
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (updateHeader) $error,$s'); 
    }  
  }

  // telnet 192.168.0.100 31416 exit control ] close quit
  void rpcSend(int i,callback, currentTab, sort, String filterRemove, String data) async
  {
    try{
      mComputerIndex = i;
      mCallback = callback;
      mComputer = gComputerList[i][cComputerName];
      mPassword = gComputerList[i][cComputerPassword];
      mIp = gComputerList[i][cComputerIp];
      try{    
        mPort = int.parse(gComputerList[i][cComputerPort]);
      }
      catch(e) {
        mPort = 31416;
      }
      
      mfilterRemove = filterRemove;
      mcurrentTab = currentTab;
      msort = sort;
      if (!mbSocketValid)
      { 
        mbAuthenticated = false;
        await getSocket(mIp, mPort);
      }
      if (!mbSocketValid)
      {
         return;
      }
      if (mPassword.isNotEmpty)
      {
        if (!mbAuthenticated)
        {
          authenticate();
          return;
        }
        else
        {
          isAuthenticated();
        }
      }
      else
      {
        mbAuthenticated = true;
        isAuthenticated();
      }
    } catch (error) {
      gLogging.addToLoggingError('Rpc (rpcSend) $mComputer: $mIp : $mPort');    
      mbSocketValid = false;
      mbAuthenticated = false;
      mbBusy = false;
      mCallback(mComputerIndex,mcurrentTab,null);      
    }
  }

  void abort()
  {
    try
    {
      if (mbSocketValid)
      {
        mRpcSocket.destroy();
        mbSocketValid = false;
        mbAuthenticated = false;
      }   
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (abort) $error,$s');         
    }
  }

  void isAuthenticated()
  {
    try {
      if (mStateClass.isStateNeedsUpdate())
      {
          getState();      
      }
      else
      {
        switch (mcurrentTab)
        {
          case cTabTasks:
            getStatusCc();
          case cTabProjects:
            getProject();
          case cTabMessages:
            getMessages();  
          case cTabTransfers:
            getTransfers();  
//          case cTabBoincSettings:
//            getNotices();
          case cTabGraph:
            getGraphs();
          case cTabAllow:
            getStatusCc();                              
        }
      }
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (isAuthenticated) $error,$s'); 
    }   
  }

  void invalidateSocket()
  {
    try {
      if (mbSocketValid)
      {
        try{mRpcSocket.destroy();}catch(error){
          gLogging.addToDebugLogging('Rpc Socket destroy not needed: $mComputer, $mIp : $mPort');
        }
      }      
      gLogging.addToDebugLogging('Rpc (invalidateSocket) $mComputer: $mIp : $mPort');    
      mbSocketValid = false;
      mbAuthenticated = false;
      mbBusy = false;
      mCallback(mComputerIndex,mcurrentTab,null);
      gDoConnectionCheck = true;
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (invalidateSocket) $error,$s'); 
    }  
  }

  Future<void> getSocket(String ip, int port) // if socket is null
  async {
    try {
      //mSocketError = txtSocketUndefined;
      mRpcSocket = await Socket.connect(ip, port, timeout: Duration(seconds: gSocketTimeout));  // the timeout might cause problems.
      mbSocketValid = true;
      gLogging.addToDebugLogging('Rpc (getSocket) $mComputer: $ip : $port');
      mIp = ip;
      mPort = port;
      // a single listen for all requests
      mRpcSocket.listen((dataIn) {
        var data = String.fromCharCodes(dataIn).trim();
        mlistenData += data;
        var eof = "\u0003";
        var found = data.indexOf(eof);
        if (found >= 0)
        {
          listenReady(mlistenData);
        }
      });  
    } catch (error) {
//      var errorS = error.toString();
//      if (errorS.contains("errno = 111")) {
//        mSocketError = txtSocketConnectionRefused;
        invalidateSocket();
    }
  }    
  

  Future<void> sendRequest(String msg,whereTo)
  async {
    try {
        mlistenData = "";
        var request = cRpcRequest1 + msg + cRpcRequest2;
        mdataBuffer = "";
        mwhereTo = whereTo;
        mRpcSocket.write(request);  // used to be writeln
  //      await mRpcSocket.flush(); // generates error StreamSink is bound to a stream
    } catch (e) {
      invalidateSocket();
    }  
  }

  void listenReady(dynamic data)
  {
    switch(mwhereTo)
    {
      case cAuthenticate1:
        authenticate1(data);
      case cAuthenticate2:
        authenticate2(data);
      case cState:
        gotState(data);
      case cStatusTask:
        gotStatusCc(data);
      case cTasks:
        gotResults(data);    
      case cProjects:
        gotProjects(data);
      case cProjectsList:
        gotSendComputerProjects(data);        
      case cMessages:
        gotMessages(data);
      case cTransfers:
        gotTransfers(data);
      case cBoincSettings:
        gotBoincSettings(data);        
      case cGraph:
        gotGraphs(data);
      case cSendCommand:
        gotCommand(data);     
        return;
      default:
        mbBusy = false;
        return;
    } 
  }

  void authenticate()
  {
    gLogging.addToDebugLogging('Rpc (authenticate) start: $mComputer, $mIp : $mPort');    
    sendRequest("<auth1/>\n", cAuthenticate1);
  }

  void authenticate1(dynamic data)
  {
    try {
        var auth = xmlToJson(data,"<$cBoincReply>","</$cBoincReply>");
        if (auth.containsKey(cBoincReply))
        {
          var auth2 = auth[cBoincReply];
          if (auth2.containsKey("nonce"))
          {
            var nonce = auth2["nonce"]["\$t"];
            gLogging.addToDebugLogging('Rpc (authenticate1) $mComputer,  $mIp : $mPort, nonce: $nonce');
            var np = nonce + mPassword;
            var hash = md5.convert(utf8.encode(np)).toString();
            var req = "<auth2>\n<nonce_hash>$hash</nonce_hash>\n</auth2>\n";
            sendRequest(req, cAuthenticate2);
            return;
          }
        }
        mbAuthenticated = false;               
        mCallback(mComputerIndex,false);                      
    } catch (error) {
      invalidateSocket();
    }
  }

  void authenticate2(dynamic data)
  {
    try {
        var auth = xmlToJson(data,"<$cBoincReply>","</$cBoincReply>");
        if (auth.containsKey(cBoincReply))
        {
          var auth2 = auth[cBoincReply];
          if (auth2.containsKey("authorized"))
          {
            mbAuthenticated = true;
            gLogging.addToDebugLogging('Rpc (authenticate2) Authorized: $mComputer, $mIp : $mPort');  
            isAuthenticated();         
            return;           
          }
        }
        mbAuthenticated = false; 
        gLogging.addToDebugLogging('Rpc (authenticate2) Password error $mIp : $mPort');
        invalidateSocket();
    } catch (error) {
      invalidateSocket();
    }  
  }

  void getState()
  {
    try {
      var req = "<get_state/>\n";
      sendRequest(req, cState);  
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (getState) $mIp : $mPort : $error,$s'); 
      invalidateSocket();
    }     
  }
  void gotState(dynamic data)
  {
    try {
      mStateClass.setState(xmlToJson(data,"<client_state>","</client_state>"));
      gLogging.addToDebugLogging('Rpc (gotState) State read for: $mComputer ($mIp:$mPort)');
      switch (mcurrentTab)
      {
        case cTabTasks:
          getStatusCc();
        case cTabProjects:
          getProject();
        case cTabMessages:
          getMessages();
        case cTabTransfers:
          getTransfers(); 
        case cTabGraph:
          getGraphs();
        case cTabAllow:
          getStatusCc();       
      }
    } catch (error,s) {
      gLogging.addToLogging('Rpc (GotState) State invalid xml $mIp : $mPort : $error,$s');
      invalidateSocket();
    }    
  }

  void getStatusCc()
  {
    var req = "<get_cc_status/>";
     sendRequest(req, cStatusTask);
  }

  void gotStatusCc(dynamic data)
  {
    mstatus = xmlToJson(data,"<cc_status>","</cc_status>"); 

    switch (mcurrentTab)
    {
      case cTabTasks:
        getResults();
      case cTabProjects:
        getProject();
      case cTabMessages:
        getMessages();
      case cTabTransfers:
        getTransfers();
      case cTabGraph:
        getGraphs();
      case cTabAllow:
        gotAllow();        
    }
  }

  dynamic getStatus()
  {
    return mstatus;
  }

  void gotComputers()
  {
      mbBusy = false;
      mCallback(mComputerIndex,mcurrentTab,null);
  }

  void getProject()
  {
    var req = "<get_project_status/>";
    sendRequest(req, cProjects);
  }

  void gotProjects(dynamic data)
  {
    try {
      var projects = xmlToJson(data,"<projects>","</projects>");
      var res = mprojectsClass.newData(mStateClass, mComputer, mselectedProject, projects);
      mbBusy = false;
      mCallback(mComputerIndex,mcurrentTab,res);
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (GotProjects) invalid xml $mIp : $mPort : $error,$s');   
      invalidateSocket();
    }       
  }

  void sendComputerBoincSettings(dynamic callback,req)
  {
    mCallbackComputer = callback;
    sendRequest(req, cBoincSettings);
  }

  void sendComputerProjects(dynamic callback,req)
  {
    mCallbackComputer = callback;
    sendRequest(req, cProjectsList);
  }

  void gotSendComputerProjects(dynamic data)
  {
    try {   
      mbBusy = false;
      mCallbackComputer(data);
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (gotSendComputer) invalid xml $mIp : $mPort : $error,$s');
    }  
  }

  void getTransfers()
  {
    var req = "<get_file_transfers/>";
    sendRequest(req, cTransfers);
  }

  void gotTransfers(dynamic data)
  {
  try {
      var transfers = xmlToJson(data,"<file_transfers>","</file_transfers>");
      var res = mtransfersClass.newData(mStateClass, mComputer, mselectedTransfer, transfers);
      mbBusy = false;
      mCallback(mComputerIndex,mcurrentTab,res);      
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (gotTransfers) invalid xml $mIp : $mPort : $error,$s');   
      invalidateSocket();
    }       
  }

  void getResults()
  {
    var req = "<get_results/>\n";
    sendRequest(req, cTasks);
  }

  void gotResults(dynamic data)
  {
    try {
      var results = xmlToJson(data,"<results>","</results>");
      var resGot = mtasksClass.newData(mStateClass, mComputer, mfilterRemove, mselectedWu, mstatus, results);
      mbBusy = false;
      mCallback(mComputerIndex,mcurrentTab,resGot);      
    } catch (error,s) {
      gLogging.addToLoggingError('Results invalid xml (rpc:GotResults): $mIp : $mPort : $error,$s');   
      invalidateSocket();
    }       
  }

  void setResults(dynamic request)
  {
    try {
      var req = request;
      sendRequest(req, cSendCommand);  
    } catch (error,s) {
      gLogging.addToLoggingError('(rpc:setResulsts): $mIp : $mPort : $error,$s'); 
      invalidateSocket();
    }     
  }

  void getMessages()
  {
    var req = "";
    var seqno = mmessagesClass.getSeqno();
    if (seqno <= 0)
    {
      req = "<get_messages/>\n";
    }
    else
    {
      req = "<get_messages><seqno>$seqno</seqno></get_messages>";
    }
    sendRequest(req, cMessages);    
  }

  void gotMessages(dynamic data)
  {
    try {
      var messages = xmlToJson(data,"<msgs>","</msgs>");
      var res = mmessagesClass.newData(mComputer, mselectedMessages, messages);
      mbBusy = false;
      mCallback(mComputerIndex,mcurrentTab,res);
    } catch (error, s) {
      gLogging.addToLoggingError('Messages invalid xml (rpc:GotProjects): $mIp : $mPort : $error,$s');   
      invalidateSocket();
    }       
  }

  void copyToClipboard()
  {
    mmessagesClass.copyToClipboard();
  }

//getNotices()
 // {
 //   var req = "<get_notices>\n</get_notices>";
 //   sendRequest(req, cNotices);   
 // }

  void gotBoincSettings(dynamic data)
  {
    try {
      var settings = xmlToJson(data,"<boinc_gui_rpc_reply>","</boinc_gui_rpc_reply>");
      mbBusy = false;
      mCallbackComputer(settings);      
    } catch (error,s) {
      gLogging.addToLoggingError('Results invalid xml (rpc:gotBoincSettings): $mIp : $mPort : $error,$s');   
      invalidateSocket();
    }      
  }

  void getGraphs()
  {
    var req = "<get_statistics/>\n";
    sendRequest(req, cGraph);   
  }

  void gotGraphs(dynamic data)
  {
    try {
      var stats = xmlToJson(data,"<statistics>","</statistics>");
      var resGot = mgraphClass.newData(mStateClass, mComputer, stats);
      mbBusy = false;
      mCallback(mComputerIndex,mcurrentTab,resGot);      
    } catch (error,s) {
      gLogging.addToLoggingError('Results invalid xml (rpc:GotGraphs): $mIp : $mPort : $error,$s');   
      invalidateSocket();
    }      
  }

  void gotAllow()
  {
      mbBusy = false;
      var dummy = []; 
      var ret = [];
      ret.add(dummy);
      ret.add(dummy);      
      mCallback(mComputerIndex,mcurrentTab,ret);  // ret = dummy
  }

  void gotCommand(dynamic data)
  {
    sendNextQueue();
  }
}