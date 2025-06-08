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

import 'package:boinctasks/main.dart';

class BoincState {
  var mbValid = false;
  var mbStateNeedsUpdate = true;
  // ignore: prefer_typing_uninitialized_variables
  late var mState;
  var mProjects = [];
  var mWu = [];

  setState(state)
  {
    mState = state;
    mbValid = true;
  }

  needsUpdate()
  {
    mbStateNeedsUpdate = true;
  }

  updated()
  {
    mbStateNeedsUpdate = false;
  }

  getProject(url)
  {
    try{
      if (mProjects.isEmpty)
      {
        mProjects = mState['client_state']['project'];
      }
      var len = mProjects.length;
      for (var i=0;i<len;i++)
      {
        var item =  mProjects[i];
        if (item['master_url']['\$t'] == url)
        { 
          var project = item['project_name']['\$t'];
          return project;
        }
      }
      mbStateNeedsUpdate = true;
      return "??";
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (getProject) $error,$s'); 
    }
  }

  getProjectUrl(name)
  {
      try{
      if (mProjects.isEmpty)
      {
        mProjects = mState['client_state']['project'];
      }
      var len = mProjects.length;
      for (var i=0;i<len;i++)
      {
        var item =  mProjects[i];        
        if (item['project_name']['\$t'] == name)
        { 
          var url = item['master_url']['\$t'];
          return url;
        }
      }
      mbStateNeedsUpdate = true;
      return "??";
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (getProjectUrl) $error,$s'); 
    }  
  }

  getWuName(wu)
  {
   try{
     if (mState == null)
     {
       mbStateNeedsUpdate = true;          
       return "";
     }
     var result = mState['client_state']['result'];      
      var len = result.length;
      for (var i=0;i<len;i++)
      {
        var item =  result[i];
        if (item['name']['\$t'] == wu)
        {        
          return item;
        }
      }
      mbStateNeedsUpdate = true;
      return null;
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (getAppUfriendly) $error,$s'); 
    }      
  }

  getProjectName(projectName)
  {
   try{
     if (mState == null)
     {
       mbStateNeedsUpdate = true;          
       return "";
     }
     var project = mState['client_state']['project'];      
      var len = project.length;
      for (var i=0;i<len;i++)
      {
        var item =  project[i];
        if (item['project_name']['\$t'] == projectName)
        {        
          return item;
        }
      }
      mbStateNeedsUpdate = true;
      return null;
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (getProjectName) $error,$s'); 
    }      
  }

  getAppUfriendly(wu)
  {
    try{
      if (mWu.isEmpty)
      {
        if (mState == null)
        {
          mbStateNeedsUpdate = true;          
          return "";
        }
        mWu = mState['client_state']['workunit'];
      }
      var len = mWu.length;
      for (var i=0;i<len;i++)
      {
        var item =  mWu[i];
        if (item['name']['\$t'] == wu)
        {        
          var app = item['app_name']['\$t'];
          var apps = mState['client_state']['app'];
          var len = apps.length;   
          for (var ii=0;ii<len;ii++)
          {
            item = apps[ii];
            if (item['name']['\$t'] == app)
            {
              return item ;
            }
          }
        }
      }
      mbStateNeedsUpdate = true;
      return null;
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (getAppUfriendly) $error,$s'); 
    }
  }
}