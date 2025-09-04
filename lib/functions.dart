import 'dart:convert';

import 'package:boinctasks/constants.dart';
import 'package:boinctasks/dialog/color/dlg_color.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xml2json/xml2json.dart';

String getFormattedTimeDiff(dynamic time, bNoNeg)
{
    var current = (DateTime.now().millisecondsSinceEpoch/1000).round();
    var diff = time - current;
    if (bNoNeg)
    {
      return "";
    }
    return getFormattedTimeInterval(diff);
}

String getFormattedTime(dynamic time)
{
  var timeFormat = DateFormat("HH:mm");
  var dt = DateTime.fromMillisecondsSinceEpoch(time * 1000);
  String timeF = timeFormat.format(dt); 
  return timeF;
}

String getFormattedTimeFull(dynamic time)
{
  var timeFormat = DateFormat("M/d/y HH:mm");
  var dt = DateTime.fromMillisecondsSinceEpoch(time * 1000);
  String timeF = timeFormat.format(dt); 
  return timeF;
}

String getFormattedTimeFullKey(dynamic item,key)
{
  String str = item[key]['\$t'];
  double strD = double.parse(str);
  int strI = strD.round(); 
  var strS = getFormattedTimeFull(strI);
  return strS;
}

String getFormattedTimeInterval(int sec)
{
  var neg = "";
  if (sec < 0)
  {
    neg = "-";
    sec = sec.abs();
  }
  format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
  var day = 0;
  while (sec > 86400)
  {
    day++;
    sec -= 86400;
  }
  var duration = Duration(seconds: sec);
  var time = format(duration);
  if (day > 0)
  {
    if (day < 10)
    {
      return "${neg}0${day}T$time";  
    }
    return "$neg${day}T$time";
  }
  else
  {
    return "$neg$time";
  }
}

String getFormattedTimeIntervalKey(dynamic item,key)
{
  String str = item[key]['\$t'];
  double strD = double.parse(str);
  int strI = strD.round(); 
  var strS = getFormattedTimeInterval(strI);
  return strS;
}

var darkenLighten = .1;
Color lighten(Color color) {
  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + darkenLighten).clamp(0.0, 1.0));

  return hslLight.toColor();
}

Color darken(Color color) {
  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness - darkenLighten).clamp(0.0, 1.0));

  return hslLight.toColor();
}

void setStripingFactor()
{
  if (gColorStriping == cColorStripingNone)
  {
    darkenLighten = 0;
  }
  else
  {
    if (gColorStriping == cColorStripingLow)
    {
      darkenLighten = .025;
    }
    else
    {
      if (gColorStriping == cColorStripingNormal)
      {
        darkenLighten = .05;
      } 
      else
      {
        if (gColorStriping == cColorStripingHigh)
        {
         darkenLighten = .1;
        }         
      }
    }
  }
}


dynamic xmlToJson(dynamic xmls,tagBegin,tagEnd)
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
  } catch (error) {
    return null;
  }    
}

dynamic extractXml(dynamic xmls,tagBegin,tagEnd)
{
    var id1 = xmls.indexOf(tagBegin);
    var id2 = xmls.indexOf(tagEnd);
    if (id1 < 0)
    {
      return "";
    }
    if (id2 < 0)
    {
      return "";
    }
//    id2 += tagEnd.length; 
    var xmlPart = xmls.substring(id1+tagBegin.length, id2);
    return xmlPart;
}

