import 'dart:async';
import 'dart:io';

import 'package:bodyengineer/model/program/program.dart';
import 'package:feature_discovery/feature_discovery.dart';

import '../../model/planner/planner_model.dart';
import '../../screen/dashboard/dashboard.dart';
import '../../screen/workout/workout_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common_appbar_for_navigation.dart';
import '../common_drawer.dart';
import '../bodystats/bs_menu.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../model/program/programDay.dart';
import '../program_library/program_library.dart';
import '../planner/planner.dart';
import '../../screen/program_library/program_library_categories.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  late SharedPreferences prefs;
  bool isDark = false;
  bool isChecked = false;
  bool subscribeWarning = false;
  bool changeDayByArguments = false;
  Program? userProgram;
  List<ProgramDay>? programDayList;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  StreamSubscription? iosSubscription;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FeatureDiscovery.discoverFeatures(
          context,
          <String>['feature1', 'feature2', 'feature3', 'feature4', 'feature5']
              .toSet());
    });

    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      setState(() {
        isDark = prefs.getBool('isDark') ?? false;
      });
    });

    // Future.delayed(Duration(seconds: 4), () async {
    //   if (!isChecked && !subscribeWarning && userProgram == null) {
    //     subscribeProgramPopup(context);
    //   }
    // });

    if (Platform.isIOS) {
      ///** BEFORE NULL SAFETY */

      // iosSubscription =
      //     firebaseMessaging.onIosSettingsRegistered.listen((data) {
      //   // save the token  OR subscribe to a topic here
      // });
      ///** BEFORE NULL SAFETY */

      firebaseMessaging.requestPermission();
      // .requestNotificationPermissions(IosNotificationSettings());
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // print('A new onMessageOpenedApp event was published!');
      // Navigator.pushNamed(context, '/message',
      //     arguments: MessageArguments(message, true));
    });

    ///** BEFORE NULL SAFETY */
    // firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     // bulk edit //print("onMessage: $message");
    //     showDialog(
    //       context: context,
    //       builder: (context) => AlertDialog(
    //         content: ListTile(
    //           title: Text(message['notification']['title']),
    //           subtitle: Text(message['notification']['body']),
    //         ),
    //       ),
    //     );
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     // bulk edit //print("onLaunch: $message");
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     // bulk edit //print("onResume: $message");
    //   },
    // );
    ///** BEFORE NULL SAFETY */

    super.initState();
  }

  int? _index = 0;

  final List<Widget> _pages = [
    // Feed(),
    DashboardScreen(),
    Planner(),
    ProgramLibrary(),
    WorkoutList(),
    ProgramLibraryCategories(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _index = index;
    });
  }

  void pushToBottomNavigationFeatureDiscovery() {
    setState(() {
      _index = 1;
    });
  }

  void pushToNextBottomNavigationFeature() {
    setState(() {
      _index = _index! + 1;
    });
  }

  void pushToNextBottomNavigationFeaturetoZero() {
    setState(() {
      _index = 0;
    });
  }

  // Future<bool> _onWillPop() {
  //   return showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: Text('Are you sure?'),
  //           content: Text('Do you want to exit?'),
  //           actions: <Widget>[
  //             FlatButton(
  //               onPressed: () => Navigator.of(context).pop(false),
  //               child: Text('No'),
  //             ),
  //             FlatButton(
  //               onPressed: () =>
  //                   SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
  //               child: Text('Yes'),
  //             ),
  //           ],
  //         ),
  //       ) ??
  //       false;
  // }

  @override
  Widget build(BuildContext context) {
    userProgram =
        Provider.of<PlannerModel>(context, listen: true).plannerMainProgram;
    programDayList =
        Provider.of<PlannerModel>(context, listen: true).programDayList;
    isChecked = Provider.of<PlannerModel>(context, listen: true).isChecked;
    subscribeWarning =
        Provider.of<PlannerModel>(context, listen: true).subscribeWarning;
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      if (!changeDayByArguments && args['index'] != null) {
        setState(() {
          _index = args['index'];
          changeDayByArguments = true;
        });
      }
    }

    return WillPopScope(
      onWillPop: () async {
        if (_key.currentState!.isDrawerOpen) {
          Navigator.of(context).pop();
          return false;
        }
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () =>
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop'),
                child: Text('Yes'),
              ),
            ],
          ),
        ) as FutureOr<bool>;
      } as Future<bool> Function()?,
      child: Scaffold(
        key: _key,
        drawer: buildProfileDrawer(context, user),
        appBar: setAppBarforNavigationPage(
                _key, pushToBottomNavigationFeatureDiscovery)
            as PreferredSizeWidget?,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromRGBO(44, 44, 44, 1),
          child: Icon(
            Icons.edit,
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => BodyStatsMenu())),
        ),
        body: Center(
          child: (_pages[_index!]),
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _index! > 3 ? 2 : _index!,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              label: '1',
              icon: DescribedFeatureOverlay(
                onComplete: () async {
                  pushToNextBottomNavigationFeature();
                  return true;
                },
                enablePulsingAnimation: true,
                contentLocation: ContentLocation.above,
                featureId: 'feature2',
                openDuration: Duration(seconds: 1),
                tapTarget: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SvgPicture.asset(
                    'assets/images/navbar/dashboard.svg',
                    color: Color.fromRGBO(8, 112, 138, 1),
                  ),
                ),
                title: Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 24),
                ),
                description: Text(
                  '''
                  This is the dashboard where you are 
                  able to see your todo,
                  entry for today,
                  watch tracked health stats summary
                  and goals
                  ''',
                  style: TextStyle(fontFamily: 'Lato', fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                targetColor: Colors.white,
                textColor: Colors.white,
                child: Container(
                  height: 30,
                  width: 30,
                  child: SvgPicture.asset(
                    'assets/images/navbar/dashboard.svg',
                    color: Color.fromRGBO(182, 182, 182, 1),
                  ),
                ),
              ),
              activeIcon: Container(
                height: 30,
                width: 30,
                child: SvgPicture.asset(
                  'assets/images/navbar/dashboard.svg',
                  color: Color.fromRGBO(8, 112, 138, 1),
                ),
              ),
              // ignore: deprecated_member_use
              // title: Column(
              //   children: [
              //     Text(
              //       allTranslations.text('dashboard')!,
              //       style: TextStyle(
              //         color: _index == 0
              //             ? !isDark
              //                 ? Color.fromRGBO(8, 112, 138, 1)
              //                 : Colors.white
              //             : Color.fromRGBO(182, 182, 182, 1),
              //         fontSize: 12,
              //       ),
              //     ),
              //     Visibility(
              //       visible: _index == 0,
              //       child: Container(
              //           margin: EdgeInsets.only(top: 2),
              //           height: 3,
              //           width: MediaQuery.of(context).size.width * 0.12,
              //           color: Color.fromRGBO(8, 112, 138, 1)),
              //     ),
              //   ],
              // ),
            ),
            BottomNavigationBarItem(
              label: '2',
              icon: DescribedFeatureOverlay(
                onComplete: () async {
                  pushToNextBottomNavigationFeature();
                  return true;
                },
                enablePulsingAnimation: true,
                contentLocation: ContentLocation.above,
                featureId: 'feature3',
                tapTarget: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SvgPicture.asset(
                    'assets/images/navbar/planner.svg',
                    color: Color.fromRGBO(8, 112, 138, 1),
                  ),
                ),
                title: Text(
                  'Planner',
                  style: TextStyle(fontSize: 24),
                ),
                description: Text('''
                  This is where you can view all the exercises
                  that has been planned in your calendar. You can also add 
                  quick workout if you don't have a plan yet or want to add additional workouts.
                  You can also add bodyweight, bodyfat percentage, and other body stats here''',
                    style: TextStyle(fontFamily: 'Lato', fontSize: 16),
                    textAlign: TextAlign.left),
                backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                targetColor: Colors.white,
                textColor: Colors.white,
                child: Container(
                  height: 30,
                  width: 30,
                  child: SvgPicture.asset(
                    'assets/images/navbar/planner.svg',
                    color: Color.fromRGBO(182, 182, 182, 1),
                  ),
                ),
              ),
              activeIcon: Container(
                height: 30,
                width: 30,
                child: SvgPicture.asset(
                  'assets/images/navbar/planner.svg',
                  color: Color.fromRGBO(8, 112, 138, 1),
                ),
              ),
              // ignore: deprecated_member_use
              // title: Column(
              //   children: [
              //     Text(
              //       allTranslations.text('planner')!,
              //       style: TextStyle(
              //         color: _index == 1
              //             ? !isDark
              //                 ? Color.fromRGBO(8, 112, 138, 1)
              //                 : Colors.white
              //             : Color.fromRGBO(182, 182, 182, 1),
              //         fontSize: 12,
              //       ),
              //     ),
              //     Visibility(
              //       visible: _index == 1,
              //       child: Container(
              //           margin: EdgeInsets.only(top: 2),
              //           height: 3,
              //           width: MediaQuery.of(context).size.width * 0.12,
              //           color: Color.fromRGBO(8, 112, 138, 1)),
              //     ),
              //   ],
              // ),
            ),
            BottomNavigationBarItem(
              label: '3',
              icon: DescribedFeatureOverlay(
                onComplete: () async {
                  pushToNextBottomNavigationFeaturetoZero();
                  return true;
                },
                enablePulsingAnimation: true,
                contentLocation: ContentLocation.above,
                featureId: 'feature4',
                tapTarget: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SvgPicture.asset(
                    'assets/images/navbar/program_library.svg',
                    color: Color.fromRGBO(8, 112, 138, 1),
                  ),
                ),
                title: Text(
                  'Program Library',
                  style: TextStyle(fontSize: 24),
                ),
                description: Text('''
                This is where you will be able to pick pre-made programs in the library or create your own program''',
                    style: TextStyle(fontFamily: 'Lato', fontSize: 16),
                    textAlign: TextAlign.left),
                backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                targetColor: Colors.white,
                textColor: Colors.white,
                child: Container(
                  height: 30,
                  width: 30,
                  child: SvgPicture.asset(
                    'assets/images/navbar/program_library.svg',
                    color: Color.fromRGBO(182, 182, 182, 1),
                  ),
                ),
              ),
              activeIcon: Container(
                height: 30,
                width: 30,
                child: SvgPicture.asset(
                  'assets/images/navbar/program_library.svg',
                  color: Color.fromRGBO(8, 112, 138, 1),
                ),
              ),
              // ignore: deprecated_member_use
              // title: Column(
              //   children: [
              //     Text(
              //       allTranslations.text('library')!,
              //       style: TextStyle(
              //         color: _index == 2
              //             ? !isDark
              //                 ? Color.fromRGBO(8, 112, 138, 1)
              //                 : Colors.white
              //             : Color.fromRGBO(182, 182, 182, 1),
              //         fontSize: 12,
              //       ),
              //     ),
              //     Visibility(
              //       visible: _index == 2,
              //       child: Container(
              //           margin: EdgeInsets.only(top: 2),
              //           height: 3,
              //           width: MediaQuery.of(context).size.width * 0.12,
              //           color: Color.fromRGBO(8, 112, 138, 1)),
              //     ),
              //   ],
              // ),
            ),
            BottomNavigationBarItem(
              label: '4',
              icon: DescribedFeatureOverlay(
                onComplete: () async {
                  pushToNextBottomNavigationFeature();
                  pushToNextBottomNavigationFeaturetoZero();
                  return true;
                },
                enablePulsingAnimation: true,
                contentLocation: ContentLocation.above,
                featureId: 'feature5',
                tapTarget: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SvgPicture.asset(
                    'assets/images/navbar/workout_page.svg',
                    color: Color.fromRGBO(8, 112, 138, 1),
                  ),
                ),
                title: Text(
                  'Workout Management Page',
                  style: TextStyle(fontSize: 24),
                ),
                description: Text(
                  '''This is where you would be managing
                   your workout plan''',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontFamily: 'Lato', fontSize: 16),
                ),
                backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                targetColor: Colors.white,
                textColor: Colors.white,
                child: Container(
                  height: 30,
                  width: 30,
                  child: SvgPicture.asset(
                    'assets/images/navbar/workout_page.svg',
                    color: Color.fromRGBO(182, 182, 182, 1),
                  ),
                ),
              ),
              activeIcon: Container(
                height: 30,
                width: 30,
                child: SvgPicture.asset(
                  'assets/images/navbar/workout_page.svg',
                  color: Color.fromRGBO(8, 112, 138, 1),
                ),
              ),
              // ignore: deprecated_member_use
              // title: Column(
              //   children: [
              //     Text(
              //       allTranslations.text('workout')!,
              //       style: TextStyle(
              //         color: _index == 3
              //             ? !isDark
              //                 ? Color.fromRGBO(8, 112, 138, 1)
              //                 : Colors.white
              //             : Color.fromRGBO(182, 182, 182, 1),
              //         fontSize: 12,
              //       ),
              //     ),
              //     Visibility(
              //       visible: _index == 3,
              //       child: Container(
              //           margin: EdgeInsets.only(top: 2),
              //           height: 3,
              //           width: MediaQuery.of(context).size.width * 0.12,
              //           color: Color.fromRGBO(8, 112, 138, 1)),
              //     ),
              //   ],
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
