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
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:boinctasks/tabs/computer/computers.dart';
import 'package:crypto/crypto.dart';
import 'package:xml2json/xml2json.dart';

// Check if a computer is connected and add or remove it from the connected list.

class RpcCheckConnection {

  late Timer mTimeOutTimerC;
  var mbTimeOutTimerInitC = false;
  dynamic mCallback;
  var mRpcRequests = 0;
  var mRpcConnected = [];
  var mbBusyConnected = false;

  getBusy()
  {
    return mbBusyConnected;
  }

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
      mRpcConnected = [];
      mRpcRequests = 0;
      for (var i=0;i<len;i++)
      {
        var enabled = gComputerList[i][cComputerEnabled];
        if (enabled == "1")
        {
          var rpc = RpcConnection();
          var computer = gComputerList[i][cComputerName];
          var password = gComputerList[i][cComputerPassword];
          var ip = gComputerList[i][cComputerIp];    
          var port = 31416;
          try{    
             port = int.parse(gComputerList[i][cComputerPort]);
          }
          catch(e) {
            port = 31416;
          }
          
          rpc.rpcCheck(i,computer,ip,port,password,rpcReady);     // i,name,ip,port,password,callback
          mRpcRequests++;
          mRpcConnected.add(rpc);
        }
        else
        {
          gComputerList[i][cComputerStatus] = txtComputerStatusDisabled;
        }
      }
      if (mRpcConnected.isEmpty)
      {
        mbBusyConnected = false;
        return;
      }
      if (mbTimeOutTimerInitC)
      {
        mTimeOutTimerC.cancel();
      }
      mTimeOutTimerC = Timer(const Duration(seconds: cTimeoutGeneralConnection), timeOutConnected); // prevent bricking            
      return;
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCheckConnection (connected) $error,$s'); 
    }
    return;
  }

  abort()
  {
    try
    {
      if (mbTimeOutTimerInitC)
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
      gLogging.addToLoggingError('RpcCombine (abort) $error,$s'); 
    }     
  }

  timeOutConnected()
  {
    try
    {
    // nothing is connected
      mTimeOutTimerC.cancel();
      mbBusyConnected = false;
//    var len = gComputerList.length;
//    for(var i=0;i<len;i++)
//    {
//      updateComputerList(i,cComputerConnectedNot);
//    }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCheckConnection (timeOutConnected) $error,$s'); 
    }
  }

  rpcReady(ilist, bconnected)
  {
    try 
    {
      mRpcRequests--;
      if (mRpcRequests == 0)
      {
        mTimeOutTimerC.cancel();      
      }

      var connected = cComputerConnectedNot;
      if (bconnected)
      {
        connected = cComputerConnectedAuthenticated;
      }
      updateComputerList(ilist,connected);
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

  updateComputerList(ilist, connected)
  {
    try{
      var lenRpc = mRpcConnected.length;
      if (lenRpc <= ilist)
      {
        // happens when the number of computers changes and a connection is not set up yet
        gLogging.addToDebugLogging('RpcCheckConnection (updateComputerList) array out of range: Len: $lenRpc, iList: $ilist');
        return;
      }
      var computerName = mRpcConnected[ilist].mComputer;
      var connectedOld = gComputerList[ilist][cComputerConnected];
      gComputerList[ilist][cComputerConnected] = connected;
      for(var r=0;r<lenRpc;r++)
      { 
        if (mRpcConnected[r].mComputer == computerName)
        {
          if (mRpcConnected[r].mbSocketValid)
          {
            if (mRpcConnected[r].mbAuthenticated)  
            {
              gComputerList[ilist][cComputerConnected] = cComputerConnectedAuthenticated;
              gComputerList[ilist][cComputerStatus] = txtComputerStatusConnectedA;
              gComputerList[ilist][cComputerBoinc] = mRpcConnected[r].mBoinc;
              gComputerList[ilist][cComputerPlatform] = mRpcConnected[r].mPlatform;              
            }
            else
            {
              gComputerList[ilist][cComputerConnected] = cComputerConnectedAuthenticatedNot;
              gComputerList[ilist][cComputerStatus] = txtComputerStatusConnectedN;   
            }
          }
          else
          {
            gComputerList[ilist][cComputerConnected] = cComputerConnectedNot;
            var error = mRpcConnected[r].mSocketError;
            if (error.length > 0)
            {
              gComputerList[ilist][cComputerStatus] = error;               
            }
            else
            {
              gComputerList[ilist][cComputerStatus] = txtComputerStatusNotConnected;
            }
          }      
          var connectedNow = gComputerList[ilist][cComputerConnected];
          if (connectedOld != connectedNow)
          {
            var statusTxt = gComputerList[ilist][cComputerStatus];
            var ipTxt = gComputerList[ilist][cComputerIp];
            var portTxt = gComputerList[ilist][cComputerPort];
          gLogging.addToLogging('$computerName ($ipTxt:$portTxt): $statusTxt');
          }  
        }
      }
    } catch (error,s) {
      gLogging.addToLoggingError('RpcCheckConnection (updateComputerList) $error: $s');         
    }  
  }
}

class RpcConnection {
  var mComputer = "Undefined";
  var mComputerIndex = -1;
  late Socket mRpcSocket;
  var mSocketError = txtSocketUndefined;  
  var mIp = "undefined";
  var mPort = 0;
  var mPassword = "";

  var mBoinc = "";
  var mPlatform = "";

  bool mbSocketValid = false;
  bool mbAuthenticated = false;
  var mlistenData = "";
  var mwhereTo = -1;
  var mdataBuffer = "";

  dynamic mstate;
  var mStateValid = false;

  dynamic mCallback;

  void rpcCheck(i,computer,ip,port,password,callback) async {
    try{
      mComputerIndex = i;
      mCallback = callback;
      mComputer = computer;
      mPassword = password;
      mIp = ip;
      mPort = port;
      
      if (!mbSocketValid)
      { 
        mbAuthenticated = false;
        await getSocket(mIp, mPort);
      }
      if (!mbSocketValid) return;
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
      gLogging.addToLoggingError('RpcConnection (rpcCheck) $mComputer: $mIp : $mPort');    
      mbSocketValid = false;
      mbAuthenticated = false;
      mCallback(mComputerIndex,false);      
    }
  }

  abort()
  {
    try
    {
      if (mbSocketValid)
      {
        mRpcSocket.destroy();
        mbSocketValid = false;        
      }
    } catch (error,s) {
      gLogging.addToLoggingError('RpcConnection (abort) $error,$s');         
    }
  }

  isAuthenticated()
  {
    try
    {
      if (!mStateValid)
      {
        getState();
      }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCheckConnection (isAuthenticated) $error,$s'); 
    }

//    getHostInfo();
  }

  invalidateSocket()
  {  
    try
    {
      mbSocketValid = false;
      mbAuthenticated = false;
      mCallback(mComputerIndex,false);
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCheckConnection (invalidateSocket) $error,$s'); 
    }    
  }

  getSocket(String ip, int port) // if socket is null
  async {
    try {
      mSocketError = txtSocketUndefined;      
      mRpcSocket = await Socket.connect(ip, port, timeout: const Duration(seconds: cTimeoutSocket));  // the timeout might cause problems.
      mbSocketValid = true;
//      gLogging.addToLoggingError('rpc: getSocket: $mComputer: $ip : $port');
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
      var errorS = error.toString();
      if (errorS.contains("errno = 111")) {
        mSocketError = txtSocketConnectionRefused;
      }      
      invalidateSocket();
    }    
  }

  sendRequest(msg,whereTo)
  async {
    try
    {
      mlistenData = "";
      var request = cRpcRequest1 + msg + cRpcRequest2;
      try {
        mdataBuffer = "";
        mwhereTo = whereTo;
        mRpcSocket.writeln(request);
        await mRpcSocket.flush();
      } catch (e) {
        invalidateSocket();
      }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCheckConnection (sendRequest) $error,$s'); 
    }     
  }

  listenReady(data)
  {
    try
    {
      switch(mwhereTo)
      {
        case cAuthenticate1:
          authenticate1(data);
        case cAuthenticate2:
          authenticate2(data);
        case cState:
          gotState(data);
        default:
  //        gotHostInfo(data);
  //        gotConnectionStatusCc(data);
      }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCheckConnection (listenReady) $error,$s'); 
    } 
  }

  xmlToJson(xmls,tagBegin,tagEnd)
  {
    try
    {
      if (xmls.contains("<unauthorized/>"))
      {
        return null;
      }


      var id1 = xmls.indexOf(tagBegin);
      var id2 = xmls.indexOf(tagEnd);
      id2 += tagEnd.length;

      var xmlPart = xmls.substring(id1, id2);
      final converter = Xml2Json();
      converter.parse(xmlPart);
      var res = converter.toGData();
      return jsonDecode(res);
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcCheckConnection (xmlToJson) $error,$s'); 
    }       
  }

  authenticate()
  {
//    gLogging.addToLogging('Authenticate (rpc:authenticate): $mIp : $mPort');    
    sendRequest("<auth1/>\n", cAuthenticate1);
  }

  authenticate1(data)
  {
    try {
        var auth = xmlToJson(data,"<$cBoincReply>","</$cBoincReply>");
        if (auth != null)
        {
          if (auth.containsKey(cBoincReply))
          {
            var auth2 = auth[cBoincReply];
            if (auth2.containsKey("nonce"))
            {
              var nonce = auth2["nonce"]["\$t"];
              var np = nonce + mPassword;
              var hash = md5.convert(utf8.encode(np)).toString();
              var req = "<auth2>\n<nonce_hash>$hash</nonce_hash>\n</auth2>\n";
              sendRequest(req, cAuthenticate2);
              return;
            }
          }
        }
        mbAuthenticated = false;               
        mCallback(mComputerIndex,false);                      
    } catch (error) {
      gLogging.addToLoggingError('RpcCheckConnection (authenticate1) $error');       
      invalidateSocket();
    }
  }

  authenticate2(data)
  {
    try {
        var auth = xmlToJson(data,"<$cBoincReply>","</$cBoincReply>");        
        if (auth != null)
        {
          if (auth.containsKey(cBoincReply))
          {
            var auth2 = auth[cBoincReply];
            if (auth2.containsKey("authorized"))
            {
              mbAuthenticated = true;
  //            gLogging.addToDebugLogging('Rpc (authenticate2) Authorized: $mIp : $mPort');  
              isAuthenticated();           
              return;           
            }
          }
        }
        mbAuthenticated = false;               
        mCallback(mComputerIndex,false);
    } catch (error) {
      gLogging.addToLoggingError('RpcCheckConnection (authenticate2) $error');        
      invalidateSocket();
    }
  }

  getState()
  {
    try {
      var req = "<get_state/>\n";
      sendRequest(req, cState);  
    } catch (error,s) {
      gLogging.addToLoggingError('Rpc (getState) $mIp : $mPort : $error,$s'); 
      invalidateSocket();
    }     
  }
  gotState(data)
  {
    try {
      mstate = xmlToJson(data,"<client_state>","</client_state>");
    //gLogging.addToLogging('State read for: $mComputer ($mIp:$mPort)');

      if (mstate == null)
      {
        mbAuthenticated = false;             
        mCallback(mComputerIndex,false);
        return;
      }
      if (mstate.containsKey("client_state"))
      {
        var state = mstate["client_state"];
        mStateValid = true;
        var majorVersion = state["core_client_major_version"]["\$t"];
        var minorVersion = state["core_client_minor_version"]["\$t"];
        var release = state["core_client_release"]["\$t"];

        mBoinc = "$majorVersion.$minorVersion.$release";
        mPlatform = state["platform_name"]["\$t"];
        mCallback(mComputerIndex,true); 
        return;
      }  
      else
      {
        // not authorized
      }
      mbAuthenticated = false;             
      mCallback(mComputerIndex,false);
    } catch (error,s) {
      gLogging.addToLogging('Rpc (GotState) invalid xml $mIp : $mPort : $error,$s');
      invalidateSocket();
    }    
  }
}