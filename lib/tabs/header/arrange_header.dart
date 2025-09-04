import 'dart:convert';
import 'dart:io';
import 'package:boinctasks/constants.dart';
import 'package:boinctasks/functions.dart';
import 'package:boinctasks/main.dart';
import 'package:boinctasks/tabs/header/header.dart';
import 'package:flutter/material.dart';

Future<File> get _localFileArrange async {
  final path = await gLocalPath;
  return File('$path/$cFileNameArrange');
}

Future<File> writeArrange(String arrange) async {
  final file = await _localFileArrange;
  // Write the file
  return file.writeAsString(arrange);
}

Future<void> readArrangeFile() async {
  try {
    final file = await _localFileArrange;

    // Read the file
    final contents = await file.readAsString();
    gArrange.readArrange(contents);
  } catch (error) {
    gArrange.setSequentialList();
  }  
}


var gArrange = ArrangeHeader();

class ArrangeCard
{
  String text = "";
  bool bEnabled = true;
}

class ArrangeHeader
{
  List<int> _listTasksArrange = [];
  List<bool> _listTasksArrangeEnabled = [];  

  int getList(int i)
  {
    return _listTasksArrange[i];
  }

  List<int> getFullList()
  {
    return _listTasksArrange;
  }

  List<bool> getFullListEnable()
  {
    return _listTasksArrangeEnabled;
  }

  void setFullList(dynamic list)
  {
    _listTasksArrange = list;
  }

  void setSequentialList()
  {
      _listTasksArrange = List<int>.generate(20, (int index) => index);
      _listTasksArrangeEnabled = List.generate(20, (int index) => true);
  }

  void readArrange(dynamic contents)
  {
    try{
      var arrange = jsonDecode(contents);
      var len = arrange.length;

      for (var i=0;i<len;i++)
      {
        var item = arrange[i];
        if (item.containsKey(cArrangeTasks))
        {  
          var arrangeTasks = item[cArrangeTasks];
          setArrangeTasks(arrangeTasks); 
        }
        if (item.containsKey(cArrangeTasksEnabled))
        {
          setArrangeTasksEnable(item[cArrangeTasksEnabled]);
        }
      } 

      List orgList = headerTasksString(); 
      var lenOrg = orgList.length;
      len = _listTasksArrange.length;
      if (len != lenOrg)
      {
        setSequentialList();
        return;
      }
      len = _listTasksArrangeEnabled.length;
      if (len != lenOrg)
      {
        setSequentialList();
        return;
      }

    }catch(error,s)
    {
      gLogging.addToLoggingError('arrange_header (readArrange) $error,$s');  
      setSequentialList();
    }    
  }

  void setArrangeTasks(dynamic list)
  {
    try{
      List orgList = headerTasksString();
      List<int> listInt = list.cast<int>();
      _listTasksArrange = listInt;
    
      // check if list is valid

      var lenOrg = orgList.length;
      var lenArrange = _listTasksArrange.length;
      if (lenOrg != lenArrange)
      {
        setSequentialList();  // invalide
        return;
      }
      List<int> uniqueNumbers = removeDuplicates(_listTasksArrange);
      var lenUnique = uniqueNumbers.length;
      if (lenOrg != lenUnique)
      {
        setSequentialList();  // invalidate
        return;      
      }
    }catch(error,s)
    {
      gLogging.addToLoggingError('arrange_header (setArrangeTasks) $error,$s');  
      setSequentialList();
    }     
  }

  void setArrangeTasksEnable(dynamic list)
  {
    List orgList = headerTasksString();
    List<bool> listBool = list.cast<bool>();    
    _listTasksArrangeEnabled = listBool;
    var lenOrg = orgList.length;
    var lenArrange = _listTasksArrangeEnabled.length;
    if (lenOrg != lenArrange)
    {
      setSequentialList();  // invalide
      return;
    }
  }

  List<int> removeDuplicates(List<int> numbers)
  {
    Set<int> seen = {}; // To track unique numbers
    List<int> uniqueNumbers = []; // To store unique numbers
    for (int number in numbers) {
      if (!seen.contains(number)) {
        seen.add(number); // Add to seen
        uniqueNumbers.add(number); // Add to the unique list
      }
    }
    return uniqueNumbers;
  }

  List getArrangeTasksList()
  {
    List arrangedList= [];    
    try{
      List orgList = headerTasksString();
      var len = orgList.length;
      for (var o=0;o<len;o++)
      {
        var pos = _listTasksArrange[o];
        var str = orgList[pos];
        var bEnabled = _listTasksArrangeEnabled[pos];        
        var card = ArrangeCard();
        card.text = str;
        card.bEnabled = bEnabled;
        arrangedList.add(card);
      }
    }catch(error,s)
    {
      gLogging.addToLoggingError('arrange_header (getArrangeTasksList) $error,$s');  
      setSequentialList();      
    }  
    return arrangedList;     
  }

  dynamic getArrangeTaskHeader(dynamic item)
  {

    return item;
  }

  dynamic getKeyWidth(dynamic id)
  {  
    try{
      var key = getKey(id);
      return "${key}_w";
    }catch(error,s)
    {
      gLogging.addToLoggingError('arrange_header (getKeyWidth) $error,$s');  
      return id;
    } 
  }

  dynamic getKey(dynamic id)
  {  
    try{    
    var split = id.split('_');
    var nr = int.parse(split[1])-1;
    var rnr = _listTasksArrange[nr]+1;
    var key = "col_$rnr";
    return key;
    }catch(error,s)
    {
      gLogging.addToLoggingError('arrange_header (getKey) $error,$s');  
      return id;
    } 
  }

  dynamic getKeyReverse(dynamic id)
  {  
    try{    
      var split = id.split('_');
      var nr = int.parse(split[1])-1;
      var rnr = _listTasksArrange.indexOf(nr)+1;
      var key = "col_$rnr";
      return key;
    }catch(error,s)
    {
      gLogging.addToLoggingError('arrange_header (getKeyReverse) $error,$s');  
      return id;
    } 
  }
}

class ReorderHeader extends StatefulWidget {
  const ReorderHeader({super.key});

  @override
  ReorderableListState createState() => ReorderableListState();
}

class ReorderableListState extends State<ReorderHeader> {
  List items = gArrange.getArrangeTasksList();

  void arrangeToNr()
  {
    try{
      gArrange._listTasksArrange = [];
      var len = items.length;
      var orgList = headerTasksString();
      for (var i=0;i<len;i++)
      {
        var item = items[i].text;
        for (var o=0;o<len;o++)
        {
          if (item == orgList[o])
          {
            gArrange._listTasksArrange.add(o);
            continue;
          }
        }
      }
    }catch(error,s)
    {
      gLogging.addToLoggingError('arrange_header (arrange) $error,$s');  
      gArrange.setSequentialList();
    }    
  }

  void arrangeEnabled()
  {
    try{
      gArrange._listTasksArrangeEnabled = [];      
      var orgList = headerTasksString();
      var len =  orgList.length;
      for (var o=0;o<len;o++)
      {
        var item = orgList[o];
        for (var i=0;i<len;i++)
        {
          if (item == items[i].text)
          {
            gArrange._listTasksArrangeEnabled.add(items[i].bEnabled);
            continue;
          }
        }
      }
    }catch(error,s)
    {
      gLogging.addToLoggingError('arrange_header (arrangeEnabled) $error,$s');
    }      
  }

  Color getColorTile(int index)
  {
    Color color;
    if (items[index].bEnabled)
    {
      if (index.isOdd)
      {
        color = darken(gSystemColor.rowHeaderColor);
      }
      else
      {
        color = lighten(gSystemColor.rowHeaderColor);
      }
    }
    else
    {
      color = const Color.fromARGB(255, 125, 125, 125);
      if (index.isOdd)
      {
        color = darken(color);
      }
      else
      {
        color = lighten(color);
      }      
    }

    return color;
  }


  @override
  Widget build(BuildContext context) {
    var padding = MediaQuery.sizeOf(context).width/4;
    if (padding <200)
    {
      padding = 0;
    }
    return Scaffold(
      appBar: AppBar(      
        title: Text('Header arrange'),
        backgroundColor: gSystemColor.pageHeaderColor,            
          leading: GestureDetector(
            onTap: () {
              arrangeToNr();    // list of strings nog in int (_listTasksArrange)
              arrangeEnabled();
              var arrangeList = [];
              arrangeList.add ({cArrangeTasks: gArrange._listTasksArrange});
              arrangeList.add ({cArrangeTasksEnabled: gArrange._listTasksArrangeEnabled});
              String json = jsonEncode(arrangeList);
              writeArrange(json);
              Navigator.pop(context, true);              
             },
           child: Icon(
            Icons.chevron_left_sharp,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(        
        backgroundColor: gSystemColor.rowHeaderColor,
        tooltip: 'Reset to default',
        onPressed: (){
          gArrange.setSequentialList();
          items = gArrange.getArrangeTasksList();
          setState(() {              
          });            
        },
        child: Text("Reset"),
      ),
      body:
       ReorderableListView(
        padding: EdgeInsets.only(left: padding, right: padding),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = items.removeAt(oldIndex);
            items.insert(newIndex, item);
          });
        },
        children: List.generate(          
          items.length,
          (index) => CheckboxListTile(
            key: Key('$index'),
            value: items[index].bEnabled,
            onChanged: (bool? value) {
              items[index].bEnabled = value;
              setState(() {
              });
            },
            title: Text(items[index].text,style:TextStyle(color:gSystemColor.headerFontColor)),
            tileColor: getColorTile(index)
          ),
          
        ),        
      ),                       
    );
  }
}