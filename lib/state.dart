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
  var mbStateNeedsUpdate = true;
  Map mState = {};
  List mProjects = [];
  var mWu = [];

  setState(state)
  {
    mState = state;
    mbStateNeedsUpdate = false;
  }

  isStateNeedsUpdate()
  {
    return mbStateNeedsUpdate;
  }

  getProject(url)
  {
    try{
      if (mState.isNotEmpty)
      {
        Map clientState = mState['client_state'];
        if (clientState.containsKey('project'))
        {
          var projects = clientState['project'];
          addProject(projects);
        }          
      }          
      else
      {
        mbStateNeedsUpdate = true;
        return "?? $url";
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
      return "?? $url";
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (getProject) $error,$s'); 
    }
  }

  addProject(projects)
  {
    try
    {
      var testSingle = projects[0];
      if (testSingle == null) // null = map
      {
        if (!isProjectPresent(projects))
        {
          mProjects.add(projects);  // we have a single item
        }
      }
      else
      {
        var len = projects.length;
        for (var i=0;i<len;i++)
        {
          var item = projects[i];
          if (!isProjectPresent(item))
          {
            mProjects.add(item);
          }
        }
      }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (addProject) $error,$s'); 
    }     
  }

  isProjectPresent(project)
  {
    try{
        var url = project['master_url']['\$t'];
        var len = mProjects.length;
        for (var i=0;i<len;i++)
        {
          if (mProjects[i]['master_url']['\$t']  == url)
          {
            return true;
          }
        }    
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (isProjectPresent) $error,$s'); 
    }     
    return false;   
  }

  getProjectUrl(name)
  {
    try{
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
      return "?? $name";
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (getProjectUrl) $error,$s'); 
    }  
  }

  getWuName(wu)
  {
   try{
     if (mState.isEmpty)
     {
       mbStateNeedsUpdate = true;          
       return null;
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
      gLogging.addToLoggingError('State (getWuName) $error,$s'); 
    }      
  }

  getProjectName(projectName)
  {
   try{
     if (mState.isEmpty)
     {
       mbStateNeedsUpdate = true;          
       return null;
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
        if (mState.isEmpty)
        {
          mbStateNeedsUpdate = true;          
          return null;
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
            if (item == null)   // a single item is not an array.
            {
              if (apps['name']['\$t'] == app) 
              {
                return apps ;
              }
            }
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