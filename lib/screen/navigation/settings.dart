import '../../model/goal/goal_model.dart';
import '../../model/planner/planner_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  UserObject? user;
  GlobalKey<ScaffoldState> _key = GlobalKey();
  late SharedPreferences prefs;
  bool sendWorkoutReminder = true;
  bool sendPushNotification = true;
  String? _languageValue = allTranslations.currentLanguage;
  int? _unitValue;
  int _sleepValue = 1;
  int? _alarmValue = 1;
  bool isDark = false;
  int? prefsUnit;

  changeLanguage(languageKey) async {
    await allTranslations.setNewLanguage(languageKey, true);
    await allTranslations.init();
    setState(() {
      allTranslations = allTranslations;
    });
  }

  deleteAllLocalData() async {
    await Provider.of<UserModel>(context, listen: false).deleteAllLocalData();
    await Provider.of<GoalModel>(context, listen: false).deleteGoals();
    await Provider.of<PlannerModel>(context, listen: false).deletePlannerData();

    Navigator.pop(context);
  }

  showFactoryResetAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Factory Reset',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 15),
              Text(
                  "If you click on the accept button whole local data (programs,exercises,bodystats etc.) will be deleted! However, the data host by our servers, continue to using for training our AI. If you don't want to it please contact us via email.")
            ]),
        buttonPadding: EdgeInsets.symmetric(horizontal: 30),
        actions: [
          GestureDetector(
              onTap: () => Navigator.pop(context), child: Text('Cancel')),
          GestureDetector(
              onTap: () => deleteAllLocalData(), child: Text('Accept'))
        ],
      ),
    );
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      user = Provider.of<UserModel>(context, listen: false).user;
      sendPushNotification = await Permission.notification.isGranted;
      prefs = await SharedPreferences.getInstance();
      setState(() {
        isDark = prefs.getBool('isDark') ?? false;
        _unitValue = prefs.getInt('unit') ?? user!.unitOfMeasurementId ?? 1;
        _alarmValue = prefs.getInt('alarmUnit') ?? 1;
        // bulk edit //print("prefs.getInt('unit') ==>" + prefsUnit.toString());
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawer: buildProfileDrawer(context, user),
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    allTranslations.text('notifications')!,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          allTranslations.text('workout_reminder')!,
                          style: TextStyle(fontSize: 17),
                        ),
                        CupertinoSwitch(
                          value: sendWorkoutReminder,
                          onChanged: (value) {
                            setState(() {
                              sendWorkoutReminder = value;
                            });
                          },
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          allTranslations.text('push_notification')!,
                          style: TextStyle(fontSize: 17),
                        ),
                        CupertinoSwitch(
                          value: sendPushNotification,
                          onChanged: (value) async {
                            setState(() {
                              sendPushNotification = value;
                            });
                            await Permission.notification
                                .request()
                                .then((value) async {
                              if (value.isGranted) {
                                setState(() {
                                  sendPushNotification = true;
                                });
                              } else {
                                setState(() {
                                  sendPushNotification = false;
                                });
                              }
                            });
                          },
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    allTranslations.text('general_settings')!,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Material(
                      shadowColor: Color(0xffd6d6d6),
                      elevation: 5,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              allTranslations.text('language_settings')!,
                              style: TextStyle(fontSize: 17),
                            ),
                            SizedBox(
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                    value: _languageValue,
                                    items: [
                                      DropdownMenuItem(
                                        child: Text("English"),
                                        value: 'en',
                                      ),
                                      DropdownMenuItem(
                                        child: Text("Türkçe"),
                                        value: 'tr',
                                      ),
                                    ],
                                    onChanged: (dynamic value) async {
                                      changeLanguage(value);
                                      setState(() {
                                        _languageValue = value;
                                      });
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Material(
                      shadowColor: Color(0xffd6d6d6),
                      elevation: 5,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              allTranslations.text('rest_timer_alarm')!,
                              style: TextStyle(fontSize: 17),
                            ),
                            Container(
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.4,
                              alignment: Alignment.centerRight,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                    value: _alarmValue,
                                    items: [
                                      DropdownMenuItem(
                                        child: Text(
                                          "Audio + Vibration",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        value: 1,
                                      ),
                                      DropdownMenuItem(
                                        child: Text(
                                          "Vibration",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        value: 2,
                                      ),
                                      DropdownMenuItem(
                                        child: Text(
                                          "Silent",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        value: 3,
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _alarmValue = value;
                                        // bulk edit //print(_alarmValue);
                                        prefs.setInt('alarmUnit', value!);
                                      });
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Material(
                      shadowColor: Color(0xffd6d6d6),
                      elevation: 5,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              allTranslations.text('unit_system')!,
                              style: TextStyle(fontSize: 17),
                            ),
                            SizedBox(
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton(
                                    value: user == null
                                        ? 1
                                        : user!.unitOfMeasurementId,
                                    items: [
                                      DropdownMenuItem(
                                        child: Text(
                                          "cm/kg",
                                          style: TextStyle(
                                            color: isDark == false
                                                ? Color.fromRGBO(44, 44, 44, 1)
                                                : Colors.white,
                                          ),
                                        ),
                                        value: 1,
                                      ),
                                      DropdownMenuItem(
                                        child: Text(
                                          "ft/in/ibs",
                                          style: TextStyle(
                                            color: isDark == false
                                                ? Color.fromRGBO(44, 44, 44, 1)
                                                : Colors.white,
                                          ),
                                        ),
                                        value: 2,
                                      ),
                                    ],
                                    onChanged: (dynamic value) async {
                                      setState(() {
                                        _unitValue = value;
                                        user!.changeUnitOfMeasurement(value);
                                      });
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Text(
                  //   'Power Savings Settings',
                  //   style: TextStyle(
                  //     fontSize: 17,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //       horizontal: 10, vertical: 10),
                  //   child: Material(
                  //     elevation: 10,
                  //     borderRadius: BorderRadius.all(Radius.circular(7)),
                  //     child: Container(
                  //       padding: EdgeInsets.all(10),
                  //       child: Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //         children: [
                  //           Text(
                  //             'Auto Sleeps',
                  //             style: TextStyle(fontSize: 17),
                  //           ),
                  //           SizedBox(
                  //             height: 50,
                  //             width: MediaQuery.of(context).size.width * 0.25,
                  //             child: DropdownButtonHideUnderline(
                  //               child: DropdownButton(
                  //                   value: _sleepValue,
                  //                   items: [
                  //                     DropdownMenuItem(
                  //                       child: Text("1 min"),
                  //                       value: 1,
                  //                     ),
                  //                     DropdownMenuItem(
                  //                       child: Text("5 mins"),
                  //                       value: 2,
                  //                     ),
                  //                     DropdownMenuItem(
                  //                       child: Text("10 mins"),
                  //                       value: 3,
                  //                     ),
                  //                     DropdownMenuItem(
                  //                       child: Text("30 mins"),
                  //                       value: 4,
                  //                     ),
                  //                   ],
                  //                   onChanged: (value) {
                  //                     setState(() {
                  //                       _sleepValue = value;
                  //                     });
                  //                   }),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // GestureDetector(
                  //   onTap: () {
                  //     currentTheme.switchTheme();
                  //     setState(() {
                  //       isDark = !isDark;
                  //     });
                  //   },
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(
                  //         horizontal: 10, vertical: 10),
                  //     child: Material(
                  //       elevation: 10,
                  //       borderRadius: BorderRadius.all(Radius.circular(7)),
                  //       child: Container(
                  //         padding: EdgeInsets.all(10),
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //           children: [
                  //             Text(
                  //               'Dark Mode',
                  //               style: TextStyle(fontSize: 17),
                  //             ),
                  //             Text(
                  //               isDark ? 'On' : 'Off',
                  //               style: TextStyle(fontSize: 17),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: 20),
                  Text(
                    allTranslations.text('credits')!,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SettingsPageCards(
                    title: 'view',
                    value: '',
                  ),
                  SizedBox(height: 20),
                  Text(
                    allTranslations.text('reset')!,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: showFactoryResetAlert,
                    child: SettingsPageCards(
                      title: 'factory_reset',
                      value: '',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    allTranslations.text('licenses')!,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SettingsPageCards(
                    title: 'view',
                    value: '',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class SettingsPageCards extends StatefulWidget {
  String? title;
  String? value;
  SettingsPageCards({this.title, this.value});
  @override
  _SettingsPageCardsState createState() =>
      _SettingsPageCardsState(title: title, value: value);
}

class _SettingsPageCardsState extends State<SettingsPageCards> {
  String? title;
  String? value;
  _SettingsPageCardsState({this.title, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Material(
        shadowColor: Color(0xffd6d6d6),
        elevation: 5,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                allTranslations.text('$title')!,
                style: TextStyle(fontSize: 17),
              ),
              Text(
                value!,
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
