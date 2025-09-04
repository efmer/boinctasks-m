import 'dart:convert';
import 'dart:io';

import 'package:boinctasks/constants.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:crypto/crypto.dart';
import 'package:xml2json/xml2json.dart';

class RpcConnection{
  late Socket mSocket;
  var mIp = "0";
  var mPort = 0;
  var mPassword = "";
  var mSocketError = txtSocketUndefined;
  var mbSocketValid = false;
  var mbAuthenticated = false;
  var mbSendConnected = false;
  var mbSendInProgress = false;
  var mComputer = "";
  var mComputerIndex = -1;
  var mwhereTo = -1;
  var mlistenData = "";
  var mdataBuffer = "";
  var mbWeGotData = false;

  dynamic mstate;
  var mStateValid = false;

  dynamic mstatus;

  var mBoinc = "";
  var mPlatform = "";

  dynamic mCallback;

  var mbRpcInUse = false;

  void abort()
  {
    try
    {
      if (mbSocketValid)
      {
        mSocket.destroy();
        mbSocketValid = false;
        mbAuthenticated = false;
      }   
    } catch (error,s) {
      gLogging.addToLoggingError('RpcConnection (abort) $error,$s');         
    }
  }

bool isPresent(String computer)
{
  if (mComputer == computer)
  {
    return true;    
  }
  return false;
}

void setNotInUse()
{
   mbRpcInUse = false; 
}

bool getInUse()
{
  return mbRpcInUse;
}

void rpcCheckConnection(int i,computer,ip,port,password,callback)
{
  mbRpcInUse = true;
  mComputerIndex = i;
  mCallback = callback;
  mPassword = password;
  mIp = ip;
  mPort = port;

  mbWeGotData = false;  // check if we complete getting the data from BOINC

  getStatusCc();
}


Future<void> rpcMakeConnection(int i,computer,ip,port,password,callback) async {
    try{
      mbRpcInUse = true;      
      mComputerIndex = i;
      mCallback = callback;
      mComputer = computer;
      mPassword = password;
      mIp = ip;
      mPort = port;

      mbWeGotData = true;  // check if we complete getting the data from BOINC
      
      if (!mbSocketValid)
      { 
        mbAuthenticated = false;
        await getSocket(mIp, mPort);
      }
      if (!mbSocketValid)
      {
        mCallback(this,mComputerIndex,false);   
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
      gLogging.addToLoggingError('RpcConnection (rpcCheck) $mComputer: $mIp : $mPort');    
      mbSocketValid = false;
      mbAuthenticated = false;
      mCallback(this,mComputerIndex,false);      
    }
  }

  Future<void> getSocket(String ip, int port)
  async {
    mSocketError = txtSocketUndefined;
    mbSocketValid = false;
    mbAuthenticated = false;
    mlistenData = "";
      try {  
        mSocket = await Socket.connect(ip, port, timeout: Duration(seconds: gSocketTimeout));  // the timeout might cause problems.
        mbSocketValid = true;

  //      gLogging.addToLoggingError('rpc: getSocket: $mComputer: $ip : $port');
        mIp = ip;
        mPort = port;
        // a single listen for all requests
        mSocket.listen((dataIn) {
          var data = String.fromCharCodes(dataIn).trim();
          mlistenData += data;
          var eof = "\u0003";
          var found = data.indexOf(eof);
          if (found >= 0)
          {
            listenReady(mlistenData);
          }
        });
      } catch (error)
      {        
        var errorS = error.toString();
        if (errorS.contains("errno = 111")) {
          mSocketError = txtSocketConnectionRefused;
        }      
        invalidateSocket();
      }    
  }

  void listenReady(dynamic data)
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
          gotStatusCc(data);
      }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcConnection (listenReady) $error,$s'); 
    } 
  }

  void authenticate()
  {
//    gLogging.addToLogging('Authenticate (rpc:authenticate): $mIp : $mPort');    
    sendRequest("<auth1/>\n", cAuthenticate1);
  }

  void authenticate1(dynamic data)
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
        mCallback(this,mComputerIndex,false);                      
    } catch (error) {
      gLogging.addToLoggingError('RpcConnection (authenticate1) $error');       
      invalidateSocket();
    }
  }

  void authenticate2(dynamic data)
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
              isAuthenticated();           
              return;           
            }
          }
        }
        mbAuthenticated = false;               
        mCallback(this,mComputerIndex,false);
    } catch (error) {
      gLogging.addToLoggingError('RpcConnection (authenticate2) $error');        
      invalidateSocket();
    }
  }

  void isAuthenticated()
  {
    try
    {
      getState(); // we only get here when not connected
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcConnection (isAuthenticated) $error,$s'); 
    }

//    getHostInfo();
  }

  void getState()
  {
    try {
      var req = "<get_state/>\n";
      sendRequest(req, cState);  
    } catch (error,s) {
      gLogging.addToLoggingError('RpcConnection (getState) $mIp : $mPort : $error,$s'); 
      invalidateSocket();
    }     
  }

  void gotState(dynamic data)
  {
    try {
      mstate = xmlToJson(data,"<client_state>","</client_state>");
    //gLogging.addToLogging('State read for: $mComputer ($mIp:$mPort)');

      if (mstate == null)
      {
        mbAuthenticated = false;             
        mCallback(this, mComputerIndex,false);
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
        mCallback(this,mComputerIndex,true); 
        mbWeGotData = true;
        return;
      }  
      else
      {
        // not authorized
      }
      mbAuthenticated = false;             
      mCallback(this,mComputerIndex,false);
    } catch (error,s) {
      gLogging.addToLogging('RpcConnection (GotState) invalid xml $mIp : $mPort : $error,$s');
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
    try {    
    mstatus = xmlToJson(data,"<cc_status>","</cc_status>"); 
    if (mstatus == null)
    {
      mbAuthenticated = false;             
      mCallback(this,mComputerIndex,false);
      return;
    }
    if (mstatus.containsKey("cc_status"))
    {
      mCallback(this,mComputerIndex,true);  
      mbWeGotData = true;      
    }
    else
    {
      mCallback(this,mComputerIndex,false); 
    }
    } catch (error,s) {
      gLogging.addToLogging('RpcConnection (gotStatusCc) invalid xml $mIp : $mPort : $error,$s');
      invalidateSocket();
    }         
  }

  dynamic xmlToJson(dynamic xmls,tagBegin,tagEnd)
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
      gLogging.addToLoggingError('RpcConnection (xmlToJson) $error,$s'); 
    }       
  }

  Future<void> sendRequest(String msg,whereTo)
  async {
    try
    {
      mlistenData = "";
      var request = cRpcRequest1 + msg + cRpcRequest2;
      try {
        mdataBuffer = "";
        mwhereTo = whereTo;
        mSocket.writeln(request);
        await mSocket.flush();
      } catch (e) {
        invalidateSocket();
      }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcConnection (sendRequest) $error,$s'); 
    }     
  }

  void invalidateSocket()
  {  
    try
    {
      if (mbSocketValid)
      {
        try{mSocket.destroy();}catch(error){
          gLogging.addToDebugLogging('RpcConnection Socket destroy not needed: $mComputer, $mIp : $mPort');
        }
      }
      mbSocketValid = false;
      mbAuthenticated = false;
      mCallback(this,mComputerIndex,false);
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('RpcConnection (invalidateSocket) $error,$s'); 
    }    
  }


}