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
import 'package:boinctasks/main.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BtAbout
{
  Future<void> openDialog(String version,context) 
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

class BtAboutDialogState extends State<BtAboutDialog> with SingleTickerProviderStateMixin {   
  final ScrollController _controller = ScrollController();
  bool bMore = false;
  late AnimationController _controllerA;
  late Animation<Offset> _animation;

  @override
  void initState() { 
    super.initState();
    _controllerA = AnimationController(duration: const Duration(seconds: 4), vsync: this);
    _animation = Tween<Offset>(
      begin: Offset(-2, 0),
      end: Offset.zero,
    ).animate(_controllerA);
    _controllerA.forward();
  }

  @override
  Widget build(BuildContext context) {
    var versionNr = widget.dlgVersion;
    var version = " BoincTasks-M V $versionNr";
    var now = "© ${DateTime.now().year}";
    var copyright = "Copyright $now, eFMer, Fred Melgert\n\nThis program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation version 3 or any later version.\nThis program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.";

    var license = gParticence;
    if (bMore)
    {
      license = gFullLicence;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dlgName + version),
        backgroundColor: gSystemColor.pageHeaderColor,         
      ),
      body: Center(
        child: SingleChildScrollView(
          controller: _controller,
          child: Column(
          children:[
            InkWell(
              child:Text("")
            ),
                        
            ElevatedButton(
              onPressed: () {
                Uri websiteUrl = Uri.parse('https://efmer.com/boinctasks-m-for-android-and-ios/boinctasksm-how-to/boinctasks-m-how-to-get/');
                widget._launchUrl(websiteUrl);
              },                                
              child: Text(txtAboutWhatIsNew + versionNr),
            ),
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://efmer.com/boinctasks-m-for-android-and-ios/');
                widget._launchUrl(websiteUrl);              
              },
              
              child: SlideTransition(
                position: _animation,
                child: Container(
                  color: Colors.white,
                  child: Image.asset('assets/images/boinctasks-m.png',width: 150,),
                ),
              ),                      
            ),
            Text(""),
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
              child: Image.asset('assets/images/github.png',width: 75,),
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
              decoration: BoxDecoration(color: gSystemColor.viewBackgroundColor),
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
                decoration: BoxDecoration(color: gSystemColor.viewBackgroundColor),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(license),
                ),
              ),  
            ),

            Text(""),
            Text("We use the following software:"),
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://github.com/flutter/flutter/tree/master');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("Flutter: Copyright 2014 The Flutter Authors. All rights reserved."),
            ),
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://github.com/dart-lang/');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("Dart: Copyright 2023, the Dart project authors."),
            ), 
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/cupertino_icons');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("cupertino_icons: Copyright (c) 2016 Vladimir Kharlampidi"),
            ),
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/intl');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("intl: Copyright 2013, the Dart project authors."),
            ),
            Text(""),    
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/package_info_plus');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("package_info_plus: Copyright 2017 The Chromium Authors. All rights reserved."),
            ), 
            Text(""),            
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/crypto');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("crypto: Copyright 2015, the Dart project authors."),
            ),
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/xml2json');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("xml2json: Copyright (c) 2019 Steve Hamblett<steve.hamblett@linux.com>"),
            ),
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/flex_color_picker');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("flex_color_picker: Copyright (c) 2020-2025 Mike Rydstrom (Rydmike)"),
            ),
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/url_launcher');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("url_launcher: Copyright 2013 The Flutter Authors. All rights reserved."),
            ),
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/is_valid');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("is_valid: Copyright (C) 2007 Free Software Foundation, Inc."),
            ), 
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/permission_handler');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("permission_handler: Copyright (c) 2018 Baseflow"),
            ), 
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/permission_handler');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("network_info_plus: Copyright 2017 The Chromium Authors. All rights reserved."),
            ), 
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/get_ip_address');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("get_ip_address: Copyright (c) 2021 Pradyot Prakash"),
            ),
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/path_provider');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("path_provider: Copyright 2013 The Flutter Authors. All rights reserved."),
            ), 
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/fluttertoast');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("fluttertoast: Copyright (c) 2020 Karthik Ponnam."),
            ),
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/fl_chart');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("fl_chart: Copyright (c) 2022 Flutter 4 Fun"),
            ), 
            Text(""),
            GestureDetector(
              onTap: () {
                Uri websiteUrl = Uri.parse('https://pub.dev/packages/provider');
                widget._launchUrl(websiteUrl);              
              },
              child: Text("provider: Copyright (c) 2019 Remi Rousselet"),
            ),
            Text(""),            

          ],
          
          ),
        ),
      )
      
       //Text(this.indata),
    );
  }

}