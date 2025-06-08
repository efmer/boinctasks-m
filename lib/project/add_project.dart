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
import 'package:boinctasks/functions.dart';
import 'package:boinctasks/lang.dart';
import 'package:boinctasks/main.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class AddProject
{
    start(context)
    {
      try{
      showDialog(
        context: context,
          builder: (myApp) {
            return AddProjectDialog();
          }
        );  
      ();
//      var req = "";
//      mRpc.getProjectList();
      } catch (error,s) {
        gLogging.addToLoggingError('AddProject (start) $error,$s'); 
      } 
    }

}


class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({super.key});

  @override
  State<StatefulWidget> createState() {
    return AddProjectDialogState();
  }
}

class AddProjectDialogState extends State<AddProjectDialog> {
  String? selectedComputer;
  String? selectedProject;  
  String account = "";
  String password = "";
  bool bpasswordVisible = false;
  String textSummary = "";  
  String textAbout = "";
  String textStatus = "";
  late Color colorStatus;
  List<String> computers = mRpc.getComputers();
  List<String> projects = [];
  var projectList = [];
  late TextEditingController _controllerAccount;
  late TextEditingController _controllerPassword;
  late TextEditingController _controllerUrl;

  void setStatus(txt,error)
  {
    textStatus = txt;
    if (error)
    {
      colorStatus = const Color.fromARGB(255, 247, 0, 0);
    }
    else
    {
      colorStatus = const Color.fromARGB(255, 39, 220, 3);
    }
  }

  void callbackList(data)
  {
    try {
      var projectsXml = xmlToJson(data,"<projects>","</projects>");       
      projectList = projectsXml['projects']['project'];

      var len = projectList.length;
      for (var i=0;i<len;i++)
      {
        var name = projectList[i]['name']['\$t'];
        projects.add(name);
      }
      setState(() {      
      });
    } catch (error,s) {
      gLogging.addToLoggingError('AddProjectDialogState (callbackList) $error,$s');
    }     
  }

  void callbackAdd(data)
  {
    try {
      var reply = extractXml(data,"<error>","</error>"); 
      if (reply.isNotEmpty)
      {
        setStatus(reply,true);
        setState(() {      
        });
        return;
      }

      if (data.contains('success'))
      {
        var ix = mRpc.getIndex(selectedComputer); // ix must be valid
        var toSend = "<lookup_account_poll/>\n";
        mRpc.sendComputer(callbackLookup,computers[ix],toSend); 
        return;
      }

      var errorNr = extractXml(data,"<error_num>","</error_num>"); 
      if (errorNr.isNotEmpty)
      {
        // -204 not ready try again
        Future.delayed(const Duration(seconds: 1), () {
            addProject();
          return;
        });
        return;
      }     


      setStatus("Unknown error",true);
        setState(() {      
      });

        
    } catch (error,s) {
      gLogging.addToLoggingError('AddProjectDialogState (callbackAdd) $error,$s');
    }     
  }

  void callbackLookup(data)
  {
    try {
      var reply = extractXml(data,"<error>","</error>"); 
      if (reply.isNotEmpty)
      {
        var errorMsg = extractXml(reply,"<error_msg>","</error_msg>"); 
        if (errorMsg.isNotEmpty)
        {
          setStatus(errorMsg,true);
          setState(() {      
          });          
          return;       
        }

        // should not happen shows raw data
        setStatus(reply,true);
        setState(() {      
        });
        return;
      }

      var errorNr = extractXml(data,"<error_num>","</error_num>"); 
       if (errorNr.isNotEmpty)
      {
        // -204 not ready try again
        Future.delayed(const Duration(seconds: 1), () {
          var ix = mRpc.getIndex(selectedComputer); // ix must be valid
          var toSend = "<lookup_account_poll/>\n";
          mRpc.sendComputer(callbackLookup,computers[ix],toSend);
          return;
        });
        return;
      }     

      var auth = extractXml(data,"<authenticator>","</authenticator>"); 
      if (auth.isNotEmpty)
      {
        var url = _controllerUrl.text;
        var name = getProjectName(url);
        if (name.isEmpty)
        {
          setStatus("Url is invalid",true);
          setState(() {      
          });
          return;
        }

        var toSend = "<project_attach>\n<project_url>$url</project_url>\n<authenticator>$auth</authenticator>\n<project_name>$name</project_name>\n</project_attach>\n";
        var ix = mRpc.getIndex(selectedComputer); // ix must be valid        
        mRpc.sendComputer(callbackAttach,computers[ix],toSend); 
        return;
      } 

      setStatus("no authenticator",true);
        setState(() {      
      });
    } catch (error,s) {
      gLogging.addToLoggingError('AddProjectDialogState (callbackLookup) $error,$s');
    } 
  }

  callbackAttach(data)
  {
    try {
      var reply = extractXml(data,"<error>","</error>"); 
      if (reply.isNotEmpty)
      {
        setStatus(reply,true);
        setState(() {      
        });
        return;      
      }
      var url = _controllerUrl.text;
      var name = getProjectName(url);      
      setStatus("Project $name attached",false); 
      setState(() {      
      });
    } catch (error,s) {
      gLogging.addToLoggingError('AddProjectDialogState (callbackAttach) $error,$s');
    }       
  }

  String getProjectName(urlCheck)
  {
    try {
      var len = projectList.length;
      for (var i=0;i<len;i++)
      {
        var url = projectList[i]['url']['\$t'];
        if (urlCheck == url)
        {
          return projectList[i]['name']['\$t'];
        }
      }
    } catch (error,s) {
      gLogging.addToLoggingError('AddProjectDialogState (getSummary) $error,$s');
    }    
    return ""; 
  }

  String getSummary(project)
  {
    try {
      var len = projectList.length;
      for (var i=0;i<len;i++)
      {
        var name = projectList[i]['name']['\$t'];
        if (name == project)
        {
          return projectList[i]['summary']['\$t'];
        }
      }
    } catch (error,s) {
      gLogging.addToLoggingError('AddProjectDialogState (getSummary) $error,$s');
    }    
    return "";
  }

  String getDescription(project)
  {
    try {
    var len = projectList.length;
    for (var i=0;i<len;i++)
    {
      var name = projectList[i]['name']['\$t'];
      if (name == project)
      {
        return projectList[i]['description']["__cdata"];
      }
    }
    } catch (error,s) {
      gLogging.addToLoggingError('AddProjectDialogState (getDescription) $error,$s');
    }    
    return "";
  }

  String getUrl(project)
  {
    try {
      var len = projectList.length;
      for (var i=0;i<len;i++)
      {
        var name = projectList[i]['name']['\$t'];
        if (name == project)
        {
          return projectList[i]['url']['\$t'];
        }
      }
    } catch (error,s) {
      gLogging.addToLoggingError('AddProjectDialogState (getUrl) $error,$s');
    }    
    return "";
  }

  void addProject()
  {
    try {
      var login = _controllerAccount.text;
      var password = _controllerPassword.text;
      var url = _controllerUrl.text;
      if (url.length > 4)
      {
        var  np = "$password$login";
        var hash = md5.convert(utf8.encode(np)).toString();  
        var toSend =   "<lookup_account>\n<url>$url</url>\n<email_addr>$login</email_addr>\n<passwd_hash>$hash</passwd_hash>\n</lookup_account>\n";
        var ix = mRpc.getIndex(selectedComputer);
        if (ix < 0)
        {
          setState(() {
            setStatus("no computer selected",true);
          });
          return;
        }
        mRpc.sendComputer(callbackAdd,computers[ix],toSend);            
      }
      else
      {
        setState(() {      
          setStatus("no valid URL",true);
        });
      }
    } catch (error,s) {
      gLogging.addToLoggingError('AddProjectDialogState (addProject) $error,$s');
    } 
  }

  @override
  void initState() {
    if (computers.isEmpty)
    {
      return;
    }
    super.initState();   
    setStatus("",false);
    mRpc.sendComputer(callbackList,computers[0],"<get_all_projects_list/>\n");  // any computer works, should all have the same project list
    selectedComputer = null;    
    selectedProject = null;

    _controllerUrl = TextEditingController();
    _controllerAccount = TextEditingController();
    _controllerPassword = TextEditingController();

    _controllerAccount.text = "";
    _controllerPassword.text = "";
  }

    @override
  void dispose() {
    _controllerUrl.dispose();
    _controllerAccount.dispose();
    _controllerPassword.dispose();        
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        ElevatedButton(
          onPressed: () {
            addProject();
          },
          child: const Text('Add Project'),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedComputer != null) {
//              var iselectedValue = int.parse(selectedValue!);              
            }
            Navigator.of(context).pop(); // close dialog
          },
          child: const Text('Exit'),
        ),
      ],


      titlePadding: const EdgeInsets.only(top: 5, left: 10, right: 15, bottom: 0),      
      contentPadding: const EdgeInsets.only(
          top: 5,
          left: 10,
          right: 15,
          bottom: 5
      ),      
      title: Text(
          txtComputers,
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 420,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _controllerAccount, 
              decoration: InputDecoration(
                hintText: 'Account',  
              ),   
              onChanged: (text) {
                _controllerAccount.text = text;
                setState(() {
                  setStatus("",false);
               });
              },  
            ),
            
            TextField(
              obscureText: bpasswordVisible,
              controller: _controllerPassword,
              decoration: InputDecoration(
                hintText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(bpasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off
                  ), onPressed: () {
                    setState(()  {
                      bpasswordVisible = !bpasswordVisible;
                    });                  
                  }
                ) 
              ),   
              
              onChanged: (text) {
                setState(() {
                  _controllerPassword.text = text;                  
                  setState(() {
                    setStatus("",false);
                  });
                });
              },   
            ),

            DropdownButtonHideUnderline(
              child: DropdownButton(
                hint: Text(
                  txtSelectComputer,
                ),
                value: selectedComputer,
//                value:refreshRate,
                items: computers
                    .map((item) =>
                    DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                      ),
                    ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    setStatus("",false);
                    selectedComputer = value;
                    //Navigator.of(context).pop();
                  });
                },
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton(
                hint: Text(
                  txtSelectProject,
                ),
                value: selectedProject,
//                value:refreshRate,
                items: projects
                    .map((item) =>
                    DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                      ),
                    ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                  textSummary = getSummary(value);
                  textAbout = getDescription(value);
                  setStatus("", false);
                  _controllerUrl.text = getUrl(value);
                    selectedProject = value;
                    //Navigator.of(context).pop();
                  });                
                }
              ),        
            ),          
            TextField(
              controller: _controllerUrl,
              decoration: InputDecoration(
                hintText: 'Project Url',  
              ),   
              onChanged: (text) {
                setState(() {
                  setStatus("",false);
               });
            },                         
            ),
            Expanded(              
              child: Text(textStatus,
                style: TextStyle(
                  color: colorStatus,
                  fontWeight: FontWeight.bold,
                ),            
              ),
            ),
            Expanded(              
              child: Text(textSummary),
            ),             
            Expanded(       
              child: SingleChildScrollView(
                child: Text(textAbout),
              ),     
            ),
          ],
        ),
      )        
    );
  }
}