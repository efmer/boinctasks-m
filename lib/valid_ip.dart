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

//10.0.0.0 - 10.255.255.255
//172.16.0.0 - 172.31.255.255
//192.168.0.0 - 192.168.255.255

import 'package:boinctasks/main.dart';
import 'package:is_valid/is_valid.dart';

bool isValidLocalIp(String ip)
{
  try{
    if (IsValid.validateIP4Address(ip))
    {
      var ipSplit = ip.split('.');
      var first = ipSplit[0];
      var second = int.parse(ipSplit[1]);
      if (first == '10')
      {
        return true;
      }
      if (first == '192')
      {
        if (second == 168) 
        {
          return true;
        }
      }
      if (first == '172')
      {
        if (second >= 16)
        {
          if (second <=31)
          {
            return true;
          }
        }
      }
    }
  }catch(error,s)
  {
    gLogging.addToLoggingError('Valid IP (isValidLocalIp) $error,$s');
  }  
	return false;
}