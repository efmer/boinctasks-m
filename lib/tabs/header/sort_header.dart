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

import 'dart:convert';
import 'dart:io';

import 'package:boinctasks/constants.dart';
import 'package:boinctasks/functions.dart';
import 'package:boinctasks/main.dart';

Future<File> get _localFileSort async {
  final path = await gLocalPath;
return File('$path/$cFileNameSort');
}

Future<void> readSortFile() async {
  try {
    final file = await _localFileSort;

    // Read the file
    final contents = await file.readAsString();
    gSortHeader.mSort = jsonDecode(contents);
    return;
//    return contents.toString();
  } catch (error) {
      gLogging.addToDebugLogging('Warning: No valid sort file found');
    return;
  }
}

Future<File> writeSortFile(String sort) async {
  final file = await _localFileSort;
  // Write the file
  return file.writeAsString(sort);
}

var gSortHeader = SortHeader();

class SortHeader
{
  var mSort = [];
 
  void init()
  {
  try
    {  
      mSort.add(["","","",true,true,true]);
      mSort.add(["","","",true,true,true]);      
      mSort.add(["","","",true,true,true]);
      mSort.add(["","","",true,true,true]);
      mSort.add(["","","",true,true,true]);
      mSort.add(["","","",true,true,true]);
      mSort.add(["","","",true,true,true]);

      readSortFile();

    } catch (error,s) {
      gLogging.addToLoggingError('SortHeader (init) $error,$s'); 
    } 
  }

  dynamic sort(String tab, res)
  {
    try
    {
    var index = 0;

    var sortHeaderShort = "";
    var sortHeaderLong = "";    
    switch(tab)
    {
      case cTabComputers:
        index = cSortHeaderComputer;
      case cTabProjects:
        index = cSortHeaderProjects;      
      case cTabTasks:
        index = cSortHeaderTasks; 
      case cTabTransfers:
        index = cSortHeaderTransfers;
      case cTabMessages:
        index = cSortHeaderMessages;
      default: return res;
    }

    var item = mSort[index];

    var short = item[cSortHeaderShort];
    var long = item[cSortHeaderLong];

    sortHeaderShort = removeArrow(short);
    sortHeaderLong = removeArrow(long); 

    if (sortHeaderShort == "" && sortHeaderLong == "")
    {
      return res;
    }
    res = sortOne(res, sortHeaderShort, item[cSortHeaderShortDir], false);
    res = sortOne(res, sortHeaderLong, item[cSortHeaderLongDir], true);
    res = addWuInFilter(res);
    
    res = addColorlighten(res);


//    res[1]=list;

    } catch (error,s) {
      gLogging.addToLoggingError('SortHeader (sort) $error,$s'); 
    } 
    return res;    
  }

List sortOne(dynamic res, sortOn, bSortOn, bLong)
{
  try
  { 
    var header = res[0];
    var sortKey = "";
    bool bisNumber = false;
    var len = header.length;
    for (var i=0;i<len;i++)
    {
      var value = header.values.elementAt(i);
      if (value == sortOn)
      {
        sortKey = header.keys.elementAt(i);
        var numKey = "${sortKey}_n";
        bisNumber = header[numKey];
        if (bLong)
        {
          if (bSortOn)
          {
            header[sortKey] = cArrowUpLong + value;
          } else
          {
            header[sortKey] = cArrowDownLong + value;
          }
        }
        else
        {
          if (bSortOn)
          {
            header[sortKey] = cArrowUpShort + value;
          } else
          {
            header[sortKey] = cArrowDownShort + value;
          }
        }       
        break;
      }      
    }

    res[0] = header;

    if (sortKey == "") 
    {
      return res;
    }

    var list = res[1];
    var bdone = false;
    while (!bdone)
    {
      bdone = true;

      for (var s = 0; s < list.length-1; s++)
      {
        var i1 = list[s][sortKey];
        var i2 = list[s+1][sortKey];
        if (bisNumber) // number compare
        {
          var v1 =  double.tryParse(i1);
          var v2 =  double.tryParse(i2);
          v1 ??= 0; // if == null v1 = 0
          v2 ??= 0;

          var bdir = false;
          if (bSortOn)
          {
            bdir = v1>v2;
          }
          else
          {
            bdir = v1<v2;
          }

          if (bdir) // swap
          {        
            var temp = list[s];
            list[s] = list[s+1];
            list[s+1] = temp;
            bdone = false;
          }

        }
        else { // string compare 
          var v1 = i1;
          var v2 = i2;
          var dir = 0;
          if (bSortOn)
          {
            dir = v1.compareTo(v2);
          }
          else
          {
            dir = v2.compareTo(v1);
          }
          if (dir > 0) // swap
          {        
            var temp = list[s];
            list[s] = list[s+1];
            list[s+1] = temp;
            bdone = false;
          }
        }
      }
    }
    

    } catch (error,s) {
      gLogging.addToLoggingError('RpSortHeader (sort) $error,$s'); 
    }     
    return res;
  }

  dynamic addWuInFilter(dynamic res)
  {
    try
    {
      var list = res[1];
      for (var s = 0; s < list.length; s++)
      {
        var type = list[s]['type'];
        if (type == cTypeFilterWuArr)
        {
          var filterWuArr = list[s]['filter'];          
          var lenFilter = filterWuArr.length;
          var fi=0;
          for (fi=0;fi<lenFilter;fi++)
          {
            var item = filterWuArr[fi];
            list.insert(s+1, item);          
          }
          break;
        }
      }    
    } catch (error,s) {
      gLogging.addToLoggingError('SortHeader (addWuInFilter) $error,$s'); 
    }  
    return res;
  }

  dynamic addColorlighten(dynamic res)
  {
    try
    {
      var bStatus = false;
      var list = res[1];
      var len =  list.length;
      if (len > 1)
      {
        var colorStatus = list[0]['colorStatus'];
        if (colorStatus != null)
        {
          bStatus = true;
        }
      }
      for (var s = 0; s < len; s+=2)
      {
        var color = list[s]['color'];
        color = lighten(color);
        list[s]['color'] = color;
        if (bStatus)
        {
          color = list[s]['colorStatus'];
          color = lighten(color);
          list[s]['colorStatus'] = color;          
        }
      }    
      for (var s = 1; s < len; s+=2)
      {
        var color = list[s]['color'];
        color = darken(color);
        list[s]['color'] = color;
        if (bStatus)
        {
          color = list[s]['colorStatus'];
          color = darken(color);
          list[s]['colorStatus'] = color;          
        }
      }          
    } catch (error,s) {
      gLogging.addToLoggingError('SortHeader (addColorlighten) $error,$s'); 
    }  
    return res;
  }

  void setSort(String tab,header, bLong)
  {
    try
    {
      if (header == null)
      {
        return;
      }
      header = removeArrow(header);
      var index = 0;
      switch(tab)
      {
        case cTabComputers:
          index = cSortHeaderComputer;
        case cTabProjects:
          index = cSortHeaderProjects;      
        case cTabTasks:
          index = cSortHeaderTasks; 
        case cTabTransfers:
          index = cSortHeaderTransfers;
        case cTabMessages:
          index = cSortHeaderMessages;
        default: return;
      }

      var item = mSort[index];

      if (bLong)
      {
        if (item[cSortHeaderLong] != header)
        {
          item[cSortHeaderLongDir] = false;
        }
        else
        {
          item[cSortHeaderLongDir] = !item[cSortHeaderLongDir];
        }
        item[cSortHeaderLong] = header;            
      }
      else
      {
        if (item[cSortHeaderShort] != header)
        {
          item[cSortHeaderShortDir]  = false;
        }
        else
        {
          item[cSortHeaderShortDir]= !item[cSortHeaderShortDir];
        }
        item[cSortHeaderShort]  = header;
      }         

      if (item[cSortHeaderShort]  == item[cSortHeaderLong] )
      {
        item[cSortHeaderLong] = ""; // remove long if both sorting names are equal
      }
      String json = jsonEncode(mSort);  
      writeSortFile(json);       
    } catch (error,s) {
      gLogging.addToLoggingError('SortHeader (setSort) $error,$s'); 
    }    
  }

  dynamic removeArrow(String txt)
  {
    if (txt.contains(cArrowUpShort))
    {
      txt = txt.replaceAll(cArrowUpShort, "");
    }
    if (txt.contains(cArrowDownShort))
    {    
      txt = txt.replaceAll(cArrowDownShort, "");
    }
    if (txt.contains(cArrowUpLong))
    {        
      txt = txt.replaceAll(cArrowUpLong, "");
    }
    if (txt.contains(cArrowDownLong))
    {         
      txt = txt.replaceAll(cArrowDownLong, "");
    }
    return txt;
  }
}
