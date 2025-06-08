import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xml2json/xml2json.dart';

getFormattedTimeDiff(time, noNeg)
{
    var current = (DateTime.now().millisecondsSinceEpoch/1000).round();
    var diff = time - current;
    if (noNeg)
    {
          if (diff < 0) return "";
    }
    return getFormattedTimeInterval(diff);
}

String getFormattedTime(time)
{
  var timeFormat = DateFormat("HH:mm");
  var dt = DateTime.fromMillisecondsSinceEpoch(time * 1000);
  String timeF = timeFormat.format(dt); 
  return timeF;
}

String getFormattedTimeFull(time)
{
  var timeFormat = DateFormat("M/d/y HH:mm");
  var dt = DateTime.fromMillisecondsSinceEpoch(time * 1000);
  String timeF = timeFormat.format(dt); 
  return timeF;
}

String getFormattedTimeFullKey(item,key)
{
  String str = item[key]['\$t'];
  double strD = double.parse(str);
  int strI = strD.round(); 
  var strS = getFormattedTimeFull(strI);
  return strS;
}

String getFormattedTimeInterval(sec)
{
  var duration = Duration(seconds: sec);

  String negativeSign = duration.isNegative ? '-' : '';
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  int days = duration.inDays;
  var daysS = "";
  if (days > 0)
  {
    daysS = "d,$days";
  }
  
  return "$negativeSign${daysS+twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
}

String getFormattedTimeIntervalKey(item,key)
{
  String str = item[key]['\$t'];
  double strD = double.parse(str);
  int strI = strD.round(); 
  var strS = getFormattedTimeInterval(strI);
  return strS;
}

Color lighten(Color color, [double amount = .1]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

  return hslLight.toColor();
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
  } catch (error) {
    return null;
  }    
}

extractXml(xmls,tagBegin,tagEnd)
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

