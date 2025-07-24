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

//https://dart.dev/language/isolates

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:boinctasks/constants.dart';
import 'package:boinctasks/main.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:xml2json/xml2json.dart';

class IsolateComputer
{
  var mData = [{"ip: ''", "port: ''"}];
}

var gIsolateFound = [];

Future<Object?> mainFindComputers(ip,port) async {
  final worker = await Worker.spawn();
  var dataReturn = await worker.parseJson('{"ip": "$ip", "port": "$port"}');
  worker.close();
  return dataReturn;
}

class Worker {
  final SendPort _commands;
  final ReceivePort _responses;
  final Map<int, Completer<Object?>> _activeRequests = {};
  int _idCounter = 0;
  bool _closed = false;

  Future<Object?> parseJson(String message) async {
    if (_closed) throw StateError('Closed');
    final completer = Completer<Object?>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _commands.send((id, message));
    return await completer.future;
  }

  static Future<Worker> spawn() async {
    // Create a receive port and add its initial message handler
    final initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();
    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };

    // Spawn the isolate.
    try {
      await Isolate.spawn(_startRemoteIsolate, (initPort.sendPort));
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;

    return Worker._(receivePort, sendPort);
  }

  Worker._(this._responses, this._commands) {
    _responses.listen(_handleResponsesFromIsolate);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    final (int id, Object? response) = message as (int, Object?);
    final completer = _activeRequests.remove(id)!;

    if (response is RemoteError) {
      completer.completeError(response);
    } else {
      completer.complete(response);
    }

    if (_closed && _activeRequests.isEmpty) _responses.close();
  }

  static void _handleCommandsToIsolate(
    ReceivePort receivePort,
    SendPort sendPort,
  ) {
    receivePort.listen((message) {
      if (message == 'shutdown') {
        receivePort.close();
        return;
      }
      final (int id, String jsonText) = message as (int, String);
      try {
        final jsonData = jsonDecode(jsonText);
        var fcc = IsolateFindComputers();
        var ip = jsonData[cComputerIp];
        var port = jsonData[cComputerPort];
        fcc.find(ip, port, id, sendPort);
      } catch (e) {
        sendPort.send((id, RemoteError(e.toString(), '')));
      }
    });
  }

  static void _startRemoteIsolate(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    _handleCommandsToIsolate(receivePort, sendPort);
  }

  void close() {
    if (!_closed) {
      _closed = true;
      _commands.send('shutdown');
      if (_activeRequests.isEmpty) _responses.close();
//      print('--- port closed --- ');
    }
  }
}

class IsolateFindComputers
{
  var mRpcConnected = [];
  var mSend = 0;
  var mErrorMsg = "";
  int mPortId = 0;
  late SendPort mPort;
  
  find(ipIn, portIn, id, SendPort sendPort)
  {
    try{
      mPortId = id;
      mPort = sendPort;
      int dot = ipIn.lastIndexOf('.');
      if (dot < 0) return [];

      String net = ipIn.substring(0,dot);

      for (var i=0;i<256;i++)
      {
        NumberFormat formatter = NumberFormat("000");
        var ips =  formatter.format(i);
        String ipf = "$net.$ips";
        var rpc = IsolateRpcConnection();
        var computer = "found:$i";
        var password = "";

        var port = 31416;
        try{    
           port = int.parse(portIn);
        }
        catch(e) {
          port = 31416;
        }

        rpc.rpcCheck(i,computer,ipf,port,password,rpcReady); // i,name,ip,port,password,callback
        mRpcConnected.add(rpc);
        mSend++;
      }   
    } 
    catch(error)
    {
      // ignore: unused_local_variable
      var ii = 1;
    }

    return "busy";
  }

  rpcReady(index, bconnected)
  {
    try{
      mSend--;
      if (mSend <=0)
      {
        mPort.send((mPortId,gIsolateFound));
        return;
      }
      if (bconnected)
      {
        // found connected computer

        var ip = mRpcConnected[index].mIp;
        var port = mRpcConnected[index].mPort.toString();
        var msg = mRpcConnected[index].mLoggingError;
        var item = {cComputerIp: ip, cComputerPort: port, "message": msg};
        gIsolateFound.add(item);
      }
    }  
    catch(error)
    {
      // ignore: unused_local_variable
      var ii =1; 
    }
  }
}

class IsolateRpcConnection {
  var mComputer = "Undefined";
  var mComputerIndex = -1;
  late Socket mRpcSocket;
  var mSocketError = "";  
  var mIp = "undefined";
  var mPort = 0;
  var mPassword = "";

  var mLoggingError = "";

  var mBoinc = "";
  var mPlatform = "";

  bool mbSocketValid = false;
  bool mbAuthenticated = false;
  var mlistenData = "";
  var mwhereTo = -1;
  var mdataBuffer = "";

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
      mLoggingError += 'RpcConnection (rpcCheck) $mComputer: $mIp : $mPort';
      mbSocketValid = false;
      mbAuthenticated = false;
      mCallback(mComputerIndex,false);      
    }
  }

/*
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
*/

  isAuthenticated()
  {
    try
    {
      mCallback(mComputerIndex,true); 
    }
    catch(error,s)
    {
      mLoggingError += 'isolateRpcCheckConnection (isAuthenticated) $error,$s'; 
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
      mLoggingError += 'isolateRpcCheckConnection (invalidateSocket) $error,$s'; 
    }    
  }

  getSocket(String ip, int port) // if socket is null
  async {
    try {
      mSocketError = "undefined";
      mRpcSocket = await Socket.connect(ip, port, timeout: Duration(seconds: gSocketTimeout));  // the timeout might cause problems.
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
        mSocketError = "refused";
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
      mLoggingError += 'isolateRpcCheckConnection (sendRequest) $error,$s';
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
        default:
  //        gotHostInfo(data);
  //        gotConnectionStatusCc(data);
      }
    }
    catch(error,s)
    {
      mLoggingError += 'isolateRpcCheckConnection (listenReady) $error,$s';
    } 
  }

  xmlToJson(xmls,tagBegin,tagEnd)
  {
    try
    {
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
      mLoggingError += 'isolateRpcCheckConnection (xmlToJson) $error,$s';
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
        mbAuthenticated = false;               
        mCallback(mComputerIndex,false);                      
    } catch (error) {
      mLoggingError += 'isolateRpcCheckConnection (authenticate1) $error';
      invalidateSocket();
    }
  }

  authenticate2(data)
  {
    try {
        var auth = xmlToJson(data,"<$cBoincReply>","</$cBoincReply>");
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
        mbAuthenticated = false;               
        mCallback(mComputerIndex,false);
    } catch (error) {
      mLoggingError += 'IsolateRpcCheckConnection (authenticate2) $error';
      invalidateSocket();
    }
  }
}