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

import 'package:boinctasks/connections/connection_check/rpcconnection.dart';
import 'package:boinctasks/constants.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:boinctasks/tabs/computer/computers.dart';

// Check if a computer is connected and add or remove it from the connected list.
var mbBusyConnected = false;

class RpcCheckConnection {

  late Timer mTimeOutTimerC;
  dynamic mCallback;
  var mRpcRequests = 0;
  var mRpcConnected = [];

  Future isConnected () async {
    try{   
      if (!gComputerListRead)
      {
        return;
      }
      var len = gComputerList.length;
      if (len == 0)
      {     
        return;
      }

      mbBusyConnected = true;
      mRpcRequests = 0;

      for (var i=0;i<len;i++)
      {
        var item = gComputerList[i];
        var enabled = item[cComputerEnabled];
        if (enabled == "1")
        {
          var computer = item[cComputerName];
          var password = item[cComputerPassword];
          var ip = item[cComputerIp];    
          var port = 31416;
          try{    
             port = int.parse(item[cComputerPort]);
          }
          catch(e) {
            port = 31416;
          }

          if (item[cComputerConnected] != '2')
          {
            removeRpc(computer);
            item[cComputerStatus] = txtComputerStatusNotConnectedS;          
            var rpc2 = RpcConnection();
            mRpcConnected.add(rpc2);             
            rpc2.rpcMakeConnection(i,computer,ip,port,password,rpcReady);     // i,name,ip,port,password,callback
          }
          else
          {
            var rpc = checkIfRpcPresent(computer);
            if (rpc == null)
            {
              var rpc2 = RpcConnection();   // no longer there, happend with pause
              mRpcConnected.add(rpc2); 
              rpc2.rpcMakeConnection(i,computer,ip,port,password,rpcReady);              
            }
            else
            {
              rpc.rpcCheckConnection(i,computer,ip,port,password,rpcReady);            
            }
          }          
          mRpcRequests++;
        }
        else
        {
          item[cComputerStatus] = txtComputerStatusDisabled;
        }
      }
      removeIfRpcNotUsed();
      if (mRpcConnected.isEmpty)
      {
        mbBusyConnected = false;
        return;
      }
      try {
        if (mTimeOutTimerC.isActive)
        {
          mTimeOutTimerC.cancel();
        }
      }
      catch(error){
        // timer not initialized
      }      
      mTimeOutTimerC = Timer(Duration(seconds: gSocketTimeout+10), timeOutConnected); // prevent bricking       
      return;
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCheckConnection (connected) $error,$s'); 
    }
    return;
  }

  void abort()
  {
    try{
     if (mTimeOutTimerC.isActive)
     {
      mTimeOutTimerC.cancel();
     }
      var lenRpc = mRpcConnected.length;      
      for (var d=0;d<lenRpc;d++)
      {
        mRpcConnected[d].abort();        
      }
      mRpcConnected = [];
      mbBusyConnected = false;      
    }   
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCheckConnection (abort) $error,$s'); 
    }    
  }

  dynamic checkIfRpcPresent(String computer)
  {
    var len = mRpcConnected.length;
    for(var i=0;i<len;i++)
    {
      if (mRpcConnected[i].isPresent(computer))
      {
        return mRpcConnected[i];
      }
    }
    return null;
  }

  void removeIfRpcNotUsed()
  {
    var len = mRpcConnected.length;
    for(var i=0;i<len;i++)
    {
      if (!mRpcConnected[i].getInUse())
      {
        mRpcConnected.removeAt(i);    // remove one at a time
        return;
      }
      mRpcConnected[i].setNotInUse();
    }
  }

  void removeRpc(String computer)
  {
    var len = mRpcConnected.length;
    for(var i=0;i<len;i++)
    {
      if (mRpcConnected[i].isPresent(computer))
      {
        mRpcConnected.removeAt(i); 
        return;
      }
    }
  }

  void resetSend()
  {
    var len = mRpcConnected.length;
    for(var i=0;i<len;i++)
    {
      mRpcConnected[i].mbSendConnected = false;
    }    
  }

  void timeOutConnected()
  {
    try
    {
      // if we get here the Socket Timeout did not work, check if we got data      
      var len = mRpcConnected.length;
      for(var i=0;i<len;i++)
      {
        if (!mRpcConnected[i].mbWeGotData)
        {
          // mark as not connected
          var computer = mRpcConnected[i].mComputer;
          var len = gComputerList.length;
          for (i=0;i<len;i++)
          {
            if (gComputerList[i][cComputerName] == computer)
            {
              gComputerList[i][cComputerConnected] = cComputerConnectedNot;
              gLogging.addToDebugLogging('RpcCheckConnection (timeOutConnected) No longer connected: $computer');            
            }
          }      
        }
      }

      try { mTimeOutTimerC.cancel(); }    catch(error){
        gLogging.addToDebugLogging('RpcCheckConnection (timeOutConnected) timer cancel not needed');          
      }
      mbBusyConnected = false;
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCheckConnection (timeOutConnected) $error,$s'); 
    }
  }

  void rpcReady(dynamic rpc,ilist, bconnected)
  {
    try 
    {
      mRpcRequests--;
      if (mRpcRequests == 0)
      {
        try { mTimeOutTimerC.cancel(); }    catch(error){
          gLogging.addToDebugLogging('RpcCheckConnection (rpcReady) timer cancel not needed');          
        }
      }

      var connected = cComputerConnectedNot;
      if (bconnected)
      {
        connected = cComputerConnectedAuthenticated;
      }
      updateComputerListStatus(ilist,connected);
      if (mRpcRequests == 0)
      {
        mbBusyConnected = false;
      }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCheckConnection (rpcReady) $error,$s'); 
    }
  }

  void updateComputerListStatus(int iCompList, connected)
  {
    try{
      var lenRpc = mRpcConnected.length;
      var lenComputer = gComputerList.length;
      if (iCompList > lenComputer)
      {
        // happens when the number of computers changes
        gLogging.addToDebugLogging('RpcCheckConnection (updateComputerList) array out of range: Len: $lenRpc, iList: $iCompList');
        return;
      }
      var computerName = gComputerList[iCompList][cComputerName];  //mRpcConnected[ilist].mComputer;
      var connectedOld = gComputerList[iCompList][cComputerConnected];
      gComputerList[iCompList][cComputerConnected] = connected;
      for(var iRpc=0;iRpc<lenRpc;iRpc++)
      { 
        if (mRpcConnected[iRpc].mComputer == computerName)
        {
          if (mRpcConnected[iRpc].mbSocketValid)
          {
            if (mRpcConnected[iRpc].mbAuthenticated)  
            {
              gComputerList[iCompList][cComputerConnected] = cComputerConnectedAuthenticated;
              gComputerList[iCompList][cComputerStatus] = txtComputerStatusConnectedA;
              gComputerList[iCompList][cComputerBoinc] = mRpcConnected[iRpc].mBoinc;
              gComputerList[iCompList][cComputerPlatform] = mRpcConnected[iRpc].mPlatform;              
            }
            else
            {
              gComputerList[iCompList][cComputerConnected] = cComputerConnectedAuthenticatedNot;
              gComputerList[iCompList][cComputerStatus] = txtComputerStatusConnectedN;   
            }
          }
          else
          {
            gComputerList[iCompList][cComputerConnected] = cComputerConnectedNot;
            var error = mRpcConnected[iRpc].mSocketError;
            if (error.length > 0)
            {
              gComputerList[iCompList][cComputerStatus] = error;               
            }
            else
            {
              gComputerList[iCompList][cComputerStatus] = txtComputerStatusNotConnected;
            }
          }      
          var connectedNow = gComputerList[iCompList][cComputerConnected];
          if (connectedOld != connectedNow)
          {
            var statusTxt = gComputerList[iCompList][cComputerStatus];
            var ipTxt = gComputerList[iCompList][cComputerIp];
            var portTxt = gComputerList[iCompList][cComputerPort];
          gLogging.addToLogging('$computerName ($ipTxt:$portTxt): $statusTxt');
          }  
        }
      }
    } catch (error,s) {
      gLogging.addToLoggingError('RpcCheckConnection (updateComputerListStatus) $error: $s');         
    }  
  }
}