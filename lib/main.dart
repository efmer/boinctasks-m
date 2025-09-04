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

import 'dart:io';
import 'package:boinctasks/dialog/color/color.dart';
import 'package:boinctasks/dialog/about.dart';
import 'package:boinctasks/dialog/color/dlg_color.dart';
import 'package:boinctasks/dialog/find_computers.dart';
import 'package:boinctasks/dialog/logging.dart';
import 'package:boinctasks/dialog/set_tabs.dart';
import 'package:boinctasks/dialog/settings.dart';
import 'package:boinctasks/dialog/settings_boinc.dart';
import 'package:boinctasks/get_ip.dart';
import 'package:boinctasks/tabs/computer/allow_computer.dart';
import 'package:boinctasks/tabs/graph/graphs.dart';
import 'package:boinctasks/tabs/graph/show_graph.dart';
import 'package:boinctasks/tabs/header/arrange_header.dart';
import 'package:boinctasks/tabs/header/header.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/connections/connection_check/rpccheck_connection.dart';
import 'package:boinctasks/tabs/project/add_project.dart';
import 'package:boinctasks/tabs/header/sort_header.dart';
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
var gsetTab = []; // List
var gcolorsContents = ""; // String
var gbsettingReadWait = 0;
var gbsettingRead = false;
var gbsetTabRead = false;
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
//bool gbDebug = false;

var gdeadline = cSetTabDeadlineNever;
var gOneLine = 2;

Future<void> loadData() async {
  gHeader = {
    'col_1'   : "Status",
    'col_1_w' : 300.0, 
    'col_1_n' :false,
    'col_1_s' :false,                
  };
  gRows = [];
  gRows.add({
    'color'   : Colors.blue,
    'row'     : 1,
    'col_1'   :'Initializing, this may take a while',
    'col_1_s' : false,
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

void setTheme(bool bDark)
{
  gSystemColor.setTheme(bDark);
}

ThemeData getTheme()
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

List <String> getConnectedComputers([bool bSort=false])
{
  List <String> lconnected = [];    
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
    if (bSort)
    {
      lconnected.sort((a, b) => a.compareTo(b));
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
  readArrangeFile();
  readSetTabFile();
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
  getsetTab();
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
      gRpc.abort();           // close all sockets because we get unhandled socket errors.    
      mRpcCheck.abort();
      gLogging.addToDebugLogging('Main (lifecycle paused) paused');
      // went to Background
    }
    if (state == AppLifecycleState.resumed) {
      gbForceRefresh = true;
      mAppSleep = false;
      mConnectionTimer = Timer(Duration(seconds: gReconnectTimeout), checkConnection);
      gLogging.addToDebugLogging('Main (lifecycle resumed) resumed');
      // came back to Foreground
    }
  }

  var gbComputerReboot = false;

  void restart()
  {
    gbHeaderResize = false;
    gHeaderInfo.init();
    gSortHeader.init();

    var lenList = gComputerList.length;
    for (var i=0;i<lenList;i++)
    {
      gComputerList[i][cComputerConnected] = cComputerConnectedNot;
    }

    mRefreshRateActual = 0;   
    mCurrentTab = cTabTasks;
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

  void setTab(String tab)
  {
    mCurrentTab = tab;
//    mCurrentTabActual = tab;    
    mRefreshRateActual = 0;
  }
  String getTab()
  {
    return mCurrentTab;
  }
  
  String getTabActual()
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

  void gotResults(dynamic ret)
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

  void gotProjects(dynamic ret)
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

  void gotMessages(dynamic ret)
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

  void gotTransfers(dynamic ret)
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

  void gotGraphs(dynamic ret)
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

  void gotAllow(dynamic ret)
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
    if (mCurrentTabActual == cTabMessages)
    {
      var lComputers = getConnectedComputers();
      if (!lComputers.contains(gRpc.mMessageComputer))
      {
        gRpc.mMessageComputer = "";
        setTab(cTabComputers);  // Message selected but computer no longer connected
      }
    }
    checkConnection();
  }

  var iTest = 3;

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

/*
        if (iTest == 0)
        {
          iTest = -10;
          showDialog(
            context: context,
            builder: (myApp) {
              return const ReorderHeader();
            }
          );         
        }
        else
        {
          iTest--;
          if (iTest < -10)
          {
            iTest = -10;
          }
        }
*/
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

            gLogging.addToDebugLogging("Refresh rate: $grefreshRate");            
            gLogging.addToDebugLogging("Max busy: $gMaxBusySec");
            gLogging.addToDebugLogging("Socket timeout: $gSocketTimeout");
            gLogging.addToDebugLogging("Reconnect timeout: $gReconnectTimeout");  
            var list = gArrange.getFullList();       
            gLogging.addToDebugLogging("Header sequence: $list");
            var listb = gArrange.getFullListEnable();       
            gLogging.addToDebugLogging("Header enbabled: $listb");
            bInitial = false;            
          }
        }
        
        if (busy)
        {
          busyCnt--;
          if (busyCnt == 0)
          {
            gLogging.addToLogging("We seem to be stuck, try to reconnect by invalidating all sockets");
            mRpcCheck.abort();
            gRpc.forceNotBusy();         
          }
          if (busyCnt < -100)
          {
            gLogging.addToLogging("We seem to be stuck, rebooting");
            gbComputerReboot = true;      
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
GestureDetector gestureColumn(String columnWidth, columnText)
{
  double startHorizontal = 0;
  var widthHeader = gHeader[columnWidth].roundToDouble();

  var text = "";
  if (widthHeader != 0)
  {
    text = gHeader[columnText];
  }

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
    
    child: Container(width:widthHeader, padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins), child:Align(alignment:Alignment.centerLeft, child:Text(text, overflow:TextOverflow.visible, maxLines: 1, style:TextStyle(fontWeight:FontWeight.bold, color:gSystemColor.headerFontColor, fontSize:headerFontSize)) ) ),

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
      try{
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
      } catch(error,s) {
        gLogging.addToLoggingError('Main (onHorizontalDragUpdate) $error,$s'); 
      }
    },    
    onHorizontalDragEnd: (details)
    {
      try{            
        if (gbHeaderResize)
        {   
          var width = gHeader[columnWidth].roundToDouble();
          headerWidthChanged(gHeader[cHeaderTab],columnText,columnWidth,width);
          mHeaderResizing = false;            
        }
      } catch(error,s) {
        gLogging.addToLoggingError('Main (onHorizontalDragEnd) $error,$s'); 
        gbHeaderResize = false;
        mHeaderResizing = false;
      }      
    },
   
  );
}

void checkConnection()
  {
    mConnectionTimer.cancel();
    gDoConnectionCheck = true;
  }

  void setMenu()
  {
    try{
      switch (getTab())
      {
        case cTabComputers:
          var list = getConnectedComputers();
          var len = list.length;
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
          menuItems = [];        
          if (gRpc.isSelectedMessages())
          {
            menuItems.add(txtMessagesCopy);
          }

          var compList = getConnectedComputers(true);
          var len = compList.length;

          for (var i=0;i< len;i++)
          {
            menuItems.add(compList[i]);
          }
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
      case cTabTransfers:
        colorSelectTransfers= gSystemColor.tabSelectColor;        
      case cTabMessages:
        colorSelectMessages = gSystemColor.tabSelectColor;                
    }

    var title = "$gProgress $mTitle";

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
                  case txtMessagesCopy:
                    gRpc.copyToClipboard();
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
                if (value == "notices")
                {
                  Navigator.of(context).pushNamed('/notices');
                  return;
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
//              CheckedPopupMenuItem(
//                checked: false,
//                value: 'notices',
//                child: const Text('Notices'),
//              ),                
              CheckedPopupMenuItem(
                checked: false,
                value: 'graph',
                child: const Text('Show graph'),
              ),              
            ],
          ),

          // menu settings
          PopupMenuButton<String>(    
            icon: const Icon(Icons.settings),
            itemBuilder: (BuildContext context) => [
                PopupMenuItem( 
                  onTap: () {
                    showDialog(
                    context: context,
                    builder: (myApp) {
                      return const SettingsBoincDialog();
                    }
                  );              
                },                              
                child: Text('BOINC Settings'),
              ),  

              PopupMenuItem(
                  onTap: () {
                    showDialog(
                    context: context,
                    builder: (myApp) {
                      return const SettingsDialog();
                    }
                  );              
                },                              
                child: Text('BoincTasks Settings'),
              ), 

              PopupMenuItem(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (myApp) {
                      return const SetTabDialog();
                    }
                  );
                },                                 
                child: const Text('BoincTasks Tabs'),
              ),

            // header
              PopupMenuItem(
                child: PopupMenuButton( 
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.arrow_right)                        
                      ),
                      const Text(
                        'Header',
                      ),
                    ],
                  ),
                  
                  //child: Text('Header'),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    PopupMenuItem(
                      onTap: () {
                        gbHeaderResize = false;
                        Navigator.pop(context);                        
                        showDialog(
                          context: context,
                          builder: (myApp) {
                            return const ReorderHeader();
                          }
                        );                        
                      },
                      child: const Text('Task header sequence'),
                    ),
                    if (gbHeaderResize)
                    CheckedPopupMenuItem(
                      checked: gbHeaderResize,                    
                      onTap: () {                     
                          gbHeaderResize = !gbHeaderResize;
                          Navigator.pop(context);
                          return;                   
                      },
                      child: const Text('Adjust header width'),
                    ),
                    if (!gbHeaderResize)
                    PopupMenuItem(                      
                        onTap: () {
                          gbHeaderResize = !gbHeaderResize;
                          Navigator.pop(context);
                          return;                     
                        },
                        child: const Text('Adjust header width'),
                    ),
                  ],
                ),
              ),

              PopupMenuItem(
                onTap: () 
                {                
                  mBtColors.openDialog(context);
                },
                child: Text('Set color'),
              ),              
              PopupMenuItem(
                onTap: () 
                {                   
                  gLogging.openDialog(context);                
                },
                child: Text('Show logging'),
              ),
                
              PopupMenuItem(
                onTap: () 
                {
                  var about = BtAbout();
                  about.openDialog(version,context);                
                },
                child: Text('About $version'), 
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                onTap: () 
                {                  
                  gbComputerReboot = true;
                },
                child: Text(txtComputersReboot), 
              ),               
            ],
            onSelected: (String value) {
              setState(() {               
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
                                        drawColumn(v,'col_1'),
                                        drawColumn(v,'col_2'),
                                        drawColumn(v,'col_3'),
                                        drawColumn(v,'col_4'),
                                        drawColumn(v,'col_5'),
                                        drawColumn(v,'col_6'),
                                        drawColumn(v,'col_7'),
                                        drawColumn(v,'col_8'),
                                        drawColumn(v,'col_9'),
                                        drawColumn(v,'col_10'),
                                        drawColumn(v,'col_11'),
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
                  if (gHeader.containsKey('col_10')) gestureColumn('col_10_w', 'col_10'),
                  if (gHeader.containsKey('col_11')) gestureColumn('col_11_w', 'col_11'),                                                      
                ]
              )
            )
          ),
        ]
      )      
    )
    );   
  }

  Widget drawColumn(dynamic v,col)
  {
    if (gHeader.containsKey(col)) {
      var width = gHeader["${col}_w"];
      if (width == 0)
      {
        return Text("");  // removed
      }

      var colp = '${col}_p';          
      if (gHeader.containsKey(colp)) {  
        return drawColumnBar(v,col);
      }        

      var cols = '${col}_s';      
      return InkWell(
        onTap: (){
          tapped(v['type'],v[col],v,context);  
        },
        child:
          Container(color: gHeader[cols] ? v['colorStatus'] : v['color'] , width: width, padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins), 
            child:Align(alignment:Alignment.centerLeft, child:Text(v[col].toString(),overflow:TextOverflow.visible, maxLines: gOneLine,
            style:TextStyle(color:v['colorText']))) 
          )
      );
    }
      return Text("");
  }


  // Percentage
  Widget drawColumnBar(dynamic v,col)
  {
    try{
 //     if (gHeader.containsKey(col)) {
    
        var colw = "${col}_w";
        var cols = '${col}_s';
        var c = v[col];
        double lenbar = 0.0;
        if (c.isNotEmpty)
        {
          var dbl = double.parse(v[col]);
          var perc = dbl.round();
          var lenbarw = gHeader[colw] - 4; // -x = right side spacing
          lenbar = lenbarw/100 * perc;
        }

        return 
        Stack(
          children: [      
            InkWell(        
              onTap: (){
                tapped(v['type'],v[col],v,context); 
              },
              child:
                Container(color: gHeader[cols] ? v['colorStatus'] : v['color'] , width:gHeader[colw], padding:const EdgeInsets.only(left:columnSideMargins, right:columnSideMargins, bottom:columnBottomMargins), 
                  child:Align(alignment:Alignment.centerLeft, child:Text(v[col].toString(),overflow:TextOverflow.visible, maxLines: gOneLine,
                  style:TextStyle(color:v['colorText']))) 
                )
            ),
            InkWell( 
              onTap: (){
                tapped(v['type'],v[col],v,context);  
              },              
              child: Container(
                margin: EdgeInsets.fromLTRB(0,10,0,14),
                color:  const Color.fromARGB(113, 40, 168, 253), width: lenbar),
            ),
        ],   
        );
      //}
    }catch(error,s)
    {
      gLogging.addToLoggingError('main (drawColumnBar) $error,$s');        
    } 
    return Text("");    
  }

  void tapped(int type,item,v,context)
   {    
    try {
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
            var project = gArrange.getKeyReverse('col_3');
            var name = gArrange.getKeyReverse('col_4');
            gRpc.selectedWu(computer,v[project],v[name]);
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
        case cTypeMessage:
          gRpc.selectedMessages(computer,v['col_2']);
          _updateNow = true;             
        case cTypeFilter:       // when the filter is enabled
        case cTypeFilterWuArr:  // when the filter is disabled
          if (item.toLowerCase().contains(cTextFilter.toLowerCase()))
          {
            var app = v[gArrange.getKeyReverse('col_2')];
            var status = v[gArrange.getKeyReverse('col_8')];
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
              //gRpc.selectedWu(computer,v['col_3'],v['col_4']);
            }
            //_updateNow = true;          
          }
      }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('main (tapped) $error,$s'); 
    }    
  }

  void tappedHeader(dynamic header, bLong)
  {
    gSortHeader.setSort(mCurrentTabActual, header, bLong);
    _updateNow = true;
  }

  void headerWidthChanged(int tab, columnText, columnWidth, newWidth)
  {
    gRpc.updateHeader(tab, columnText, columnWidth, newWidth);
  }

  Future<void> computerTap(dynamic computer, dynamic context)
  async {
    await  computerDialog(computer, context);   
  }

  Future<void> addComputer()
  async {
    await computerDialog(cComputerNewName, context);   
  }
  
  
  Future<void> computerDialog(String computer, context)
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

Future okDialog(String title, text, context)
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