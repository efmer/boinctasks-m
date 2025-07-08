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

import 'dart:io';

import 'package:boinctasks/constants.dart';
import 'package:boinctasks/functions.dart';
import 'package:boinctasks/tabs/misc/header.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:boinctasks/valid_ip.dart';
import 'package:flutter/material.dart';
import 'package:is_valid/is_valid.dart';
// ignore: depend_on_referenced_packages
import 'package:xml/xml.dart';

var gComputerList = [];
var gComputerListRead = false;

Future<File> get _localFileComputers async {
  final path = await gLocalPath;
  return File('$path/$cFileNameComputers');
}

Future<String> readComputersFile() async {
  try {
    final file = await _localFileComputers;

    // Read the file
    String contents = await file.readAsString();
    return contents;
//    return contents.toString();
  } catch (error) {
      gLogging.addToLoggingError('No valid computers.xml file found');
    return "";
  }
}

Future<File> writeComputers(String computers) async {
  final file = await _localFileComputers;
// Write the file
return file.writeAsString(computers);
}

writeComputerList()
{
  var len = gComputerList.length;
  var xml = "<computers>\n";
  for (var i=0;i<len;i++)
  {
    xml += "  <computer>\n";
    xml += "    <id_name>${gComputerList[i][cComputerName]}</id_name>\n";
    xml += "    <id_group>${gComputerList[i][cComputerGroup]}</id_group>\n";
    xml += "    <ip>${gComputerList[i][cComputerIp]}</ip>\n";
    xml += "    <checked>${gComputerList[i][cComputerEnabled]}</checked>\n";
    xml += "    <port>${gComputerList[i][cComputerPort]}</port>\n";
    xml += "    <password>${gComputerList[i][cComputerPassword]}</password>\n";
    xml += "  </computer>\n";      
  }
  xml += "</computers>\n";
  writeComputers(xml);
}

class Computers {
  var cInit = "Initializing....";
  var cStateUpdate = "State needs to update";

  updateHeader(columnText, columnWidth, newWidth,bWrite)
  {
    gHeaderInfo.mHeaderComputersWidth[columnWidth] = newWidth; 
    if (bWrite)
    {
      gHeaderInfo.writeComputers();      
    }
  }

  init()
  {
    readComputers();
  }

  readComputers()
  async {
    try {
      gComputerList = [];
      final contents = await readComputersFile();
      if (contents == "")
      {
        gComputerListRead = true;   
        // empty add dummy computer list
        // Enable should be "0" = false because there is no valid IP address.
        gComputerList.add({cComputerEnabled:"0",cComputerGroup: "", cComputerName: "Tap to setup", cComputerIp:"ip", cComputerPort:"", cComputerPassword:"", cComputerStatus:"", cComputerConnected: "??", cComputerBoinc: "", cComputerPlatform: ""} );
        return;
      }
      final document = XmlDocument.parse(contents);
      final computersNode = document.findElements('computers').first;
      final computers = computersNode.findElements('computer');

      for (final computer in computers) {
        final enabled = computer.findElements('checked').first.innerText;         
        final group = computer.findElements('id_group').first.innerText;        
        final name = computer.findElements('id_name').first.innerText;
        final ip = computer.findElements('ip').first.innerText;
        final port = computer.findElements('port').first.innerText;        
        final password = computer.findElements('password').first.innerText; 
        var status = "";
        if (enabled == "0") status = txtComputerStatusDisabled;   
        gComputerList.add({cComputerEnabled:enabled,cComputerGroup: group, cComputerName: name, cComputerIp:ip, cComputerPort:port, cComputerPassword:password, cComputerStatus:status, cComputerConnected: "??", cComputerBoinc: "", cComputerPlatform: ""} ); 
      }
      gComputerListRead = true;
    } catch (error,s) {
      gLogging.addToLoggingError('Computers (readComputers) $error,$s');
    }    
  }
  getTab()
  {
    return newData();
  }

  getHeaderComputers()
  {
    headerComputersMinMax();    
    var tableItem = {
      cHeaderTab:cTypeComputer,
      'col_1':"🗹",
      'col_1_w': gHeaderInfo.mHeaderComputersWidth['col_1_w'],   
      'col_1_n' :false,
      'col_2':txtComputerHeaderGroup,
      'col_2_w': gHeaderInfo.mHeaderComputersWidth['col_2_w'], 
      'col_2_n' :false,
      'col_3':txtComputerHeaderComputer,
      'col_3_w': gHeaderInfo.mHeaderComputersWidth['col_3_w'], 
      'col_3_n' :false,
      'col_4':txtComputerHeaderIp,
      'col_4_w': gHeaderInfo.mHeaderComputersWidth['col_4_w'], 
      'col_4_n' :false,
      'col_5':txtComputerHeaderPort,
      'col_5_w': gHeaderInfo.mHeaderComputersWidth['col_5_w'], 
      'col_5_n' :false,
      'col_6':txtComputerHeaderBoinc,
      'col_6_w': gHeaderInfo.mHeaderComputersWidth['col_6_w'], 
      'col_6_n' :false,
      'col_7':txtComputerHeaderPlatform,
      'col_7_w': gHeaderInfo.mHeaderComputersWidth['col_7_w'], 
      'col_7_n' :false,      
      'col_8':txtHeaderStatus,
      'col_8_w': gHeaderInfo.mHeaderComputersWidth['col_8_w'], 
      'col_8_n' :false,
    }; 
    return tableItem;
  } 

  newData()
  {
    var header = {};
    var rows = [];
    var ret = [];
   try{
      header = getHeaderComputers();

      var len = gComputerList.length;
      for (var i=0;i<len;i++)
      {
        var color = gSystemColor.rowColor;        

        var enabled = "";
        if (gComputerList[i][cComputerEnabled] == "1")
        {
          enabled = "[x]";
          if (gComputerList[i][cComputerConnected] == cComputerConnectedAuthenticated) 
          {
            color =const Color.fromARGB(133, 20, 255, 3);               
          }
          else
          {
            if (gComputerList[i][cComputerConnected] == cComputerConnectedNot) 
            {
              color =const Color.fromARGB(133, 204, 21, 21);               
            }
            else
            {
              if (gComputerList[i][cComputerConnected] == cComputerConnectedAuthenticatedNot) 
              {
                color =const Color.fromARGB(133, 255, 157, 0);               
              }            
            }
          }          
        }
        else
        {
          color =const Color.fromARGB(134, 255, 0, 0);
        }

        if (i.isEven)
        {
          color = lighten(color);
        }

        rows.add({
          'row' : i,
          'color' : color,
          'colorStatus': color,        
          'type': cTypeComputer,
          'computer':gComputerList[i][cComputerName],
          'col_1':enabled,
          'col_2':gComputerList[i][cComputerGroup],
          'col_3':gComputerList[i][cComputerName],
          'col_4':gComputerList[i][cComputerIp],
          'col_5':gComputerList[i][cComputerPort],
          'col_6':gComputerList[i][cComputerBoinc],          
          'col_7':gComputerList[i][cComputerPlatform],
          'col_8':gComputerList[i][cComputerStatus],
        });  
      }

    } catch (error,s) {
      gLogging.addToLoggingError('Computers (newData) $error,$s'); 
    }

    ret.add(header);    
    ret.add(rows);
    return ret;
  }
}

// Add computer dialog
// ===================

class AddComputersDialog extends StatefulWidget {
  final dynamic computerName;
  const AddComputersDialog(this.computerName, {super.key, required this.onConfirm});

  @override
  State<StatefulWidget> createState() {
    return AddComputersDialogState();
  }

  final Function(String value) onConfirm;
}

class AddComputersDialogState extends State<AddComputersDialog> {
  var index = -1;
  bool mbEnabled = true;
  bool mbCanBeDeleted = false;
  String? mErrorIpText;
  String? mErrorNameText = txtComputerScanInValidName;
  bool passwordVisible=true;
  final TextEditingController mComputerGroup = TextEditingController();
  final TextEditingController mComputerName = TextEditingController();
  final TextEditingController mComputerIp = TextEditingController();
  final TextEditingController mComputerPort = TextEditingController();
  final TextEditingController mComputerPassword = TextEditingController();


  @override
  void initState() {  
    mbCanBeDeleted = false;
    var len = gComputerList.length;        
    for (var i=0;i<len;i++)
    {
      if (gComputerList[i][cComputerName] == widget.computerName)     
      {
        var item = gComputerList[i];
        mbEnabled = false;
        var enabled = item[cComputerEnabled];   
        if (enabled == "1")
        {
          mbEnabled = true;
        }       
        mComputerGroup.text = item[cComputerGroup];
        if (gComputerList[i][cComputerName] == cComputerNewName)
        {
          gComputerList[i][cComputerName] = "new";
          mComputerName.text = gComputerList[i][cComputerName];
        }
        else
        {
          mComputerName.text = widget.computerName;
        }
        mComputerIp.text =item[cComputerIp];
        mComputerPort.text =item[cComputerPort];
        mComputerPassword.text =item[cComputerPassword];

        index = i;
        break;
      }
    }
    validateName(mComputerName.text);
    validateIp(mComputerIp.text);
    super.initState();
  }

  checkIfValidItem(item)
  {
    var len = gComputerList.length;
    for (var i=0;i<len;i++)
    {
      if (gComputerList[i][cComputerName] == item[cComputerName])
      {
        if (i!=index) // not self
        {
          return false;
        }
      }
    }
    return true;
  }
  
  validateIp(ip)
  {
    if (IsValid.validateIP4Address(ip))
    {
		  if (isValidLocalIp(ip))
		  {
			  mErrorIpText = null;
      }
      else
      {
			  mErrorIpText = txtComputerScanInValidIpLocal;
      }
    }
    else
    {
      mErrorIpText = txtComputerScanInValidIp;
    }
  }

  validateName(name)
  {
    if (name.length > 1)
    {
		  mErrorNameText = null;
    }
    else
    {
		  mErrorNameText = txtComputerScanInValidName;
    }
  }
 
  deleteComputer(computer)
  {
    try {
      var len = gComputerList.length;        
      for (var i=0;i<len;i++)
      {
        if (gComputerList[i][cComputerName] == computer)
        {
          gComputerList.removeAt(i);
          writeComputerList();
          break;
        }
      }
    } catch (error,s) {
      gLogging.addToLoggingError('Computers (deleteComputer) $error,$s');
    }     
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog 
    (
      insetPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.fromLTRB(10, 12.0, 10, 16.0),
        children: <Widget>[        
          CheckboxListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0),            
            title: Text(txtComputerHeaderEnabled),        
            value: mbEnabled,
            onChanged: (bool? newValue) {
              setState(() {
                mbEnabled = newValue!; 
                mbCanBeDeleted = false;            
                if (gComputerList.length > 1)
                {
                  if (!mbEnabled)
                  {
                    mbCanBeDeleted = true;
                  }
                }
              });
            }
          ),
          TextFormField(
            decoration: InputDecoration(
              labelText: txtComputerHeaderGroup,
            ),
            controller: mComputerGroup,
          ),          
          TextField(
            decoration: InputDecoration(
              labelText: txtComputerHeaderComputer,
              errorText: mErrorNameText,
            ),
            controller: mComputerName,
			      onChanged: (name)
            { 
              validateName(name);
              setState(() {});              
            },            
          ),
          TextField(
            controller: mComputerIp,   
			      onChanged: (ip)
            { 
              validateIp(ip);
              setState(() {});              
            },
            decoration: InputDecoration(
              labelText: txtComputerHeaderIp,
			        errorText: mErrorIpText,
            ),

          ), 
          TextField(
            controller: mComputerPort,            
            decoration: InputDecoration(
              labelText: txtComputerHeaderPort,
            ),
          ),
          TextField(
            obscureText: passwordVisible,
            controller: mComputerPassword,            
            decoration: InputDecoration(
              labelText: txtComputerHeaderPassword,
              suffixIcon: IconButton(
                icon: Icon(passwordVisible
                ? Icons.visibility
                : Icons.visibility_off),
                onPressed: () {
                  setState(
                    () {
                      passwordVisible = !passwordVisible;
                    },
                  );
                },
              ),

            ),
          ),  
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              if (mbCanBeDeleted)
              ElevatedButton(
                onPressed: () { // Delete
                  var ret = mComputerName.text;
                  if (!mbCanBeDeleted)
                  {                
                    ret = "#ENABLED#";            
                    widget.onConfirm(ret);
                    Navigator.of(context).pop(); // close dialog
                  }
                  else
                  {
                    deleteComputer(ret);
                    Navigator.of(context).pop(); // close dialog              
                  }
                },
                child: Visibility(
                  visible: mbCanBeDeleted,
                  child: Text(txtButtonDelete),
                )
              ),
              ElevatedButton(
              onPressed: () { // Cancel
                widget.onConfirm("");
                Navigator.of(context).pop(); // close dialog
              },
              child: Text(txtButtonCancel),       
            ),    
            ElevatedButton(
              onPressed: () { // OK

              if (mErrorNameText == null)
              {                        
                  var sEnabled = "0";
                  if (mbEnabled)
                  {
                    sEnabled = "1";
                  }

                if (index < 0 )
                {
                  index = gComputerList.length;
                  gComputerList.add({cComputerEnabled: "1",cComputerGroup: "", cComputerName: cComputerNewName, cComputerIp: "", cComputerPort: "", cComputerPassword: "", cComputerStatus: "new", cComputerConnected: "??", cComputerBoinc: "", cComputerPlatform: ""} ); 

                }

                  gComputerList[index][cComputerEnabled] = sEnabled;          
                  gComputerList[index][cComputerGroup] = mComputerGroup.text;
                  gComputerList[index][cComputerName] =  mComputerName.text;
                  gComputerList[index][cComputerIp] =  mComputerIp.text;
                  gComputerList[index][cComputerPort] =  mComputerPort.text;                        
                  gComputerList[index][cComputerPassword] =  mComputerPassword.text;
                  if (checkIfValidItem(gComputerList[index]))
                  {
                    writeComputerList();
                    widget.onConfirm("#OK#");
                    // Handle the selected item here           
                    Navigator.of(context).pop(); // close dialog
                  }
                  else
                  {
                    mComputerName.text = "${mComputerName.text} double"; // invalid
                  }
                }
              },
              child: Text(txtButtonOK),
            ),  
          ],
        ),                 
        ],
      /*
      actions: [
        Visibility(
         visible: mbCanBeDeleted,
        child: 
          ElevatedButton(
            onPressed: () { // Delete
              var ret = mComputerName.text;
              if (!mbCanBeDeleted)
              {                
                ret = "#ENABLED#";            
                widget.onConfirm(ret);
                Navigator.of(context).pop(); // close dialog
              }
              else
              {
                deleteComputer(ret);
                Navigator.of(context).pop(); // close dialog              
              }
            },
            child: Visibility(
              visible: mbCanBeDeleted,
              child: Text(txtButtonDelete),
            )
          ),
        ),
        ElevatedButton(
          onPressed: () { // Cancel
            widget.onConfirm("");
            Navigator.of(context).pop(); // close dialog
          },
          child: Text(txtButtonCancel),       
        ), 
        ElevatedButton(
          onPressed: () { // OK

          if (mErrorNameText == null)
          {                        
              var sEnabled = "0";
              if (mbEnabled)
              {
                sEnabled = "1";
              }

            if (index < 0 )
            {
              index = gComputerList.length;
              gComputerList.add({cComputerEnabled: "1",cComputerGroup: "", cComputerName: cComputerNewName, cComputerIp: "", cComputerPort: "", cComputerPassword: "", cComputerStatus: "new", cComputerConnected: "??", cComputerBoinc: "", cComputerPlatform: ""} ); 

            }

              gComputerList[index][cComputerEnabled] = sEnabled;          
              gComputerList[index][cComputerGroup] = mComputerGroup.text;
              gComputerList[index][cComputerName] =  mComputerName.text;
              gComputerList[index][cComputerIp] =  mComputerIp.text;
              gComputerList[index][cComputerPort] =  mComputerPort.text;                        
              gComputerList[index][cComputerPassword] =  mComputerPassword.text;
              if (checkIfValidItem(gComputerList[index]))
              {
                writeComputerList();
                widget.onConfirm("#OK#");
                // Handle the selected item here           
                Navigator.of(context).pop(); // close dialog
              }
              else
              {
                mComputerName.text = "${mComputerName.text} double"; // invalid
              }
            }
          },
          child: Text(txtButtonOK),
        ),
      ],      
      */
    );
  }
}