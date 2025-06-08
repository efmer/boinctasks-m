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

import 'dart:async';

import 'package:boinctasks/dialog/about_licence.dart';
import 'package:boinctasks/lang.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

String gLogTxt = "";
String gLogTxtError = "";  

class BtAbout
{
  Future<void> openDialog(version,context) 
  async {
     await showDialog(
      context: context,
      builder: (myApp) {     
        return BtAboutDialog(dlgName: txtAboutDialogName, dlgVersion: version);
      }
     );
  }
}

class BtAboutDialog extends StatefulWidget {
  final dynamic dlgName;
  final dynamic dlgVersion;  
  const BtAboutDialog({super.key, this.dlgName, this.dlgVersion});


Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}

  @override
  State<StatefulWidget> createState() {
    return BtAboutDialogState();
  }
}

class BtAboutDialogState extends State<BtAboutDialog> { 
  final ScrollController _controller = ScrollController();
  bool bMore = false;
  @override
  void initState() { 
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var versionNr = widget.dlgVersion;
    var version = "BoincTasks-M V $versionNr";
    var now = "© ${DateTime.now().year}";
    var copyright = "Copyright $now, eFMer Fred Melgert\n\nThis program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation version 3 or any later version.\nThis program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.";

    var license = gParticence;
    if (bMore)
    {
      license = gFullLicence;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dlgName),
      ),
      body: Center(
        child: SingleChildScrollView(
          controller: _controller,
          child: Column(
          children:[
            InkWell(
              child:Text(version)
            ),
                        
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://efmer.com/boinctasks-m-for-android-and-ios/');
                widget._launchUrl(websiteUrl);              
              },
              child: Image.asset('assets/images/boinctasks-m.png',width: 150,),
            ),
            
            ElevatedButton(
              onPressed: () {
                Uri websiteUrl = Uri.parse('https://efmer.com/boinctasks-m-for-android-and-ios/');
                widget._launchUrl(websiteUrl);
              },                                
              child: Text(txtAboutWebsite),
            ),

            Container(height: 40, width: 1, color: Colors.grey, margin: const EdgeInsets.only(left: 10.0, right: 10.0),),

            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://github.com/efmer/boinctasks-m');
                widget._launchUrl(websiteUrl);              
              },
              child: Image.asset('assets/images/github.png',width: 150,),
            ),
            
            ElevatedButton(
              onPressed: () {
                Uri websiteLicence = Uri.parse('https://github.com/efmer/boinctasks-m');
                widget._launchUrl(websiteLicence);                       
              },                                
              child: Text(txtAboutGithub),
            ),
  
            Container(height: 40, width: 1, color: Colors.grey, margin: const EdgeInsets.only(left: 10.0, right: 10.0),),

            DecoratedBox(
              decoration: const BoxDecoration(color: Color.fromARGB(255, 255, 255, 255)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(copyright),
              ),
            ),

            Container(height: 40, width: 1, color: Colors.grey, margin: const EdgeInsets.only(left: 10.0, right: 10.0),),

            ElevatedButton(
              onPressed: () {
                Uri websiteLicence = Uri.parse('https://www.gnu.org/licenses/gpl-3.0-standalone.html');
                widget._launchUrl(websiteLicence);                       
              },                                
              child: Text(txtAboutLicence),
            ),
            GestureDetector (
            behavior: HitTestBehavior.translucent,
            onTap:  (){
              bMore = true;
              setState(() {});
            },
            child: DecoratedBox(              
              decoration: const BoxDecoration(color: Color.fromARGB(255, 255, 255, 255)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(license),
              ),
            ),  
            )
                                                                                        
          ],
          
          ),
        ),
      )
      
       //Text(this.indata),
    );
  }

}