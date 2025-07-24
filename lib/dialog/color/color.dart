//colors for headers, row headers, and rows

import 'package:flutter/material.dart';

class SystemColor
{
  var bDart = false;

  var pageHeaderColor   = const Color.fromARGB(255, 255, 255, 255);
  var headerColor     = Color.fromRGBO(0, 102, 204, 1);
  var rowHeaderColor  = Color.fromRGBO(51, 153, 255, 1);

  var pageHeaderFontColor = Colors.white;
  var headerFontColor     = Colors.white;
  var rowHeaderFontColor  = Colors.white;
  var rowFontColor        = Colors.white;

  // logging text
  var viewBackgroundColor  = Colors.white;

  // project messages transfers
  var rowColor        = const Color.fromARGB(255, 234, 234, 234);
  var rowColorText    = const Color.fromARGB(255, 0, 0, 0); 
  var rowColorSel     = const Color.fromARGB(255, 68, 68, 68);
  var rowColorTextSel = const Color.fromARGB(255, 255, 255, 255);

  var graphBackgroundColor = const Color.fromARGB(255, 255, 255, 255);

  var tabSelectColor = Color.fromRGBO(0, 0, 0, 1);

  setTheme(bool bDark)
  {
    if (bDark)
    {
      bDark = true;
    
      pageHeaderColor = Color.fromRGBO(51, 102, 153, 1);
      headerColor     = Color.fromRGBO(0, 102, 204, 1);
      rowHeaderColor  = Color.fromRGBO(51, 153, 255, 1);

      pageHeaderFontColor = Colors.white;
      headerFontColor     = Colors.white;
      rowHeaderFontColor  = Colors.white;
      rowFontColor        = Color.fromARGB(255, 0, 0, 0);

      // logging text
      viewBackgroundColor = Colors.black;

      rowColor        = const Color.fromARGB(255, 37, 37, 37);
      rowColorText    = const Color.fromARGB(255, 255, 255, 255); 
      rowColorSel     = const Color.fromARGB(255, 218, 218, 218);
      rowColorTextSel = const Color.fromARGB(255, 0, 0, 0);

      tabSelectColor = Color.fromRGBO(0, 0, 0, 1);

      graphBackgroundColor = const Color.fromARGB(255, 0, 0, 0);
    }
    else  //light
    {
      bDark = false;  

      pageHeaderColor   = const Color.fromARGB(255, 255, 255, 255);
      //pageHeaderColor   = const Color.fromARGB(255, 146, 206, 255);      
      headerColor       = Color.fromRGBO(65, 159, 253, 1);
      rowHeaderColor    = Color.fromRGBO(51, 153, 255, 1);

      pageHeaderFontColor = Colors.white;
      headerFontColor     = Colors.white;
      rowHeaderFontColor  = Colors.white;
      rowFontColor        = Color.fromARGB(255, 0, 0, 0); 

      // logging text
      viewBackgroundColor  = Colors.white;

      rowColor        = const Color.fromARGB(255, 234, 234, 234);
      rowColorText    = const Color.fromARGB(255, 0, 0, 0); 
      rowColorSel     = const Color.fromARGB(255, 68, 68, 68);
      rowColorTextSel = const Color.fromARGB(255, 255, 255, 255);   

      tabSelectColor = Color.fromRGBO(0, 0, 0, 1);     

      graphBackgroundColor = const Color.fromARGB(255, 255, 255, 255); 
    }
  }
}