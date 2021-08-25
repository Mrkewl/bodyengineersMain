import '../../helper/tools_helper.dart';
import '../../model/planner/planner_model.dart';
import '../../model/watch/watch_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'dart:convert' as convert;

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/user/user_model.dart';
import '../../model/user/user.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';

class SyncDevices extends StatefulWidget {
  @override
  _SyncDevicesState createState() => _SyncDevicesState();
}

class _SyncDevicesState extends State<SyncDevices> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  UserObject? user;
  bool isGarminSynced = false;
  bool isPolarSynced = false;

  void prompt(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  googleCalendar() async {
    await Provider.of<PlannerModel>(context, listen: false)
        .sendPlannerToGoogleCalendar(prompt);
  }

  showAlertDialog({String? message, bool? result}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Container(
                child: Text(message!),
              ),
            ));
  }

  webview(String url, String title) {
    // bulk edit //print(url);

    showDialog(
        context: context,
        builder: (context) => WebviewScaffold(
              resizeToAvoidBottomInset: true,
              url: url + '?uid=' + user!.uid!,
              appBar: AppBar(
                title: Text(title),
              ),
              persistentFooterButtons: [
                Text(
                  "On the last step, you need to wait ~20 seconds to sync successfully. Please don't cancel until 'Sync Completed' popup appear.",
                  textAlign: TextAlign.center,
                ),
              ],
              javascriptChannels: Set.from([
                JavascriptChannel(
                    name: 'Print',
                    onMessageReceived: (JavascriptMessage message) {
                      // bulk edit //print(message.message);

                      Navigator.pop(context);

                      Map<String, dynamic> response =
                          convert.jsonDecode(message.message);

                      showAlertDialog(
                          result: response['result'],
                          message: response['message']);

                      if (response['result']) {
                        // Future.delayed(Duration(seconds: 120), () async {
                        Provider.of<WatchModel>(context, listen: false)
                            .getDataFromServer();
                        // });
                      }
                    })
              ]),
            ));
  }

  webviewSecure(String url) {
    FlutterWebBrowser.openWebPage(
      url: url,
      customTabsOptions: CustomTabsOptions(
        colorScheme: CustomTabsColorScheme.dark,
        toolbarColor: Colors.deepPurple,
        secondaryToolbarColor: Colors.green,
        navigationBarColor: Colors.amber,
        addDefaultShareMenuItem: true,
        instantAppsEnabled: true,
        showTitle: true,
        urlBarHidingEnabled: true,
      ),
      safariVCOptions: SafariViewControllerOptions(
        barCollapsingEnabled: true,
        preferredBarTintColor: Colors.green,
        preferredControlTintColor: Colors.amber,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        modalPresentationCapturesStatusBarAppearance: true,
      ),
    );
  }

  calendarAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Google Calendar Sync"),
          content: Text(
              "When you press 'Sync' button, BE App will sync your current program with Google Calendar. \n\nPlease keep in mind that, if you change anything in your program, you have to sync your program again."),
          actions: [
            FlatButton(
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 17),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
                child: Text(
                  "Sync",
                  style: TextStyle(fontSize: 17),
                ),
                onPressed: () {
                  googleCalendar();
                }),
          ],
        );
      },
    );
  }

  alreadySyncedDialog(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Already Synced"),
          content: Text(
              "You're already synced. Do you want to sync your device again?"),
          actions: [
            FlatButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            FlatButton(
              child: Text("Sync Again"),
              onPressed: () {
                switch (name) {
                  case 'Garmin':
                    Navigator.pop(context);
                    webview(Tools.urlConverter('garminApi/authApi'),
                        'Garmin Connect');
                    break;
                  case 'Polar':
                    Navigator.pop(context);

                    webview(Tools.urlConverter('polarApi/getAll'), 'Polar');
                    break;
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context, listen: true).user;
    isGarminSynced = Provider.of<WatchModel>(context).garminDataList != null &&
        Provider.of<WatchModel>(context).garminDataList!.isNotEmpty;
    return Scaffold(
        key: _key,
        appBar: setAppBar(_key) as PreferredSizeWidget?,
        drawer: buildProfileDrawer(context, user),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Color.fromRGBO(8, 112, 138, 1),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.chevron_left,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      allTranslations.text('sync_devices')!,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      width: 30,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: GestureDetector(
                  onTap: () {
                    isPolarSynced
                        ? alreadySyncedDialog(context, 'Polar')
                        : webview(
                            Tools.urlConverter('polarApi/getAll'), 'Polar');
                  },
                  child: SyncDeviceItem(
                    isFilled: Provider.of<WatchModel>(context).polarDataList !=
                            null &&
                        Provider.of<WatchModel>(context)
                            .polarDataList!
                            .isNotEmpty,
                    title: 'Polar',
                    imagePath: 'assets/images/sync_devices/polar.png',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: GestureDetector(
                  onTap: () {
                    isGarminSynced
                        ? alreadySyncedDialog(context, 'Garmin')
                        : webview(Tools.urlConverter('garminApi/authApi'),
                            'Garmin Connect');
                  },
                  child: SyncDeviceItem(
                    isFilled: Provider.of<WatchModel>(context).garminDataList !=
                            null &&
                        Provider.of<WatchModel>(context)
                            .garminDataList!
                            .isNotEmpty,
                    title: 'Garmin',
                    imagePath: 'assets/images/sync_devices/garmin.png',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: GestureDetector(
                  onTap: () {
                    isGarminSynced
                        ? alreadySyncedDialog(context, 'Fitbit')
                        : webview(Tools.urlConverter('fitbitApi/apiLogin'),
                            'FitBit/Activity Tracker');
                  },
                  child: SyncDeviceItem(
                    isFilled: Provider.of<WatchModel>(context).fitbitDataList !=
                            null &&
                        Provider.of<WatchModel>(context)
                            .fitbitDataList!
                            .isNotEmpty,
                    title: 'FitBit/Activity Tracker',
                    imagePath: 'assets/images/sync_devices/fitbit.png',
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              //   child: GestureDetector(
              //     onTap: () => calendarAlertDialog(context),
              //     child: Stack(
              //       children: [
              //         SyncDeviceItem(
              //           isFilled: false,
              //           title: 'Google Calendar',
              //           imagePath: 'assets/images/sync_devices/calendar.png',
              //         ),
              //         Positioned(
              //             top: 0,
              //             bottom: 0,
              //             right: 20,
              //             child: GestureDetector(
              //               onTap: () => calendarAlertDialog(context),
              //               child: Icon(
              //                 Icons.info,
              //                 size: 30,
              //                 color: Colors.black54,
              //               ),
              //             )),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ));
  }
}

class SyncDeviceItem extends StatelessWidget {
  final bool? isFilled;
  final String? title;
  final String? imagePath;

  SyncDeviceItem({this.isFilled, this.title, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 15.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: isFilled!
              ? Color.fromRGBO(8, 112, 138, 1)
              : Color.fromRGBO(86, 177, 191, 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(2, 3),
              blurRadius: 3,
              spreadRadius: 2,
            )
          ]),
      height: MediaQuery.of(context).size.height * 0.1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0)),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Image.asset(
                imagePath!,
                width: MediaQuery.of(context).size.width * 0.10,
                fit: BoxFit.fill,
              ),
            ),
            Text(
              title!,
              style: TextStyle(
                fontSize: 20,
                color: Color.fromRGBO(44, 44, 44, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
