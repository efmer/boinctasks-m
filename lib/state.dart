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

import 'package:boinctasks/constants.dart';
import 'package:boinctasks/main.dart';

class ProjectList {
  List <String> mUrl = [];
  List <String> mName = [];

  void clear()
  {
    mUrl = [];
    mName = [];
  }

  void addItem(String url,String name)
  {
    mUrl.add(url);
    mName.add(name);
  }

  String getNameFromUrl(String url)
  {
    var index = mUrl.indexOf(url);
    if (index >= 0)
    {
      return mName[index];
    }
    return cNotFound;
  }

  String getUrl(String name)
  {
    var index = mName.indexOf(name);
    if (index >= 0)
    {
      return mUrl[index];
    }
    return cNotFound;  
  }
}

class UserFriendly {
  List <String> mWu = [];
  List <String> mName = [];
  List <String> mNameFriendly = [];

  void clear()
  {
    mWu = [];
    mName = [];
    mNameFriendly = [];
  }

  void add(String wu, String name, String friendly)
  {
    mWu.add(wu);
    mName.add(name);    
    mNameFriendly.add(friendly);
  }

  String getName(String wu)
  {
    var index = mWu.indexOf(wu);
    if (index >= 0)
    {
      return mName[index];
    }
    return cNotFound; 
  }

  String getNameFriendly(String wu)
  {
    var index = mWu.indexOf(wu);
    if (index >= 0)
    {
      return mNameFriendly[index];
    }
    return cNotFound; 
  }

}


class BoincState {
  var mbStateNeedsUpdate = true;
  Map mState = {};
  ProjectList mProjectsCache = ProjectList();
  UserFriendly mCacheUserFriendly = UserFriendly();

  void setState(dynamic state)
  {
    try{
      mState = state;
      mbStateNeedsUpdate = false;
      if (mState.isNotEmpty)
      {
        var cs = mState['client_state'];
        if (cs.containsKey('workunit'))
        {
          var wu = cs['workunit'];
          buildCacheUserFriendly(wu);
        }
        buildCache();
      }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (setState) $error,$s'); 
    }    
  }

  void buildCache()
  {
    try
    {
      mProjectsCache.clear();
      var cs = mState['client_state'];
      if (cs.containsKey('project'))    
      {
        var projects = cs['project']; 
        var testSingle = projects[0];
        if (testSingle == null) // null = map
        {
          mProjectsCache.addItem(projects['master_url']['\$t'], projects['project_name']['\$t']);
        }
        else
        {
          var len = projects.length;
          for (var i=0;i<len;i++)
          {
            var item = projects[i];
            mProjectsCache.addItem(item['master_url']['\$t'], item['project_name']['\$t']);          
          }
        }
      }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (buildCache) $error,$s'); 
    }     
  }

  void buildCacheUserFriendly(dynamic wu) // not a list on a single item
  {
    try{
      mCacheUserFriendly.clear();      
      var lenWu = wu.length;
      for (var i=0;i<lenWu;i++)
      {
        var wui = wu[i];  
        if (wui == null)  // a single item, not a list
        {
          wui = wu;
          i = lenWu + 1;
        }
        var name = wui['name']['\$t'];  
        String app = wui['app_name']['\$t'];
        var apps = mState['client_state']['app'];
        var lenApps = apps.length;   
        for (var ii=0;ii<lenApps;ii++)
        {
          var item = apps[ii];
          if (item == null)   // a single item is not an array.
          {
            ii = lenApps+1;
            i = lenWu+1;
            item = apps;
          }
          if (item['name']['\$t'] == app)
          {
            String appName = item['name']['\$t'];            
            String userFriendly = item['user_friendly_name']['\$t'];
            mCacheUserFriendly.add(name, appName, userFriendly);
          }
        }        
      }
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (buildCacheUserFriendly) $error,$s'); 
    }
  }

  bool isStateNeedsUpdate()
  {
    return mbStateNeedsUpdate;
  }

  String getProject(String url)
  {
    try{
      var name = mProjectsCache.getNameFromUrl(url);
      if (name == cNotFound)
      {
        mbStateNeedsUpdate = true;        
      }
      return name;
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (getProject) $error,$s'); 
    }
    return cNotFound;
  }

  String getProjectUrl(String name)
  {
    try{
      var url = mProjectsCache.getUrl(name);
      if (url == cNotFound)
      {
        mbStateNeedsUpdate = true;
      }
      return url;
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (getProjectUrl) $error,$s'); 
    }  
    return name;
  }

  dynamic getProjectItem(String projectName)
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
        if (item == null)
        {
          item = project;   // one item
          i = len + 1;
        }

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
      gLogging.addToLoggingError('State (getProjectItem) $error,$s'); 
    }      
  }

  String getAppUfriendly(String wu)
  {
    try{
      var name = mCacheUserFriendly.getNameFriendly(wu);
      if (name == cNotFound)
      {
        mbStateNeedsUpdate = true;        
        return name;
      }
      return name;
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (getAppUfriendly) $error,$s'); 
    }
    mbStateNeedsUpdate = true;       
    return cNotFound;
  }

    String getAppUname(String wu)
  {
    try{
      var name = mCacheUserFriendly.getName(wu);
      if (name == cNotFound)
      {
        mbStateNeedsUpdate = true;
        return name;
      }
      return name;
    }
    catch(error,s)
    {
      gLogging.addToLoggingError('State (getAppUfriendly) $error,$s'); 
    }
    mbStateNeedsUpdate = true;       
    return cNotFound;
  }

  dynamic getWuName(dynamic wu)
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

}