import 'dart:io';
import 'dart:math';
import 'package:boinctasks/tabs/graph/graphs.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter/services.dart';

// https://onlyflutter.com/how-to-create-line-charts-in-flutter/
// https://github.com/imaNNeo/fl_chart/issues/438

String dropdownComputer = "";
String dropdownProject  = "";  
String dropdownCredits  = txtGraphAvgUser;

typedef OnWidgetSizeChange = void Function(Size size);

class ShowLineChart extends StatefulWidget {
  const ShowLineChart({super.key});
  @override
  State<ShowLineChart> createState() => ShowLineChartState();
}

class ShowLineChartState extends State<ShowLineChart> {
  var itemsComputers = [
      'dummy',
  ];
  var itemsProjects = [
      'dummy',
  ];  

  var itemsCredits = [
    txtGraphTotUser,
    txtGraphAvgUser,
    txtGraphTotHost,
    txtGraphAvgHost,
  ];

  @override
  void initState() {
    getDropDown("");
    super.initState();
  }

  void getDropDown(String currentComputer)
  {
    try{
      var len = gGraphData.length;
      itemsComputers = [];
      itemsProjects = [];
      dropdownProject = "";
      for (var i=0;i<len;i++)
      {
        var item = gGraphData[i];
        var computer = item[0];
        var project = item[1];
        if (i==0)
        {
          if (currentComputer == "")
          {
            dropdownComputer = computer;
          }
          else
          {
            dropdownComputer = currentComputer;
          }
        }      
        if (computer == dropdownComputer)
        {
          if (dropdownProject.isEmpty)
          {
            dropdownProject = project;
          }
          if (!itemsProjects.contains(project))
          {
            itemsProjects.add(project);
          }
        }
        if (!itemsComputers.contains(computer))
        {
          itemsComputers.add(computer);
        }
      }
    }catch(error,s)
    {
      gLogging.addToLoggingError('show_graph (ShowLineChartState) $error,$s');      
    }
  }  

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid){
    //  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky); // remove bar on Android
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
        SystemUiOverlay.top
      ]);      
    }
    GraphWidget test = GraphWidget();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(""),
        centerTitle: false,
        backgroundColor: gSystemColor.pageHeaderColor, 
        actions: [
          IconButton(
            iconSize: 30.0,
            icon: Icon(Icons.chevron_left_sharp),
              onPressed: () {
                Navigator.pop(context, true);
            },
          ),                  
          if (dropdownComputer.isNotEmpty)
          Expanded(
            child: 
              DropdownButton( // computer 
                isExpanded: true, 
                value: dropdownComputer,
                icon: const Icon(Icons.keyboard_arrow_down),
                items:
                  itemsComputers.map((String items) {                
                    return DropdownMenuItem(value: items,
                    child:                      
                      //Text(items));
                      Text(items, overflow: TextOverflow.ellipsis));
                  }).toList(),
                onChanged: (String? newValue) {
                  dropdownComputer = newValue!;
                  getDropDown(dropdownComputer);                  
                  setState(() {
                  });
                },
            ),
          ),
          if (itemsProjects.isNotEmpty)
          Expanded(       
            child:
              DropdownButton( // project
                isExpanded: true, 
                value: dropdownProject,
                // iconSize: 24,
                icon: const Icon(Icons.keyboard_arrow_down),
                items:
                  itemsProjects.map((String items) {
                    return DropdownMenuItem(value: items,
                      child:
                        //Text(items));
                        Text(items, overflow: TextOverflow.ellipsis));
                  }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownProject = newValue!;
                  });
                },
              ),
          ),
          if (dropdownCredits.isNotEmpty)   
          Expanded(
            child:
              DropdownButton( // Credits
                isExpanded: true, 
                value: dropdownCredits,
                icon: const Icon(Icons.keyboard_arrow_down),
                items:
                  itemsCredits.map((String items) {
                    return DropdownMenuItem(value: items,
                    child:
                      Text(items, overflow: TextOverflow.ellipsis));
                  }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownCredits = newValue!;
                  });
                },
              ),   
          )                        
        ],
      ),   
 
      body:
      Container(
        width:  double.infinity,  // does nothing?
        color:  gSystemColor.graphBackgroundColor, 
        child:
          AspectRatio(
          aspectRatio: 1.25,  // does nothing?
          child: Column(
            children: [
             // const Padding(
             //   padding: EdgeInsets.symmetric(vertical: 4),
             // ),
              Expanded( // fill available space
                child: Padding(                                     
                  padding: const EdgeInsets.only(right: 20, left: 10, bottom: 10),
                  child: test,
                ),
              ),
            ],
          ),
        ),        
      ),
    );  
  }
}

class GraphWidget extends ShowLineChart {

  const GraphWidget({super.key});
  @override
  State<GraphWidget> createState() => GraphWidgetState();
  
  //void changed() {
  //  GraphWidgetState.changed();
 // }
}

class GraphWidgetState extends State<GraphWidget> {
  intl.DateFormat mdFormat = intl.DateFormat('MMMd');
  double mMaxTime = 0;
  double mMinTime = 0;
  double mMidTime = 0;
  bool bMidTime = false;

  double mIntervalCredit = 1;
  double mMinCredit = 0;
  double mMaxCredit = 0;
  String mLastCredit = "";

  List <FlSpot> data = [];

  List<FlSpot> getData()
  {
    List <FlSpot> newData = [];
    try{
      var leng= gGraphData.length;

      for (var g=0;g<leng;g++)
      {
        var itemg = gGraphData[g];
        var computer = itemg[0];
        var project = itemg[1];
        if (project != dropdownProject || computer != dropdownComputer)
        {
          continue;
        }
        var sel = 0;
        if (dropdownCredits == txtGraphTotUser) sel = 1;
        if (dropdownCredits == txtGraphAvgUser) sel = 2;
        if (dropdownCredits == txtGraphTotHost) sel = 3;
        if (dropdownCredits == txtGraphAvgHost) sel = 4;        

        var graph = itemg[2];
        var len = graph.length;    
        if (len == 0)
        {
          var spot = FlSpot(0, 0);
          newData.add(spot);
          return newData;
        }

        for (var i=0;i<len;i++)
        {
          var item = graph[i];
          double hour = item[0];
          hour = hour.truncateToDouble();
          double credits = item[sel];
          credits = credits.truncateToDouble();
          var spot = FlSpot(hour, credits); // = in hours
          newData.add(spot);
        }
      }
    }catch(error,s)
    {
      gLogging.addToLoggingError('show_graph (getData) $error,$s');      
    }
    return newData;
  }

  void getInterval()
  {
    try {
      mLastCredit = "";
      double delta = mMaxCredit - mMinCredit;
      var length = delta.toString().length;    
      var intervalS = "1".padRight(length-3, '0');
      mIntervalCredit = double.parse(intervalS);
      var density = delta / mIntervalCredit;
      if (density > 25)
      {
        intervalS = "1".padRight(length-2, '0');
        mIntervalCredit = double.parse(intervalS);
      }  
      else
      {      
       // if (density > 15)
       // {
       //   intervalS = "5".padRight(length-2, '0');
       //   mIntervalCredit = double.parse(intervalS);
       // }  
      }
    }catch(error,s)
    {
      gLogging.addToLoggingError('show_graph (getInterval) $error,$s');      
    }    
  }

   @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = getData();   

    if (data.length <= 1)
    {
      showWarning("There is no data to display");      
    }

    mMaxTime = double.parse(data.map<double>((e) => (e.x)).reduce(max).toStringAsFixed(0));
    mMinTime = double.parse(data.map<double>((e) => e.x).reduce(min).toStringAsFixed(0));
    var delta = mMaxTime - mMinTime;
    mMidTime = mMinTime + delta/2;
    bMidTime = false;

    mMaxCredit = double.parse(data.map<double>((e) => (e.y)).reduce(max).toStringAsFixed(0));
    mMinCredit = double.parse(data.map<double>((e) => (e.y)).reduce(min).toStringAsFixed(0));

    getInterval();

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(   
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (touchedSpot) => Colors.black,
            getTooltipItems: (value) {
                return value
                .map((e) => LineTooltipItem(
                    "Credits: ${getCreditExp(e.y,false)} \n Time: ${getDate(e.x)}", TextStyle(fontWeight: FontWeight.bold, color: Colors.white,)))
                .toList();
            },
          ),
        ),

        maxY: mMaxCredit,
        minY: mMinCredit,
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },          
          horizontalInterval: mIntervalCredit,
          verticalInterval: 3600*24,          
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: const Color.fromARGB(255, 189, 186, 186), width: 2),
            left: BorderSide(color: const Color.fromARGB(255, 189, 186, 186), width: 2),
            right: const BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
            top: const BorderSide(color: Color.fromARGB(255, 255, 255, 255), width: 2),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: getBottomTitles(),
          topTitles: noTitlesWidget(),
          leftTitles: getLeftTitles(),
          rightTitles: noTitlesWidget(),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: false,
            color: Colors.cyan,
            barWidth: 2,
            isStrokeCapRound: false,
            dotData: const FlDotData(show: true),
            spots: data,
          ),
        ],
      ),
    );
  }

  AxisTitles getBottomTitles() {
    return AxisTitles(     
      sideTitles: SideTitles(     
        reservedSize: 40, // at the bottom
        interval: 3600/2,   // value in seconds, interval in hours
        showTitles: true,
        getTitlesWidget: (value, meta) {
          String text = '';
          if (value == 0)
          {
            return Text("No data");
          }

          if (value == mMinTime)
          {
            text = getDate(value);
            bMidTime = false;
          }
          else 
          {
            if (value == mMaxTime) {            
              text = getDate(value);
            }
            else
            {
              if (value > mMidTime)
              {
                if (!bMidTime)
                {
                  text = getDate(value);
                  bMidTime = true;
                }
              }
            }
          }
          if (text.isNotEmpty)
          {
            return Text(text);
          }
          return Text("");


        },
      ),
    );
  }

  AxisTitles getLeftTitles() {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,        
        interval: mIntervalCredit,
        getTitlesWidget: (value, meta) {
          if (value == mMaxCredit)
          {
            return Text("");
          }
          if (value == mMinCredit)
          {
            mLastCredit = "";
            return Text("");
          }          
          if (value == 0)
          {
            return Text("0");
          }
          var txt = getCreditExp(value,true);
          if (txt != mLastCredit)
          {
            mLastCredit = txt;
            return Text(txt);
          }
          return Text("");
        },
      ),
    );
  }

  String getCreditExp(dynamic value, bToInt)
  {
    var texte = "?";
    try{
      var exp = "";
      var giga = 1000000000;
      var mega = 1000000;
      var kilo = 1000;
      if (value >= giga)
      {
        value /= giga;
        exp = "G";
      }
      else
      {
        if (value >= mega)
        {
          value /= mega;
          exp = "M";
        }
        else
        {
          if (value >= kilo)
          {
            value /= kilo;
            exp = "k";
          }
        }
      }
      if (bToInt)
      {
        var valuer = value.round();
        var fraction = valuer - value;
        if (fraction.abs() > 0.15)
        {
          return "";  // int is way off do not display
        }
        var valueI = value.round();
        var text = valueI.toString();      
        texte = "$text$exp";
      }
      else
      {
        var text = value.toString();
        if (exp.isNotEmpty)
        {
          text = text.replaceAll('.',exp);
        }        
        texte = text; //"$text$exp";        
      }
    }catch(error,s)
    {
      gLogging.addToLoggingError('show_graph (getExp) $error,$s');      
    }    
    return texte;
  }

  String getDate(double seconds)
  {
    var epoch = seconds*1000;
    var str = mdFormat.format(DateTime.fromMillisecondsSinceEpoch(epoch.toInt()));
    return str;
  }

  AxisTitles noTitlesWidget() {
    return const AxisTitles(sideTitles: SideTitles());
  }

  void showWarning(String text){
   Fluttertoast.showToast(
     msg: text,
     toastLength: Toast.LENGTH_SHORT,
     gravity: ToastGravity.CENTER,
     timeInSecForIosWeb: 2,
     //backgroundColor: Colors.red,
     //textColor: Colors.white,
     fontSize: 16.0,
   );    
  }
  
}
