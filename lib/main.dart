import '../model/achievement/achievement_model.dart';
import '../model/goal/goal_model.dart';
import '../model/settings/settings_model.dart';
import '../model/watch/watch_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:feature_discovery/feature_discovery.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:paulonia_cache_image/paulonia_cache_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'translations.dart';
import 'route.dart';
import './config.dart';
import './model/planner/planner_model.dart';
import './model/program/program_model.dart';
import './model/user/user_model.dart';
import './model/tutorial/tutorial_model.dart';

late bool isFirstSeen;
late bool isLoggedin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PCacheImage.init();

  await Firebase.initializeApp();
  if (FirebaseAuth.instance.currentUser != null) {
    // signed in
    isLoggedin = true;
    // bulk edit //print(FirebaseAuth.instance.currentUser);
    // bulk edit //print(FirebaseAuth.instance.currentUser.uid);
    // bulk edit //print('Sign In');
  } else {
    // bulk edit //print('Not Auth');
    isLoggedin = false;
  }
  // if (Platform.isAndroid) {
  //   SharedPreferences.setMockInitialValues({});
  // }
  // alt kısımda ilk ekran kontrolü yapılıyor
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isFirstSeen = prefs.getBool('seen') ?? true;
  // isLoggedin = prefs.getBool('loggedIn') ?? false;

  await prefs.setBool('seen', false);
  await allTranslations.init(); // çeviri için lazım
  // String _sysLng = ui.window.locale.languageCode;
  // debugPrint('SİSTEM LANGUAGE ==========>' + _sysLng);
  // String newLang = _sysLng == 'de' ? 'de' : 'en';
  String prefLanguage = await allTranslations.getPreferredLanguage();
  allTranslations.setNewLanguage(
      prefLanguage != null && prefLanguage != '' ? prefLanguage : 'en');
  runApp(
    MyApplication(),
  );
}

class MyApplication extends StatefulWidget {
  @override
  _MyApplicationState createState() => _MyApplicationState();
}

class _MyApplicationState extends State<MyApplication> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future onSelectNotification(String? payload) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return NewScreen(
        payload: payload,
      );
    }));
  }

  @override
  void initState() {
    allTranslations.onLocaleChangedCallback = _onLocaleChanged;
    currentTheme.addListener(() {
      // bulk edit //print('Changes');
      setState(() {});
    });
    super.initState();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOs = IOSInitializationSettings();
    var initSetttings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  _onLocaleChanged() async {
    // bulk edit //print('Language has been changed to: ${allTranslations.currentLanguage}');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserModel(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsModel(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => PlannerModel(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => ProgramModel(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => WatchModel(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => AchievementModel(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => GoalModel(),
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => TutorialModel(),
          lazy: false,
        ),
      ],
      child: FeatureDiscovery(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return ScrollConfiguration(behavior: MyBehavior(), child: child!);
          },
          theme: ThemeData.light(
                  // primaryColor: Color.fromRGBO(86, 177, 191, 1),
                  // accentColor: Color.fromRGBO(8, 112, 138, 1),
          
                  )
              .copyWith(
            primaryColor: Color.fromRGBO(8, 112, 138, 1),
            accentColor: Color.fromRGBO(86, 177, 191, 1),
            textTheme: ThemeData.dark().textTheme.apply(
                  fontFamily: 'Lato',
                  bodyColor: Color.fromRGBO(44, 44, 44, 1),
                ),
            primaryTextTheme: ThemeData.dark().textTheme.apply(
                  fontFamily: 'Lato',
                  bodyColor: Color.fromRGBO(44, 44, 44, 1),
                ),
            accentTextTheme: ThemeData.dark().textTheme.apply(
                  fontFamily: 'Staatliches',
                  bodyColor: Color.fromRGBO(44, 44, 44, 1),
                ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Color.fromRGBO(8, 112, 138, 1),
            accentColor: Color.fromRGBO(86, 177, 191, 1),
            textTheme: ThemeData.dark().textTheme.apply(
                  fontFamily: 'Lato',
                  bodyColor: Color.fromRGBO(255, 255, 255, 1),
                ),
            primaryTextTheme: ThemeData.dark().textTheme.apply(
                  fontFamily: 'Lato',
                  bodyColor: Color.fromRGBO(255, 255, 255, 1),
                ),
            accentTextTheme: ThemeData.dark().textTheme.apply(
                  fontFamily: 'Staatliches',
                  bodyColor: Color.fromRGBO(255, 255, 255, 1),
                ),
          ),
          themeMode: currentTheme.currentTheme(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Tells the system which are the supported languages
          supportedLocales: allTranslations.supportedLocales(),
          // initialRoute: '/design',
          // home:  DesignRouter(),
          initialRoute: isFirstSeen
              ? "/opening"
              : !isLoggedin
                  ? "/welcome"
                  : "/splash_screen",
          routes: Routes.getAll(),
        ),
      ),
    );
  }
}

class NewScreen extends StatelessWidget {
  String? payload;

  NewScreen({
    required this.payload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(payload!),
      ),
    );
  }
}

// To Remove SingleChildScrollView Glow Effect //
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
