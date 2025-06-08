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
import 'dart:developer';
import 'dart:io';
import 'package:boinctasks/dialog/about.dart';
import 'package:boinctasks/dialog/color.dart';
import 'package:boinctasks/dialog/find_computers.dart';
import 'package:boinctasks/dialog/logging.dart';
import 'package:boinctasks/dialog/settings.dart';
import 'package:boinctasks/get_ip.dart';
import 'package:boinctasks/header.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/connections/rpcconnect.dart';
import 'package:boinctasks/project/add_project.dart';
import 'package:boinctasks/sort_header.dart';
import 'package:boinctasks/tabs/computers.dart';
import 'package:flutter/material.dart';
import 'package:boinctasks/connections/rpc.dart';
import 'package:boinctasks/constants.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

// thanks to https://github.com/jstoyles/flutter_data_view_idea/blob/main/lib/main.dart
// using Flavors https://docs.flutter.dev/deployment/flavors

var readSettings = "";
var gsettings = []; // List
var gcolorsContents = ""; // String
var gbsettingRead = false;
var gbcolorsRead = false;
// ignore: avoid_init_to_null
//var glocalFilePath;

late BtLogging gLogging;
//late BtSettings mBtSettings;
late BtColors mBtColors;

var mRpc = RpcCombined();
late Timer mConnectionTimer;
var mConnectionTimeout = 60;    // once a minute
var mRpcConnection = RpcCheckConnection();
var mDoConnectionCheck = true;

Map mHeader = {};
List mRows = [];
//var _currentTab = cTabProjects;
//var _currentTab = cTabTransfers;
//var _currentTab = cTabTasks;
//var _currentTab = cTabMessages;
var _currentTab = cTabTasks;
var mCurrentTabActual = "";
var mbHeaderResize = false;


var mProgress = "I";

//sizing for headers, row headers, rows, and columns
const double pageHeaderHeight = 0;
const double headerHeight = 60;
const double rowHeaderHeight = 0;
const double headerFontSize = 16;
const double rowHeight = 50;
const double columnSideMargins = 1;
const double columnSideMarginsFirst = 4;
const double columnBottomMargins = 10;
const double columnWidth = 150 + (columnSideMargins*2);

//colors for headers, row headers, and rows
const pageHeaderColor = Color.fromRGBO(51, 102, 153, 1);
const headerColor = Color.fromRGBO(0, 102, 204, 1);
const rowHeaderColor = Color.fromRGBO(51, 153, 255, 1);
const rowColor = Color.fromRGBO(153, 204, 255, 1);

const pageHeaderFontColor = Colors.white;
const headerFontColor = Colors.white;
const rowHeaderFontColor = Colors.white;
const rowFontColor = Color.fromARGB(255, 0, 0, 0);

var _filterRemove = "";
var _updateNow = false;
var _sortTasks = "";

var grefreshRate = 3;
bool gbDebug = false;

loadData() async {
  mRows = [];
  mRows.add({
    'row' : 1,
    'col_1':'Initializing',
    'col_2':'This may take a while.',    
  });
}

Future<String> get gLocalPath async {
  Directory? directory;
//  var directory = Directory('.' );


  if (Platform.isAndroid){
    directory = await getExternalStorageDirectory();
  }else
  {
    directory = await getApplicationDocumentsDirectory(); //getApplicationDocumentsDirectory();
  }
  var path = directory?.path;
  if (path != null)  
  {
    return path;
  }
  return "";
}

void main(){
  gLogging = BtLogging();
//  mRpc.init();
  mBtColors = BtColors();
  mBtColors.init();

  loadData(); //load the initial data

  runApp(
    MaterialApp(
      title: cBoincTasksM,
      home: const BtDataView(title: cBoincTasksM),
      theme: ThemeData(
        scaffoldBackgroundColor:const Color.fromARGB(255, 244, 244, 244),
      ),
    ),  
  );
}

class BtDataView extends StatefulWidget {
  const BtDataView({super.key, required this.title});
  final String title;

  @override
  State<BtDataView> createState() => BtViewState();
}

class MyAppBar extends AppBar {
  MyAppBar({super.key});
}

class BtViewState extends State<BtDataView> with WidgetsBindingObserver{
  final ScrollController _headerController = ScrollController();
  final ScrollController _rowController = ScrollController();
  late List<String> menuItems;
  bool mHeaderResizing = false;
  String mTitle = cBoincTasksM;
  bool mAppSleep = false;

  @override
  initState()
  {
    try{
      super.initState();
  //    glocalFilePath = _localPath;
      gLogging.init();

      mcomputersClass.init();
      gHeaderInfo.init();
      gSortHeader.init();
      readColorsFile();
      readSettingsFile();
      timer();
      mConnectionTimer = Timer(Duration(seconds: mConnectionTimeout), checkConnection);

      WidgetsBinding.instance.addObserver(this);  // detecting pause and resume
      setState((){});
    }
    catch(error)
    {
      // ignore: unused_local_variable
      var ii=1;
    }
  }

  @override
  dispose()
  {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      mAppSleep = true;
      // initState(); as a last resort...
      // still there
      // E/flutter (20691): [ERROR:flutter/runtime/dart_vm_initializer.cc(41)] Unhandled Exception: SocketException: Software caused connection abort (OS Error: Software caused connection abort, errno = 103),
      mRpc.abort();           // close all sockets because we get unhandled socket errors.
      mRpcConnection.abort(); // the same
      log('AppLifecycleState.paused)');
      gLogging.addToDebugLogging('Main (lifecycle paused) paused');
      gLogging.addToLoggingError('Notice: Main (lifecycle paused) paused'); 
      // went to Background
    }
    if (state == AppLifecycleState.resumed) {
      mAppSleep = false;
      //initState(); if all else fails...
      log('AppLifecycleState.resumed)');
      gLogging.addToDebugLogging('Main (lifecycle resumed) resumed');  
      gLogging.addToLoggingError('Notice: Main (lifecycle resumed) resumed');             
      // came back to Foreground
    }
  }

  void showComputers()
  {
    try
    {
      var ret = mcomputersClass.getTab();
      mHeader = ret[0];
      mRows = ret[1];
      setState((){});
      mTitle = txtTitleComputers;
    } catch (error,s) {
      gLogging.addToLoggingError('Main (showComputers) $error,$s'); 
    }  
  }

  var bFirst = true;

  void gotResults(ret)
  { 
    try
    {
      mHeader = ret[0];    
      mRows = ret[1];
      setState((){});
      mCurrentTabActual = cTabTasks;
      mTitle = txtTitleTasks;
    } catch (error,s) {
      gLogging.addToLoggingError('Main (gotResults) $error,$s'); 
    }      
  }

  void gotProjects(ret)
  {    
    try{
      mHeader = ret[0];
      mRows = ret[1];
      setState((){});
      mCurrentTabActual = cTabProjects;  
      mTitle = txtTitleProjects;
    } catch (error,s) {
      gLogging.addToLoggingError('Main (gotProjects) $error,$s'); 
    }      
  }

  void gotMessages(ret)
  {
    try
    {
      mHeader = ret[0];
      mRows = ret[1];
      setState((){});
      mCurrentTabActual = cTabMessages; 
      mTitle = txtTitleMessages;
    } catch (error,s) {
      gLogging.addToLoggingError('Main (gotMessages) $error,$s'); 
    }      
  }

  void gotTransfers(ret)
  {
    try
    {
      mHeader = ret[0];
      mRows = ret[1];
      setState((){});
      mCurrentTabActual = cTabTransfers;
      mTitle = txtTitleTransfers;
    } catch (error,s) {
      gLogging.addToLoggingError('Main (gotTransfers) $error,$s'); 
    }    
  }

  void gotTimeOut()
  {
//    _currentTab = cTabComputers;  // switch to computer tab to show that nothing is connected.

    checkConnection();

 //   _currentTabActual = _currentTab;
 //   var ret = mComputers.getTab();
 //   gHeader = ret[0];
 //   _rows = ret[1];
 //   setState((){});    
  }

  void timer()
  {
    try
    {
      var bInitial = true;
      var updateInterval = 2; // no less than 2 we need to give isConnected time to find connected computers.
      var maxInitialize = 100;
      var maxBusy = 600;
      var busyCnt = maxBusy;
      var sec = 0;  
      var secm = 100;   // 100 mSec = 0.1 sec
      Timer.periodic(Duration(milliseconds: secm), (timer) {       
        var busy = mRpc.getBusy();
        if (mAppSleep)
        {
          busy= true;
          busyCnt = maxBusy;
        }
        if (mHeaderResizing)
        {
          busy= true;
        }
        if (bInitial)
        {
          busyCnt = maxBusy;
          updateInterval = 1;   
          if (maxInitialize-- < 0)
          {
            bInitial = false; // timeout
          }          
          busy = true;  // settings not read back.
          if (gbsettingRead && gbcolorsRead)
          {
            var version = gLogging.getVersion();
            mTitle = "${widget.title} V:$version";
            setState((){});
            getSettings();   
            gLogging.debugMode(gbDebug);
            bInitial = false;            
          }
        }
        if (busy)
        {
          busyCnt--;
          if (busyCnt < 0)
          {
            mRpc.forceNotBusy();
            busyCnt = maxBusy;          
          }
          sec = updateInterval;

          if (busyCnt == (maxBusy-10))
          {
            mProgress = "⧗";
            setState((){});   
          }

        } else 
        {
          if (mDoConnectionCheck)
          {
            if (mAppSleep)
            {
              mDoConnectionCheck = false;
            }
            else
            {
              if (!mRpcConnection.getBusy())
              {
//                mRpcConnection = RpcCheckConnection();
                mRpcConnection.isConnected();
                mDoConnectionCheck = false;
              }
              else
              {
                // ignore: unused_local_variable
                var ii = 1;
              }
            }
          }

          busyCnt = maxBusy;
          var sec10 = sec/10;
          if (sec10.toInt() == sec/10 )
          {
            var bar = "▁▂▃▄▅▆▇";
            int lenBar = bar.length-1;
            var barPos = sec10.toInt();
            if (barPos > lenBar)
            {
              barPos = lenBar;
            }
            mProgress = bar.substring(barPos, barPos+1);
            setState((){});        
          }                 
          sec--;      
          if (_updateNow)
          {
            _updateNow = false;
            sec = 0;
          }
          if (sec <= 0)
          {
            mProgress = "⇊";
            // get interval from setttings
            updateInterval = grefreshRate;
            updateInterval *=10; // to mSec
            updateInterval += 3; // 3 mSec added to show blank bar            
            sec = updateInterval;
            updateComputers();
          }
        }
      });
    } catch (error,s) {
      gLogging.addToLoggingError('Main (timer) $error,$s'); 
    } 
  } 

  void updateComputers()
  {
    var busy = mRpc.getBusy();
    if (!busy)
    {
      _updateNow = false;
      var sort = "";
      try{
        switch(_currentTab)
        {
          case cTabTasks:
          {
            sort = _sortTasks;
          }
        }
        if (_currentTab == cTabComputers)
        {
          showComputers();
          return;
        }
        mRpc.setBusy();
        bool berror = mRpc.send(this,_currentTab,sort,_filterRemove,"<boinc_gui_rpc_request>\n<get_cc_status/>\n</boinc_gui_rpc_request>\n\u0003");
        if (berror)
        {
          _currentTab = cTabComputers;
          _updateNow = true;
        }
      } catch(error,s) {
        gLogging.addToLoggingError('Main (updateComputers) $error,$s'); 
      }
    }  
  }

GestureDetector gestureColumn(columnWidth, columnText)
{
  double startHorizontal = 0;
  var widthHeader = mHeader[columnWidth].roundToDouble();

  return  GestureDetector (
    behavior: HitTestBehavior.translucent,
    onTap: (){
        if (!mbHeaderResize)
        {
         tappedHeader(mHeader[columnText], false);
        }
    },
    onLongPress: (){
      if (!mbHeaderResize)
      {
        tappedHeader(mHeader[columnText], true);
      }
    }, 

    child: Container(width:widthHeader, padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins), child:Align(alignment:Alignment.centerLeft, child:Text(mHeader[columnText], style:const TextStyle(fontWeight:FontWeight.bold, color:headerFontColor, fontSize:headerFontSize)) ) ),
    onHorizontalDragStart: (details) 
    {
      if (mbHeaderResize)
      {
        startHorizontal = details.localPosition.dx;
        mHeaderResizing = true;
      }
    },    
    onHorizontalDragUpdate: (details)
    {
      if (mbHeaderResize)
      {    
  //      var newWidth = (details.globalPosition.dx - startHorizontal).roundToDouble();
        var newWidth = (details.localPosition.dx - startHorizontal).roundToDouble(); 
        if (newWidth < cMinHeaderWidth )
        {
          newWidth = cMinHeaderWidth;
        }
        mHeader[columnWidth]= newWidth;     
        setState(() {});
      }
    },    
    onHorizontalDragEnd: (details)
    {
      if (mbHeaderResize)
      {   
        var width = mHeader[columnWidth].roundToDouble();
        headerWidthChanged(mHeader[cHeaderTab],columnText,columnWidth,width);
        mHeaderResizing = false;
      }
    },
   
  );
}

checkConnection()
  {
    mConnectionTimer.cancel();
    mDoConnectionCheck = true;
    mConnectionTimer = Timer(Duration(seconds: mConnectionTimeout), checkConnection);
  }

  setMenu()
  {
    try{
      var len = mRpc.mRpc.length;
      menuItems = [];
      for (var i=0;i< len;i++)
      {
        menuItems.add(mRpc.mRpc[i].mComputer);
      }

      switch (_currentTab)
      {
        case cTabComputers:
          menuItems = [txtComputersAdd,txtComputersFind];      
        case cTabTasks:
          if (mRpc.isSelectedWu()) {
            menuItems = [txtTasksCommandSuspended,txtTasksCommandResume,txtTasksCommandAborted,txtProperties];}
          else { menuItems = []; }
        case cTabProjects:
          if (mRpc.isSelectedProjects()) {
            menuItems = [txtProjectsCommandSuspended,txtProjectsCommandResume,txtProjectCommandUpdate,txtProjectCommandNoMoreWork,txtProjectCommandAllowMoreWork, txtProperties, txtProjectCommandAdd];
          }
          else {
            menuItems = [txtProjectCommandAdd];
          }
        case cTabTransfers:
          menuItems = [txtTransfersCommandRetry];
        case cTabMessages:
      }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('main (setMenu): $error,$s');
    }  
  }
 
  @override
  Widget build(BuildContext context){    
    //scroll headers to match scrolling data
    _rowController.addListener((){
      _headerController.jumpTo(_rowController.offset);
    });
    var lenRow = mRows.length;
    setMenu();
    
    var title = "$mProgress $mTitle";//${widget.title} V:$_programVersion";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
        // popup Menu
        actions: [
          // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> projects
          if (_currentTab==cTabProjects)
            if (mRpc.isSelectedProjects())          
            IconButton(
              icon: const Icon(Icons.autorenew),
              tooltip: txtProjectCommandUpdate,
              onPressed: () async {
                mRpc.commandsTab(_currentTab,txtProjectCommandUpdate,context); 
              },
            ),           
          if (_currentTab==cTabProjects)
            if (mRpc.isSelectedProjects())          
            IconButton(
              icon: const Icon(Icons.pause),
              tooltip: txtProjectsCommandSuspended,
              onPressed: () async {
                mRpc.commandsTab(_currentTab,txtProjectsCommandSuspended,context); 
              },
            ), 
          if (_currentTab==cTabProjects)
            if (mRpc.isSelectedProjects())
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: txtProjectsCommandResume,
              onPressed: () async {
                mRpc.commandsTab(_currentTab,txtProjectsCommandResume,context); 
              },
            ),
          // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> messages

          // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> tasks
          if (_currentTab==cTabTasks)
            if (mRpc.isSelectedWu())
            IconButton(
              icon: const Icon(Icons.pause),
              tooltip: 'Pause',
              onPressed: () async {
                mRpc.commandsTab(_currentTab,txtTasksCommandSuspended,context); 
              },
            ), 
          if (_currentTab==cTabTasks)
            if (mRpc.isSelectedWu())          
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Resume',
              onPressed: () async {
                mRpc.commandsTab(_currentTab,txtTasksCommandResume,context); 
              },
            ), 

          // tab popup
          PopupMenuButton(
            icon: const Icon(Icons.task_alt),
            itemBuilder: (context) => menuItems.map((e) => PopupMenuItem(value: e, child: Text(e))).toList(),
              onSelected: (command) {
                switch(command)
                {
                  case txtComputersAdd:
                    addComputer();
                  case txtComputersFind:                 
                    findComputerAndroidIos(context);                   
                  case txtProjectCommandAdd:
                    var pc = AddProject();
                    pc.start(context);
                    return;
                  default:
                    mRpc.commandsTab(_currentTab,command,context);                  
                }
            },
          ),

          // select tab
          PopupMenuButton<String>(
            icon: const Icon(Icons.list),
            onSelected: (String value) {
              setState(() {
                if (value == 'adjust')
                {
                  mbHeaderResize = !mbHeaderResize;                  
                }
                else
                {
                  _currentTab = value;
                }
                _updateNow = true;                
              });
            },
            itemBuilder: (BuildContext context) => [
              CheckedPopupMenuItem(
                checked: (_currentTab==cTabComputers),
                value: cTabComputers,
                child: const Text('Computer'),
              ),
              CheckedPopupMenuItem(
                checked: (_currentTab==cTabProjects),              
                value: cTabProjects,
                child: const Text('Project'),
              ),
              CheckedPopupMenuItem(
                checked: (_currentTab==cTabTasks),                     
                value: cTabTasks,
                child: const Text('Tasks'),
              ),                
              CheckedPopupMenuItem(
                checked: (_currentTab==cTabTransfers),           
                value: cTabTransfers,
                child: const Text('Transfers'),
              ), 
              CheckedPopupMenuItem(
                checked: (_currentTab==cTabMessages),                  
                value: cTabMessages,
                child: const Text('Messages'),
              ),
              CheckedPopupMenuItem(
                checked: mbHeaderResize,
                value: 'adjust',
                child: const Text('Adjust header width'),
              ),               
            //  CheckedPopupMenuItem(
            //    checked: (_currentTab==cTabNotices),                 
            //    value: cTabNotices,
            //    child: const Text('Notices'),
            //  ),               
            ],
          ),

          // app menu
          PopupMenuButton<String>(    
            icon: const Icon(Icons.settings),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: '1',
                child: Text('BoincTasks settings'),
              ),                           
              const PopupMenuItem(
                value: '2',
                child: Text('Set color'),
              ),              
              const PopupMenuItem(
                value: '4',
                child: Text('Show log'),
              ),
              const PopupMenuItem(
                value: '5',
                child: Text('Show error log'),
              ),                
              const PopupMenuItem(
                value: '6',
                child: Text('About'),
              ),               
            ],
            onSelected: (String value) {
              setState(() {
                if (value == '1')
                {
                  showDialog(
                    context: context,
                    builder: (myApp) {
                      //SettingsDialog;
                      return const SettingsDialog();
                    }
                  );              
                }
                if (value == '2')
                {
                  mBtColors.openDialog(context);
                }                                  
                if (value == '4')
                {
                  gLogging.openDialog(gLogging,context);                
                }
                if (value == '5')
                {
                  gLogging.openDialogError(context);
                }                 
                if (value == '6')
                {                 
                  var version = gLogging.getVersion();                   
                  var about = BtAbout();
                  about.openDialog(version,context);                
                }                                
              });
            },              
          ),
        ]

        
        // Popup Menu

      ),

      body: SafeArea(
        child: Stack(children: [
          SingleChildScrollView(
              scrollDirection:Axis.vertical,
              child: Stack(                  
                  children:[
                  SingleChildScrollView(scrollDirection:Axis.horizontal,
                      physics: const ClampingScrollPhysics(),
                      controller: _rowController,
                      child:Container(
                          padding:const EdgeInsets.only(top: (rowHeaderHeight + headerHeight + pageHeaderHeight) - (rowHeaderHeight/2) ),
                          child: Column(children:[
                            Column(children: mRows.asMap().map((k, v) {
                              var children = [
                                        InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_1'],v,context);
                                          },
                                          child:
                                            Container(color:v['color'], width:mHeader["col_1_w"], padding:const EdgeInsets.only(left:columnSideMarginsFirst, right:columnSideMargins, bottom:columnBottomMargins),
                                              child:Align(alignment:Alignment.centerLeft,
                                              child:Text(v['col_1'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                              style:TextStyle(color:v['colorText'])) ) )
                                        ),
                                        InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_2'],v,context);                                          
                                          },
                                          child:
                                            Container(color:v['color'], width:mHeader["col_2_w"], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins),
                                              child:Align(alignment:Alignment.centerLeft, child:Text(v['col_2'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                                  style:TextStyle(color:v['colorText'])) ) )
                                        ),                                        
                                        if (mHeader.containsKey('col_3')) InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_3'],v,context);  
                                          },
                                          child:
                                            Container(color:v['color'], width:mHeader["col_3_w"], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins),
                                              child:Align(alignment:Alignment.centerLeft, child:Text(v['col_3'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                                style:TextStyle(color:v['colorText'])) ) )
                                        ),                                    
                                        
                                        if (mHeader.containsKey('col_4')) InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_4'],v,context);  
                                          },
                                          child:
                                            Container(color:v['color'], width:mHeader["col_4_w"], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins), 
                                              child:Align(alignment:Alignment.centerLeft, child:Text(v['col_4'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                                  style:TextStyle(color:v['colorText'])) ) )
                                        ),
                                        if (mHeader.containsKey('col_5')) InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_5'],v,context);  
                                          },
                                          child:
                                            Container(color:v['color'], width:mHeader["col_5_w"], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins),
                                              child:Align(alignment:Alignment.centerLeft, child:Text(v['col_5'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                              style:TextStyle(color:v['colorText'])) ) )
                                        ),  
                                        if (mHeader.containsKey('col_6')) InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_6'],v,context);  
                                          },
                                          child:
                                            Container(color:v['color'], width:mHeader["col_6_w"], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins),
                                              child:Align(alignment:Alignment.centerLeft, child:Text(v['col_6'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                              style:TextStyle(color:v['colorText'])) ) )
                                        ),                                                                                                                                                 
                                        if (mHeader.containsKey('col_7')) InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_7'],v,context);  
                                          },
                                          child:
                                            Container(color:v['color'], width:mHeader["col_7_w"], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins),
                                              child:Align(alignment:Alignment.centerLeft, child:Text(v['col_7'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                              style:TextStyle(color:v['colorText'])) ) )
                                        ),
                                        if (mHeader.containsKey('col_8')) InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_8'],v,context);  
                                          },
                                          child:
                                            Container(color:v['color'], width:mHeader["col_8_w"], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins), 
                                              child:Align(alignment:Alignment.centerLeft, child:Text(v['col_8'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                              style:TextStyle(color:v['colorText'])) ) )
                                        ),

                                    ];
                              return MapEntry(k,
                                Container(
                                  height:k==lenRow-1?rowHeight:rowHeight+rowHeaderHeight,
                                  margin:k==lenRow-1?const EdgeInsets.only(top:rowHeaderHeight/2):const EdgeInsets.only(top:0),
                                  child:Row(
                                    children:children
                                  )
                                )
                            );
                            }).values.toList())
                          ])
                      )
                  )
                ]
              )
          ),
          
          // header
          Container(
            color:headerColor,
            height:headerHeight,
            margin:const EdgeInsets.only(top:pageHeaderHeight),
            child: SingleChildScrollView(
              controller: _headerController,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection:Axis.horizontal,
              child:Row(children:[
                  if (mHeader.containsKey('col_1')) gestureColumn('col_1_w', 'col_1'),
                  if (mHeader.containsKey('col_2')) gestureColumn('col_2_w', 'col_2'),
                  if (mHeader.containsKey('col_3')) gestureColumn('col_3_w', 'col_3'),
                  if (mHeader.containsKey('col_4')) gestureColumn('col_4_w', 'col_4'),
                  if (mHeader.containsKey('col_5')) gestureColumn('col_5_w', 'col_5'),
                  if (mHeader.containsKey('col_6')) gestureColumn('col_6_w', 'col_6'),
                  if (mHeader.containsKey('col_7')) gestureColumn('col_7_w', 'col_7'),
                  if (mHeader.containsKey('col_8')) gestureColumn('col_8_w', 'col_8'),
                  if (mHeader.containsKey('col_9')) gestureColumn('col_9_w', 'col_9'),
                ]
              )
            )
          ),
        ]
      )      
    )
    );   
  }

  tapped(type,item,v,context) {    
    var computer = v['computer'];
    switch(type)
    {
      case cTypeComputer:
        computerTap(computer,context);  
      case cTypeResult:
        mRpc.selectedWu(computer,v['col_3'],v['col_4']);
        _updateNow = true;
      case cTypeProject:
        mRpc.selectedProject(computer,v['col_2']);
        _updateNow = true;        
      case cTypeTransfer:
        mRpc.selectedTransfer(computer,v['col_2'],v['col_3']);
        _updateNow = true;         
      case cTypeFilter:       // when the filter is enabled
      case cTypeFilterWuArr:  // when the filter is disabled
        if (item.toLowerCase().contains(cTextFilter.toLowerCase()))
        {
          var app = v['col_2'];
          var status = v['col_8'];
          var filter = computer+app+status;
          if (_filterRemove == filter)
          {
            _filterRemove = ""; // remove filter
          }
          else
          {
            _filterRemove = filter;
          }
          _updateNow = true;
        }
        else
        {
          mRpc.selectedWu(computer,v['col_3'],v['col_4']);
          _updateNow = true;          
        }
    }
  }

  tappedHeader(header, bLong)
  {
    gSortHeader.setSort(mCurrentTabActual, header, bLong);
    _updateNow = true;
//    switch(_currentTabActual)
//    {
//        case cTabTasks:
//        {
//
//        }
//    }
  }

  headerWidthChanged(tab, columnText, columnWidth, newWidth)
  {
    mRpc.updateHeader(tab, columnText, columnWidth, newWidth);
  }

  computerTap(dynamic computer, dynamic context)
  async {
    await  computerDialog(computer, context);   
  }

  addComputer()
  async {
    await computerDialog(cComputerNewName, context);   
  }
  
  
  computerDialog(computer, context)
  async {
     await showDialog(
      context: context,
      builder: (myApp) {
        if(MediaQuery.of(context).orientation == Orientation.landscape) 
        { 
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        }        
        return AddComputersDialog(computer, onConfirm: (String ret) { 
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeRight,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);          
          if (ret == '#OK#')
          {
            gotTimeOut();
            return;
          }
          if (ret == '#ENABLED#')
          {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(txtComputersDelete,
                style: TextStyle(fontSize: 20),
              ),
              duration: const Duration(seconds: 10),
              backgroundColor: const Color.fromARGB(255, 253, 40, 40),
              padding: EdgeInsets.all(40),

            ));            
            gotTimeOut();
            return;
          }
         },);
      }
     );
  }

Future okDialog(title, text, context)
async {
    await showDialog(
    context: context,
    builder: (myApp) {   
      return OkDialog(title,text, onConfirm: (bool ret) {
        return ret;
        },);
      }
    );
  }
 
}