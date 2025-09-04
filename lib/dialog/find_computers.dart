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

import 'package:boinctasks/constants.dart';
import 'package:boinctasks/tabs/computer/find_computers_isolate.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:boinctasks/tabs/computer/computers.dart';
import 'package:is_valid/is_valid.dart';
import 'package:flutter/material.dart';

class FindComputersDialog extends StatefulWidget {
  final dynamic dlgTitle;
  final dynamic dlgIp;
  const FindComputersDialog(this.dlgTitle, this.dlgIp, {super.key, required this.onConfirm});

  @override
  State<StatefulWidget> createState() {
    return FindComputersDialogState();
  }

  final Function(String) onConfirm;
}

class FindComputersDialogState extends State<FindComputersDialog> {
  TextEditingController mComputerIp = TextEditingController();
  TextEditingController mComputerPort = TextEditingController();  
  String mIp = "";
  String? mErrorIpText = txtComputerScanInValidIpLocal;
  String? mErrorPortText;
  bool mbShowText = true;

  void validateIp(String ip)
  {
    if (IsValid.validateIP4Address(ip))
    {
			mErrorIpText = null;      
      /*
		  if (isValidLocalIp(ip))
		  {
			  mErrorIpText = null;
      }
      else
      {
			  mErrorIpText = txtComputerScanInValidIpLocal;
      }
      */
    }
    else
    {
      mErrorIpText = txtComputerScanInValidIp;
    }
  }

  void validatePort(String port)
  {
    try{
      var iPort = int.parse(port);
      if (IsValid.validateNumericRange(value: iPort, min: 1, max: 65535))
      {    
        mErrorPortText = null;
      }
      else
      {
        mErrorPortText = txtComputerScanInValidPort;
      }
    } catch (error,s) {
      gLogging.addToLoggingError('findComputerDialog (validatePort) $error,$s'); 
      mErrorPortText = txtComputerScanInValidPort;      
    }    
  }
  
  @override
  void initState() {  
    mComputerIp.text = widget.dlgIp;
    mbShowText = mComputerIp.text.isEmpty;
    validateIp(mComputerIp.text);
    mComputerPort.text = "";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SimpleDialog     
    (
      insetPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.fromLTRB(10, 12.0, 10, 16.0),
        children: <Widget>[          
          TextFormField(
            decoration: InputDecoration(
              labelText: "IP",
              errorText: mErrorIpText,
            ),
            onChanged: (ip)
            { 
              validateIp(ip);
              setState(() {});              
            },
            controller: mComputerIp,
          ),                    
          TextFormField(
            decoration: InputDecoration(
              labelText: "Port",
              errorText: mErrorPortText,
            ),
            onChanged: (port)
            { 
              validatePort(port);
              setState(() {});              
            },
            controller: mComputerPort,
          ),  
          if (mbShowText)
		        Text(txtComputerScanDialogNoIp),	 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
              onPressed: () { // Cancel
                widget.onConfirm("");
                Navigator.of(context).pop(); // close dialog
              },
              child: Text(txtButtonCancel),
              ),
              ElevatedButton(
                onPressed: () { // OK 
                  if (mErrorIpText == null)
                  {
                    if (mErrorPortText == null)
                    {                 
                      var ret = {cComputerIp: mComputerIp.text, cComputerPort: mComputerPort.text};
                      var json = jsonEncode(ret);
                      widget.onConfirm(json);
                      // Handle the selected item here           
                      Navigator.of(context).pop(); // close dialog
                    }
                  }
                },
                child: Text(txtButtonFind),
              ),           
            ]
          )
        ],
      );    
  }
}

Future<void> findComputerDialog(String ip, context)
async {
  try{
    await showDialog(
      context: context,
      builder: (myApp) {   
        return FindComputersDialog(txtComputersFindTitle, ip, onConfirm: (ret) async {           
          if (ret == "")
          {
            return;
          }
          var json = jsonDecode(ret);
          var ip = json[cComputerIp];
          var port = json[cComputerPort];          

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(txtComputersScanStart,
              style: TextStyle(fontSize: 20),
            ),            
            duration: const Duration(seconds: 30),
            padding: EdgeInsets.all(40)
          ));

          // OK on find computers
          var list = await mainFindComputers(ip,port);
          foundComputerDialog(list,context);
        },);
      }
    );
  } catch (error,s) {
    gLogging.addToLoggingError('findComputerDialog $error,$s'); 
  }       
}

Future<void> foundComputerDialog(dynamic list, context)
async {
  try{
    var listRemoved = [];
    var len = list.length;
    for (var i=0;i<len;i++)
    {
        var item = list[i];
        var ip = item[cComputerIp];
        var port = (item[cComputerPort]);

        var clen = gComputerList.length;
        for (var c=0;c<clen;c++)
        {          
          if (ip == gComputerList[c][cComputerIp])
          {
            if (gComputerList[c][cComputerPort] == "" && port == "31416") // blank is the same
            {
              port = "";
            }

            if (port == gComputerList[c][cComputerPort] )
            {
              listRemoved.add(item);
              list.removeAt(i);
              len = list.length;              
              i=0;
            }
          }
        }
    }

    await showDialog(
      context: context,
      builder: (myApp) {   
        return FoundComputerDialog2(txtComputersFoundTitle, list, listRemoved, onConfirm: (toAdd) async {         
          var len = toAdd.length;
          if (len > 0)
          {
            for (var i=0;i<len;i++)
            {
              var ip = toAdd[i]['ip'];
              var port = toAdd[i]['port'];
              gComputerList.add({cComputerEnabled:"1",cComputerGroup: "", cComputerName: ip, cComputerIp:ip, cComputerPort:port, cComputerPassword:"", cComputerStatus:"", cComputerConnected: "??", cComputerBoinc: "", cComputerPlatform: ""} ); 
            }
            writeComputerList();
          }          
        },);
      }
    );
  } catch (error,s) {
    gLogging.addToLoggingError('foundComputerDialog $error,$s'); 
  }     
  }



class OkDialog extends StatefulWidget {
  final dynamic dlgTitle;
  final dynamic dlgTxt;
  const OkDialog(this.dlgTitle, this.dlgTxt, {super.key, required this.onConfirm});

  @override
  State<StatefulWidget> createState() {
    return OkDialogState();
  }

  final Function(bool value) onConfirm;
}

class OkDialogState extends State<OkDialog> {
  final TextEditingController mText = TextEditingController();
  String mIp = "";
  String? mErrorText;

  @override
  void initState() {  

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dlgTitle),
      scrollable: true,
      actions: [
        ElevatedButton(
          onPressed: () { // Continue
              widget.onConfirm(true);
              // Handle the selected item here           
              Navigator.of(context).pop(); // close dialog
          },
          child: Text(txtButtonContinue),
        ),
      ],
      content: Column(
        children: <Widget>[         
          DecoratedBox(
            decoration: BoxDecoration(color: gSystemColor.viewBackgroundColor),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(widget.dlgTxt),
            ),
          ),
        ],
      ),
    );
  }
}

// Find Computers returns here with the list of computers found 
class FoundComputerDialog2 extends StatefulWidget {
  final dynamic dlgTitle;
  final dynamic dlgList;
  final dynamic dlgListRemoved;  
  const FoundComputerDialog2(this.dlgTitle, this.dlgList, this.dlgListRemoved, {super.key, required this.onConfirm});

  @override
  State<StatefulWidget> createState() {
    return FoundComputerDialogState();
  }

  final Function(List) onConfirm;
}

class FoundComputerDialogState extends State<FoundComputerDialog2> {
  // TextEditingController mText = TextEditingController();
  var mTxt = "";
  var mButtonText = txtButtonOK;

  var mlistToAdd = [];

  @override
  void initState() {  
    try{
      mTxt = "";
      mlistToAdd = widget.dlgList;
      var len = mlistToAdd.length;
      if (len <= 0)
      {
        mTxt = txtComputersScanNothing;
      }
      else
      {
        mTxt = txtComputersScanToAdd;
        mButtonText = txtButtonAdd;      
        for (var i=0;i<len;i++)
        {
          var item = mlistToAdd[i];
          var ip = item[cComputerIp];
          var port = item[cComputerPort];
          mTxt += "IP: $ip, port: $port\n";      
        } 
        var listRemoved = widget.dlgListRemoved;
        var lenRemoved = listRemoved.length;
        if (lenRemoved > 0)
        {
          mTxt += txtComputersScanRemoved;
        }
        for (var ir=0;ir<lenRemoved;ir++)
        {
          var item = listRemoved[ir];
          var ip = item[cComputerIp];
          var port = item[cComputerPort];
          mTxt += "IP: $ip, port: $port\n";      
        }

        if ((len <= 0) && (lenRemoved <= 0))
        {
          mTxt = txtComputersScanToAdd;
        }
      }

    }catch(error,s) {
        gLogging.addToLoggingError('FoundComputerDialogState (initState) $error,$s'); 
    }

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dlgTitle),
      scrollable: true,
      actions: [
        ElevatedButton(
          onPressed: () { // Cancel
            mlistToAdd = [];
            widget.onConfirm(mlistToAdd);
            Navigator.of(context).pop(); // close dialog
          },
          child: Text(txtButtonCancel),
        ),        
        ElevatedButton(
          onPressed: () { // Continue
              widget.onConfirm(mlistToAdd);
              // Handle the selected item here           
              Navigator.of(context).pop(); // close dialog
          },
          child: Text(mButtonText),
        ),
      ],
      content: Column(
        children: <Widget>[         
          DecoratedBox(
            decoration: BoxDecoration(color: gSystemColor.viewBackgroundColor),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(mTxt),
            ),
          ),
        ],
      ),
    );
  }
}