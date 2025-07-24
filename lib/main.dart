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
import 'package:boinctasks/dialog/color/color.dart';
import 'package:boinctasks/dialog/about.dart';
import 'package:boinctasks/dialog/color/dlg_color.dart';
import 'package:boinctasks/dialog/find_computers.dart';
import 'package:boinctasks/dialog/logging.dart';
import 'package:boinctasks/dialog/settings.dart';
import 'package:boinctasks/get_ip.dart';
import 'package:boinctasks/tabs/computer/allow_computer.dart';
import 'package:boinctasks/tabs/graph/graphs.dart';
import 'package:boinctasks/tabs/graph/show_graph.dart';
import 'package:boinctasks/tabs/misc/header.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/connections/connection_check/rpccheck_connection.dart';
import 'package:boinctasks/tabs/project/add_project.dart';
import 'package:boinctasks/tabs/misc/sort_header.dart';
import 'package:boinctasks/tabs/computer/computers.dart';
import 'package:flutter/material.dart';
import 'package:boinctasks/connections/rpc.dart';
import 'package:boinctasks/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart'; 

// thanks to https://github.com/jstoyles/flutter_data_view_idea/blob/main/lib/main.dart
// using Flavors https://docs.flutter.dev/deployment/flavors

var gSystemColor = SystemColor();

var readSettings = "";
var gsettings = []; // List
var gcolorsContents = ""; // String
var gbsettingReadWait = 0;
var gbsettingRead = false;
var gbcolorsRead = false;
// ignore: avoid_init_to_null
//var glocalFilePath;

late BtLogging gLogging;
late BtColors mBtColors;

var gRpc = RpcCombined();
late Timer mConnectionTimer;  // once a minute
var gDoConnectionCheck = true;

Map gHeader = {};
List gRows = [];
//var _currentTab = cTabProjects;
//var _currentTab = cTabTransfers;
//var _currentTab = cTabTasks;
//var _currentTab = cTabMessages;
var gbHeaderResize = false;


var gProgress = "I";

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

var _filterRemove = "";
var _updateNow = false;
var _sortTasks = "";

var gMaxBusySec = 15;
var gReconnectTimeout = 30;
var gSocketTimeout = 15;
var grefreshRate = 3;
bool gbForceRefresh = true;
bool gbDarkMode = false;
bool gbDebug = false;

loadData() async {
  gRows = [];
  gRows.add({
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

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  scaffoldBackgroundColor:const Color.fromARGB(255, 244, 244, 244),
    filledButtonTheme:
      FilledButtonThemeData(
      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(gSystemColor.headerColor)),
    ),        
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.indigo,  
  scaffoldBackgroundColor:const Color.fromARGB(255, 103, 102, 102),
    filledButtonTheme:
      FilledButtonThemeData(
      style: ButtonStyle(backgroundColor: WidgetStateProperty.all(gSystemColor.headerColor), foregroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 255, 255, 255))),
    ),        
);

setTheme(bool bDark)
{
  gSystemColor.setTheme(bDark);
}

getTheme()
{
  if (gbDarkMode)
  {
    return darkTheme;
  }
  return lightTheme;
}

late ThemeProvider appThemeProvider;
bool bAppThemeProviderValid = false;

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;  
  ThemeMode get themeMode => _themeMode;

  void setLight()
  {
    _themeMode = ThemeMode.light;
    notifyListeners();
    setTheme(false);      
  }

  void setDark()
  {
    _themeMode = ThemeMode.dark;
    notifyListeners();
    setTheme(true);
  }
}

getConnectedComputers()
{
  List lconnected = [];    
  try{    
    var lenList = gComputerList.length;
    for (var i=0;i<lenList;i++)
    {
      var enabled = gComputerList[i][cComputerEnabled];
      if (enabled == "1")
      {
        var connected = gComputerList[i][cComputerConnected];  
        if (connected == "2")
        {
          lconnected.add(gComputerList[i][cComputerName]);
        }
      }
    }
  }
  catch(error,s)
  {
    gLogging.addToLoggingError('main (getConnectedComputers): $error,$s');
  }
  return lconnected;           
}

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  gLogging = BtLogging();  
  readSettingsFile();
  mainWaitSettings();
}

void mainWaitSettings()
{
  if (!gbsettingRead)
  {
      if (gbsettingReadWait++ > 20) // mSec
      {
        mainReady();  // not ready but we can't wait forever
      }
      Timer(const Duration(milliseconds: 100), mainWaitSettings);  
  }
  else
  {
    mainReady();  // generally takes 100 mSec to get here.
  }
}

void mainReady()
{
  mBtColors = BtColors();
  mBtColors.init();
  getSettings();  
  mBtColors.switchColorDarkOrLight();
  loadData(); //load the initial data
  setTheme(gbDarkMode);

  runApp(
    ChangeNotifierProvider (
      create: (_) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    appThemeProvider = Provider.of<ThemeProvider>(context);
    bAppThemeProviderValid = true;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          theme: getTheme(),
          themeMode: themeProvider.themeMode,
          home: BtDataView(),
          routes: <String, WidgetBuilder>{
            "/graph": (BuildContext context) => ShowLineChart()
          },          
        );
      },
    );
  }
}

class BtDataView extends StatefulWidget {
  const BtDataView({super.key});
  final String title = cBoincTasksM;

  @override
  State<BtDataView> createState() => BtViewState();
}

class MyAppBar extends AppBar {
  MyAppBar({super.key});
}

var gTab = BtViewState();
class BtViewState extends State<BtDataView> with WidgetsBindingObserver{
  final ScrollController _headerController = ScrollController();
  final ScrollController _rowController = ScrollController();
  late List<String> menuItems;
  bool mHeaderResizing = false;
  String mTitle = cBoincTasksM;
  bool mAppSleep = false;
  var mRefreshRateActual = 0;   
  var mCurrentTab = cTabTasks;
  var mCurrentTabActual = "";
  late RpcCheckConnection mRpcCheck;

  @override
  initState()
  {
    try{
      super.initState();

      gLogging.init();

      mcomputersClass.init();
      gHeaderInfo.init();
      gSortHeader.init();
      readColorsFile();
      mainTimer();
      mRpcCheck = RpcCheckConnection();      
      mConnectionTimer = Timer(Duration(seconds: gReconnectTimeout), checkConnection);

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
      gRpc.abort();           // close all sockets because we get unhandled socket errors.    
      mRpcCheck.abort();
      log('AppLifecycleState.paused)');
      gLogging.addToDebugLogging('Main (lifecycle paused) paused');
      // went to Background
    }
    if (state == AppLifecycleState.resumed) {
      gbForceRefresh = true;
      mAppSleep = false;
      mConnectionTimer = Timer(Duration(seconds: gReconnectTimeout), checkConnection);
      //initState(); if all else fails...
      log('AppLifecycleState.resumed)');
      gLogging.addToDebugLogging('Main (lifecycle resumed) resumed');
      // came back to Foreground
    }
  }

  var gbComputerReboot = false;

  restart()
  {
    var lenList = gComputerList.length;
    for (var i=0;i<lenList;i++)
    {
      gComputerList[i][cComputerConnected] = cComputerConnectedNot;
    }

    mRefreshRateActual = 0;   
    mCurrentTab = cTabComputers;
    mCurrentTabActual = "";    
    gbForceRefresh = true;
    if (mConnectionTimer.isActive)
    {
      mConnectionTimer.cancel();
    }
    gRpc.abort();           // close all sockets because we get unhandled socket errors.   
    mRpcCheck.abort();
    gDoConnectionCheck = true;
    mbBusyConnected = false;  // RpcCheckConnection    
    mainTimer();
    gbComputerReboot = false;
    gLogging.addToDebugLogging("Reboot app (restart)");
  }

  setTab(tab)
  {
    mCurrentTab = tab;
//    mCurrentTabActual = tab;    
    mRefreshRateActual = 0;
  }
  getTab()
  {
    return mCurrentTab;
  }
  
  getTabActual()
  {
    return mCurrentTabActual;
  }

  void showComputers()
  {
    try
    {
      var ret = mcomputersClass.getTab();
      ret = gSortHeader.sort(mCurrentTabActual, ret);      
      gHeader = ret[0];
      gRows = ret[1];
      setState((){});
      mCurrentTabActual = cTabComputers;      
      mTitle = txtTitleComputers;
    } catch (error,s) {
      gLogging.addToLoggingError('Main (showComputers) $error,$s'); 
    }  
  }

  //void gotComputers(ret)
 // {
 //   showComputers();
 // }

  var bFirst = true;

  void gotResults(ret)
  { 
    try
    {
      gHeader = ret[0];    
      gRows = ret[1];
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
      gHeader = ret[0];
      gRows = ret[1];
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
      gHeader = ret[0];
      gRows = ret[1];
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
      gHeader = ret[0];
      gRows = ret[1];
      setState((){});
      mCurrentTabActual = cTabTransfers;
      mTitle = txtTitleTransfers;
    } catch (error,s) {
      gLogging.addToLoggingError('Main (gotTransfers) $error,$s'); 
    }    
  }

  void gotGraphs(ret)
  {
    try
    {
      gGraphData = ret;
      if (mCurrentTabActual == cTabGraph)
      {
        setTab(cTabComputers);  // never stay on the virtual cTabGraph
      }
      else
      {
        setTab(mCurrentTabActual);
      }
      Navigator.of(context).pushNamed('/graph');
 
    } catch (error,s) {
      gLogging.addToLoggingError('Main (gotGraphs) $error,$s'); 
    }   
  }

  void gotAllow(ret)
  {
    try
    {
      mCurrentTabActual = cTabAllow;
    } catch (error,s) {
      gLogging.addToLoggingError('Main (gotTransfers) $error,$s'); 
    }    
  }

  void gotTimeOut()
  {
//    _currentTab = cTabComputers;  // switch to computer tab to show that nothing is connected.
    checkConnection();
  }

  Timer? timerRunning;
  void mainTimer()
  {
    try
    {      
      var bInitial = true;
      var updateInterval = 2; // no less than 2 we need to give isConnected time to find connected computers.
      var maxInitialize = 100;
      var maxBusyMs = gMaxBusySec*10;
      var busyCnt = maxBusyMs;
      var iBusyIcon = 0;
      var bBusyIcon = false;  
      var sec = 0;  
      mRefreshRateActual = 0;      
      var secm = 100;   // 100 mSec = 0.1 sec

      Timer.periodic(Duration(milliseconds: secm), (timer) {
        if (gbComputerReboot)
        {
          timer.cancel();         
          restart();
        }

        var busy = gRpc.getBusy();
        if (mAppSleep)
        {
          busy= true;
          busyCnt = maxBusyMs;
          if (mConnectionTimer.isActive)
          {
            mConnectionTimer.cancel();
          }
        }        
        if (mHeaderResizing)
        {
          busy= true;
        }
        if (bInitial)
        {
          busyCnt = maxBusyMs;
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
//            getSettings();   // to get refresh rate
            gLogging.debugMode(gbDebug);
            bInitial = false;            
          }
        }
        
        if (busy)
        {
          busyCnt--;
          if (busyCnt < 0)
          {
            gLogging.addToLogging("We seem to be stuck, try to reconnect by invalidating all sockets");
            mRpcCheck.abort();
            gRpc.forceNotBusy();         
          }

          sec = updateInterval;

          if (busyCnt < (100))    // 10 seconds
          {
            gDoConnectionCheck = true;
            if (bBusyIcon == true)
            {              
              switch(iBusyIcon)
              {
                case 0:
                  gProgress = "◐";
                  iBusyIcon = 1;
                case 1:
                  gProgress = "◓";
                  iBusyIcon = 2;
                case 2:
                  gProgress = "◑";
                  iBusyIcon = 3;
                default:
                  gProgress = "◒";
                  iBusyIcon = 0;
                  bBusyIcon = false;
              }
            }
            else
            {
              if (iBusyIcon == 0)
              {
                gProgress = "⧗";
              }
              iBusyIcon++;
              if (iBusyIcon > 4)
              {
                iBusyIcon = 0;
                bBusyIcon = true;
              }            
            }
            setState((){});               
          }
        } else 
        {
          if (gbForceRefresh)
          {
            gbForceRefresh = false;
            _updateNow = true;
            mRefreshRateActual = 0;
          }

          busyCnt = maxBusyMs;
          var sec10 = sec/10;
          if (sec10.toInt() == sec/10 )
          {
            var bar = "▁▂▃▄▅▆▇█▓▒";
            int lenBar = bar.length-1;
            var barPos = sec10.toInt();
            if (barPos > lenBar)
            {
              barPos = lenBar;
            }
            gProgress = bar.substring(barPos, barPos+1);
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
            gProgress = "⇊";
            updateInterval = mRefreshRateActual;
            updateInterval *= 10; // to .1 Sec
            updateInterval += 3; // .3 added to show blank bar            
            sec = updateInterval;
            if (mRefreshRateActual < grefreshRate)
            {
              mRefreshRateActual++;
            }
            if (mRefreshRateActual > grefreshRate)
            {
              mRefreshRateActual = grefreshRate;
            }
            if (mCurrentTab == cTabComputers)
            {
              if (mRefreshRateActual > 4)
              {
                mRefreshRateActual = 4;
              }
            }
            updateComputers();
          }

          if (gDoConnectionCheck)
          {
            if (mAppSleep)
            {
              gDoConnectionCheck = false;
            }
            else
            {
              if (!mbBusyConnected)
              {
                mConnectionTimer = Timer(Duration(seconds: gReconnectTimeout), checkConnection);                
                mRpcCheck.isConnected(); 
                gDoConnectionCheck = false;
              }
            }
          }          
        }
      });
    } catch (error,s) {
      gLogging.addToLoggingError('Main (timer) $error,$s'); 
    } 
  } 

  void updateComputers()
  {
    var busy = gRpc.getBusy();
    if (!busy)
    {
      _updateNow = false;
      var sort = "";
      try{
        var tab = getTab();
        switch(tab)
        {
          case cTabTasks:
          {
            sort = _sortTasks;
          }
          case cTabComputers:
          {
            showComputers();
            return;
          }
       
        }

//        if (tabActual != tab)
//        {
//          if (tabActual == cTabComputers)
//          {
//            setTab(cTabComputers);
//          }
//        }

        gRpc.setBusy();

        var toSend = "<boinc_gui_rpc_request>\n<get_cc_status/>\n</boinc_gui_rpc_request>\n\u0003";
        bool berror = gRpc.send(this,tab,sort,_filterRemove,toSend);
        if (berror)
        {
          setTab(cTabComputers);
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
  var widthHeader = gHeader[columnWidth].roundToDouble();

  return  GestureDetector (
    behavior: HitTestBehavior.translucent,
    onTap: (){
        if (!gbHeaderResize)
        {
         tappedHeader(gHeader[columnText], false);
        }
    },
    onLongPress: (){
      if (!gbHeaderResize)
      {
        tappedHeader(gHeader[columnText], true);
      }
    }, 

    child: Container(width:widthHeader, padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins), child:Align(alignment:Alignment.centerLeft, child:Text(gHeader[columnText], style:TextStyle(fontWeight:FontWeight.bold, color:gSystemColor.headerFontColor, fontSize:headerFontSize)) ) ),
    onHorizontalDragStart: (details) 
    {
      if (gbHeaderResize)
      {
        startHorizontal = details.localPosition.dx;
        mHeaderResizing = true;
      }
    },    
    onHorizontalDragUpdate: (details)
    {
      if (gbHeaderResize)
      {    
  //      var newWidth = (details.globalPosition.dx - startHorizontal).roundToDouble();
        var newWidth = (details.localPosition.dx - startHorizontal).roundToDouble(); 
        if (newWidth < cMinHeaderWidth )
        {
          newWidth = cMinHeaderWidth;
        }
        gHeader[columnWidth]= newWidth;     
        setState(() {});
      }
    },    
    onHorizontalDragEnd: (details)
    {
      if (gbHeaderResize)
      {   
        var width = gHeader[columnWidth].roundToDouble();
        headerWidthChanged(gHeader[cHeaderTab],columnText,columnWidth,width);
        mHeaderResizing = false;
      }
    },
   
  );
}

checkConnection()
  {
    mConnectionTimer.cancel();
    gDoConnectionCheck = true;
  }

  setMenu()
  {
    try{
      var len = gRpc.mRpc.length;
      menuItems = [];
      for (var i=0;i< len;i++)
      {
        menuItems.add(gRpc.mRpc[i].mComputer);
      }

      switch (getTab())
      {
        case cTabComputers:
          var list = getConnectedComputers();
          len = list.length;
          if (len > 0)
          {
            menuItems = [txtComputersAdd,txtComputersFind,txtComputersAllow];      
          }
        else
        {
          menuItems = [txtComputersAdd,txtComputersFind];   
        }
        case cTabTasks:
          if (gRpc.isSelectedWu()) 
          {
            menuItems = [txtTasksCommandSuspended,txtTasksCommandResume,txtTasksCommandAborted,txtProperties];
          }
          else { menuItems = [txtCommandSelectFirst]; }
        case cTabProjects:
          if (gRpc.isSelectedProjects()) {
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
    var lenRow = gRows.length;
    setMenu();

    var version = gLogging.getVersion();     
    
    double width = MediaQuery.of(context).size.width;  

    Color colorSelectComputer = gSystemColor.headerColor;
    Color colorSelectProjects = gSystemColor.headerColor;
    Color colorSelectTasks    = gSystemColor.headerColor;
    Color colorSelectTransfers= gSystemColor.headerColor;    
    Color colorSelectMessages = gSystemColor.headerColor;
    var tab = getTab();
    switch (tab)
    {
      case cTabComputers:
        colorSelectComputer = gSystemColor.tabSelectColor;
      case cTabProjects:
        colorSelectProjects = gSystemColor.tabSelectColor;
      case cTabTasks:
        colorSelectTasks    = gSystemColor.tabSelectColor;
      case cTabMessages:
        colorSelectMessages = gSystemColor.tabSelectColor;                
    }

    var title = "$gProgress $mTitle";//${widget.title} V:$_programVersion";

    return Scaffold(
      backgroundColor: gSystemColor.pageHeaderColor,  
      appBar: AppBar(
        title: Text(title),
        backgroundColor: gSystemColor.pageHeaderColor,
        // popup Menu
        actions: [
          // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> switch tab buttons
          if (width > cWidthShowButtonsAll)
            FilledButton.icon(
              onPressed: () {
                setTab(cTabComputers);
                _updateNow = true; 
              },
              label: Text(txtTitleComputers),
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(colorSelectComputer)),
            ),
          if (width > cWidthShowButtonsAll) 
            Text(" "), // divider

          if (width > cWidthShowButtons)            
            FilledButton.icon(
              onPressed: () {
                setTab(cTabProjects);
                _updateNow = true; 
              },
              label: Text(txtTitleProjects),
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(colorSelectProjects)),              
            ), 
          if (width > cWidthShowButtons) 
            Text(" "), // divider

          if (width > cWidthShowButtons)            
            FilledButton.icon(
              onPressed: () {
                setTab(cTabTasks);
                _updateNow = true; 
              },
              label: Text(txtTitleTasks),
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(colorSelectTasks)),
            ),
          if (width > cWidthShowButtons) 
            Text(" "), // divider 

          if (width > cWidthShowButtonsAll2)
            FilledButton.icon(
              onPressed: () {
                setTab(cTabTransfers);
                _updateNow = true; 
              },
              label: Text(txtTitleTransfers),
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(colorSelectTransfers)),
            ),
          if (width > cWidthShowButtons) 
            Text(" "), // divider 


          if (width > cWidthShowButtons)            
            FilledButton.icon(
              onPressed: () {
                setTab(cTabMessages);
                _updateNow = true;               
            },
              label: Text(txtTitleMessages),
              style: ButtonStyle(backgroundColor: WidgetStateProperty.all(colorSelectMessages)),              
            ),                     
          if (width > cWidthShowButtons) 
            Text(" "), // divider

          // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> projects
          if (tab==cTabProjects)
            if (gRpc.isSelectedProjects())          
            IconButton(
              icon: const Icon(Icons.autorenew),
              tooltip: txtProjectCommandUpdate,
              onPressed: () async {
                gRpc.commandsTab(tab,txtProjectCommandUpdate,context); 
              },
            ),           
          if (tab==cTabProjects)
            if (gRpc.isSelectedProjects())          
            IconButton(
              icon: const Icon(Icons.pause),
              tooltip: txtProjectsCommandSuspended,
              onPressed: () async {
                gRpc.commandsTab(tab,txtProjectsCommandSuspended,context); 
              },
            ), 
          if (tab==cTabProjects)
            if (gRpc.isSelectedProjects())
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: txtProjectsCommandResume,
              onPressed: () async {
                gRpc.commandsTab(tab,txtProjectsCommandResume,context); 
              },
            ),
          // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> messages
          // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> transfers
          if (tab==cTabTransfers)
            if (gRpc.isSelectedTransfers())
            IconButton(
              icon: const Icon(Icons.autorenew),
              tooltip: 'Retry',
              onPressed: () async {
                gRpc.commandsTab(tab, txtTransfersCommandRetry,context); 
              },
            ),
  
          // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> tasks
          if (tab==cTabTasks)
            if (gRpc.isSelectedWu())
            IconButton(
              icon: const Icon(Icons.pause),
              tooltip: 'Pause',
              onPressed: () async {
                gRpc.commandsTab(tab,txtTasksCommandSuspended,context); 
              },
            ), 
          if (tab==cTabTasks)
            if (gRpc.isSelectedWu())          
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Resume',
              onPressed: () async {
                gRpc.commandsTab(tab,txtTasksCommandResume,context); 
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
                  case txtComputersAllow:
                    setTab(cTabAllow);
                    _updateNow = true;
                    showDialog(
                      context: context,
                      builder: (myApp) {                      
                        return AllowComputer(onConfirm: (String ret) { 
                          setTab(cTabComputers);
                          _updateNow = true;
                        });
                      }
                  );
                  case txtProjectCommandAdd:
                    var pc = AddProject();
                    pc.start(context);
                    return;
                  default:
                    gRpc.commandsTab(getTab(),command,context);                  
                }
            },
          ),

          // select tab
          PopupMenuButton<String>(
            icon: const Icon(Icons.list),
            onSelected: (String value) {
              setState(() {
                if (value == "adjust")
                {
                  gbHeaderResize = !gbHeaderResize;                  
                }
                else
                {
                  if (value == "graph")
                  {
                    setTab(cTabGraph);
                  }
                  else
                  {
                    setTab(value);
                  }
                }
                _updateNow = true;                
              });
            },
            itemBuilder: (BuildContext context) => [
              CheckedPopupMenuItem(
                checked: (tab==cTabComputers),
                value: cTabComputers,
                child: const Text('Computer'),
              ),
              CheckedPopupMenuItem(
                checked: (tab==cTabProjects),              
                value: cTabProjects,
                child: const Text('Project'),
              ),
              CheckedPopupMenuItem(
                checked: (tab==cTabTasks),                     
                value: cTabTasks,
                child: const Text('Tasks'),
              ),                
              CheckedPopupMenuItem(
                checked: (tab==cTabTransfers),           
                value: cTabTransfers,
                child: const Text('Transfers'),
              ), 
              CheckedPopupMenuItem(
                checked: (tab==cTabMessages),                  
                value: cTabMessages,
                child: const Text('Messages'),
              ),
              CheckedPopupMenuItem(
                checked: false,
                value: 'graph',
                child: const Text('Show graph'),
              ),               
              CheckedPopupMenuItem(
                checked: gbHeaderResize,
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
              PopupMenuItem(
                value: '6',
                child: Text('About $version'), 
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: '7',
                child: Text(txtComputersReboot), 
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
                  var about = BtAbout();
                  about.openDialog(version,context);                
                }
                if (value == '7')
                {                  
                  gbComputerReboot = true;
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
                            Column(children: gRows.asMap().map((k, v) {
                              var children = [
                                        InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_1'],v,context);
                                          },
                                          child:
                                            Container(color:v['color'], width:gHeader["col_1_w"], padding:const EdgeInsets.only(left:columnSideMarginsFirst, right:columnSideMargins, bottom:columnBottomMargins),
                                              child:Align(alignment:Alignment.centerLeft,
                                              child:Text(v['col_1'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                              style:TextStyle(color:v['colorText'])) ) )
                                        ),
                                        InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_2'],v,context);                                          
                                          },
                                          child:
                                            Container(color:v['color'], width:gHeader["col_2_w"], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins),
                                              child:Align(alignment:Alignment.centerLeft, child:Text(v['col_2'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                                  style:TextStyle(color:v['colorText'])) ) )
                                        ),                                        
                                        if (gHeader.containsKey('col_3')) InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_3'],v,context);  
                                          },
                                          child:
                                            Container(color:v['color'], width:gHeader["col_3_w"], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins),
                                              child:Align(alignment:Alignment.centerLeft, child:Text(v['col_3'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                                style:TextStyle(color:v['colorText'])) ) )
                                        ),                                    
                                        
                                        if (gHeader.containsKey('col_4')) InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_4'],v,context);  
                                          },
                                          child:
                                            Container(color:v['color'], width:gHeader["col_4_w"], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins), 
                                              child:Align(alignment:Alignment.centerLeft, child:Text(v['col_4'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                                  style:TextStyle(color:v['colorText'])) ) )
                                        ),
                                        if (gHeader.containsKey('col_5')) InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_5'],v,context);  
                                          },
                                          child:
                                            Container(color:v['color'], width:gHeader["col_5_w"], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins),
                                              child:Align(alignment:Alignment.centerLeft, child:Text(v['col_5'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                              style:TextStyle(color:v['colorText'])) ) )
                                        ),  
                                        if (gHeader.containsKey('col_6')) InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_6'],v,context);  
                                          },
                                          child:
                                            Container(color:v['color'], width:gHeader["col_6_w"], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins),
                                              child:Align(alignment:Alignment.centerLeft, child:Text(v['col_6'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                              style:TextStyle(color:v['colorText'])) ) )
                                        ),                                                                                                                                                 
                                        if (gHeader.containsKey('col_7')) InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_7'],v,context);  
                                          },
                                          child:
                                            Container(color:v['color'], width:gHeader["col_7_w"], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins),
                                              child:Align(alignment:Alignment.centerLeft, child:Text(v['col_7'].toString(),overflow:TextOverflow.visible, maxLines: 2,
                                              style:TextStyle(color:v['colorText'])) ) )
                                        ),
                                        if (gHeader.containsKey('col_8')) InkWell(
                                          onTap: (){
                                            tapped(v['type'],v['col_8'],v,context);  
                                          },
                                          child:
                                            Container(color:v['colorStatus'], width:gHeader["col_8_w"], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins), 
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
            color:gSystemColor.headerColor,
            height:headerHeight,
            margin:const EdgeInsets.only(top:pageHeaderHeight),
            child: SingleChildScrollView(
              controller: _headerController,
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection:Axis.horizontal,
              child:Row(children:[
                  if (gHeader.containsKey('col_1')) gestureColumn('col_1_w', 'col_1'),
                  if (gHeader.containsKey('col_2')) gestureColumn('col_2_w', 'col_2'),
                  if (gHeader.containsKey('col_3')) gestureColumn('col_3_w', 'col_3'),
                  if (gHeader.containsKey('col_4')) gestureColumn('col_4_w', 'col_4'),
                  if (gHeader.containsKey('col_5')) gestureColumn('col_5_w', 'col_5'),
                  if (gHeader.containsKey('col_6')) gestureColumn('col_6_w', 'col_6'),
                  if (gHeader.containsKey('col_7')) gestureColumn('col_7_w', 'col_7'),
                  if (gHeader.containsKey('col_8')) gestureColumn('col_8_w', 'col_8'),
                  if (gHeader.containsKey('col_9')) gestureColumn('col_9_w', 'col_9'),
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
        if (item == computer)
        {
          gRpc.collapseComputer(computer);
        }
        else
        {
          gRpc.selectedWu(computer,v['col_3'],v['col_4']);
        }
        _updateNow = true;
      case cTypeResultCollapsed:
        gRpc.collapseComputer(computer);
        _updateNow = true; 
      case cTypeProject:
        gRpc.selectedProject(computer,v['col_2']);
        _updateNow = true;        
      case cTypeTransfer:
        gRpc.selectedTransfer(computer,v['col_2'],v['col_3']);
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
          if (item == computer) // collapse a computer and the filter
          {
            gRpc.collapseComputer(computer);
            _updateNow = true;    
          }
          else 
          {
            gRpc.selectedWu(computer,v['col_3'],v['col_4']);
          }
          _updateNow = true;          
        }
    }
    
  }

  tappedHeader(header, bLong)
  {
    gSortHeader.setSort(mCurrentTabActual, header, bLong);
    _updateNow = true;
  }

  headerWidthChanged(tab, columnText, columnWidth, newWidth)
  {
    gRpc.updateHeader(tab, columnText, columnWidth, newWidth);
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
//          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        }        
        return AddComputersDialog(computer, onConfirm: (String ret) {         
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