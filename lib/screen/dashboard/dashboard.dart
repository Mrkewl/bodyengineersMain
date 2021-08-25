import 'package:bodyengineer/model/watch/watch_data.dart';
import 'package:bodyengineer/screen/dashboard/widget/goals_item.dart';
import 'package:bodyengineer/screen/widget/calendar/week_calendar_widget.dart';

import '../../../be_theme.dart';
import '../../../helper/tools_helper.dart';
import '../../../model/goal/body_goal.dart';
import '../../../model/goal/exercise_goal.dart';
import '../../../model/goal/goal_model.dart';
import '../../../model/planner/bodystatsDay.dart';
import '../../../model/planner/exercise_history.dart';
import '../../../model/planner/measurement.dart';
import '../../../model/program/exercise.dart';
import '../../../model/user/user.dart';
import '../../../model/user/user_model.dart';
import '../../../model/watch/fitbit.dart';
import '../../../model/watch/garmin.dart';
import '../../../model/watch/polar.dart';
import '../../../model/watch/watch_model.dart';
import '../../../screen/dashboard/goals/widgets/goal_progress_bar.dart';
import '../../../screen/dashboard/widget/day_item.dart';
import '../../../screen/dashboard/widget/watch_data.dart';
import '../../../screen/widget/calendar/calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../model/planner/planner_model.dart';
import '../../model/program/programDay.dart';
import '../../model/program/workout.dart';
import '../../translations.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  // CalendarController _calendarController;
  // CalendarController _calendarControllerMonth;
  TextEditingController _postponeDayController = TextEditingController();
  MyTheme theme = MyTheme();
  // CalendarController _calendarControllerMonths;
  Map<DateTime, List<Workout>> _events = {};
  late List _selectedEvents;
  AnimationController? _animationController;
  List<ProgramDay> programDayList = [];
  List<BodystatsDay?> bodystatsDayList = [];
  List<DateTime> visibleDays = [];
  List<ExerciseGoal>? exerciseGoals;
  List<Exercise> exerciseList = [];
  List<ExerciseHistoryElement> exerciseHistoryList = [];
  List<BodyGoal>? bodyGoals;
  UserObject? user;
  DateTime? rescheudle;
  DateTime _selectedDay = DateTime.now();
  DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  bool isCheckGoal = false;
  bool isCheckExerciseGoal = false;
  List<WatchDataObject>? watchDataList;

  double? bodyWeight;
  double? bodyFat;
  String measurementUnit = '';
  List<Measurement> bodyfatMeasurements = [];
  List<Measurement> bodyWeightMeasurements = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // Example holidays
  bool isSameDate(date1, date2) {
    return date2.year == date1.year &&
        date2.month == date1.month &&
        date2.day == date1.day;
  }

  void _onVisibleDaysChanged(List<DateTime> callbackVisibleDays) {
    // bulk edit //print('CALLBACK: _onVisibleDaysChanged');
    setState(() {
      visibleDays = callbackVisibleDays;
    });
  }

  showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(5),
              content: Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.52,
                child: CalendarWidget(
                    selectedDay: _selectedDay,
                    selectedDayCallback: _onDaySelected,
                    animationController: _animationController),
              ),
              actions: [
                FlatButton(
                  child: Text(
                    "Select",
                    style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    print('Dashboard Page is Created =>' + DateTime.now().second.toString());
    Future.delayed(Duration.zero, () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        measurementUnit = prefs.getInt('unit') == 1 ? 'kg' : 'lbs';
      });
    });
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  // ignore: unused_element
  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDay = day;
    });
  }

  void _onCalendarCreatedForWeeks(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated =>' + format.toString());
  }

  void quickWorkoutCallback(DateTime dateTime) {
    // bulk edit //print('Quick Workout ==>');
    // bulk edit //print(dateTime);
    String programDayId = DateTime.now().microsecondsSinceEpoch.toString();
    Provider.of<PlannerModel>(context, listen: false).addQuickWorkout(
        dateTime: dateTime,
        uid: user!.uid,
        programDayId: programDayId,
        dayName: 'Quick Workout');
    ProgramDay programDay = Provider.of<PlannerModel>(context, listen: false)
        .programDayList
        .where((element) => element.id == programDayId)
        .first;

    Navigator.pushNamed(context, '/workout_log', arguments: {
      'programDay': programDay,
    });
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  // ignore: unused_element
  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.toString()),
                  onTap: () => print('$event tapped!'),
                ),
              ))
          .toList(),
    );
  }

  changeDayCallBack(ProgramDay data, DateTime dateTime) async {
    deleteEventFromCalendar(data.dateTime);

    await Provider.of<PlannerModel>(context, listen: false)
        .changeProgramDayDate(programDay: data, newDateTime: dateTime);
    // _onVisibleDaysChanged(
    //     visibleDays.first, visibleDays.last, CalendarFormat.week);
  }

  void deleteEventFromCalendar(DateTime? dateTime) {
    _events.forEach((key, value) {
      if (isSameDate(key, dateTime)) {
        setState(() {
          value = [];
        });
      }
    });
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () => Navigator.pop(context),
    );

    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.all(15),
      actionsPadding: EdgeInsets.all(0),
      content: Text("There will be an info message withing this alert dialog"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> checkGoals(UserObject? user) async {
    print('checkGoals => ' + DateTime.now().second.toString());
    await setMeasurement();
    if (bodyfatMeasurements.isNotEmpty) {
      bodyFat = bodyfatMeasurements.last.value ?? user!.bodyFatPercentage;
    } else {
      bodyFat = user!.bodyFatPercentage;
    }
    if (bodyWeightMeasurements.isNotEmpty) {
      bodyWeight = bodyWeightMeasurements.last.value != null
          ? bodyWeightMeasurements.last.value!.toDouble()
          : user!.bodyWeightInKilo;
    } else {
      bodyWeight = user!.bodyWeightInKilo;
    }
    await Provider.of<GoalModel>(context, listen: false)
        .checkBodyGoals(bodyFat: bodyFat, bodyWeight: bodyWeight, user: user);
    isCheckGoal = true;
  }

  Future<void> setMeasurement() async {
    if (Provider.of<PlannerModel>(context, listen: true)
        .bodystatsDayList
        .isNotEmpty)
      bodyfatMeasurements = Tools.filterMeasurementFromBodystatDay(
          measurementName: 'Body Fat',
          bodystatsDayList: Provider.of<PlannerModel>(context, listen: true)
              .bodystatsDayList);
    if (Provider.of<PlannerModel>(context, listen: true)
        .bodystatsDayList
        .isNotEmpty)
      bodyWeightMeasurements = Tools.filterMeasurementFromBodystatDay(
          measurementName: 'Body Weight',
          bodystatsDayList: Provider.of<PlannerModel>(context, listen: true)
              .bodystatsDayList);
  }

  showNotification() async {
    var android = AndroidNotificationDetails('id', 'channel ', 'description',
        priority: Priority.high, importance: Importance.max);
    var iOS = IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, 'Flutter devs', 'Flutter Local Notification Demo', platform,
        payload: 'Welcome to the Local Notification demo');
  }

  Future<void> checkExerciseGoals() async {
    isCheckExerciseGoal = true;
    await Provider.of<GoalModel>(context, listen: false)
        .checkExerciseGoals(exerciseHistoryList);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context, listen: true).user;
    if (user != null && user!.unitOfMeasurementId != null)
      measurementUnit = user!.unitOfMeasurementId == 1 ? 'kg' : 'lbs';

    exerciseList =
        Provider.of<PlannerModel>(context, listen: true).allExerciseList;
    exerciseGoals = Provider.of<GoalModel>(context, listen: true)
        .exerciseGoalList
        .where((element) => !element.isCompleted!)
        .toList();
    bodyGoals = Provider.of<GoalModel>(context, listen: true)
        .bodyGoalList
        .where((element) => !element.isCompleted!)
        .toList();

    programDayList =
        Provider.of<PlannerModel>(context, listen: true).programDayList;
    bodystatsDayList =
        Provider.of<PlannerModel>(context, listen: true).bodystatsDayList;
    watchDataList =
        Provider.of<WatchModel>(context, listen: true).watchDataList;
    exerciseHistoryList =
        Provider.of<PlannerModel>(context, listen: true).exerciseHistory;

    if (!isCheckGoal && user != null) checkGoals(user);
    if (!isCheckExerciseGoal && exerciseHistoryList.isNotEmpty)
      checkExerciseGoals();
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: theme.currentTheme() == ThemeMode.dark
              ? Colors.grey[150]
              : Colors.grey[50],
          child: Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // RaisedButton(
                    //   onPressed: () => showNotification(),
                    //   child: Text('Notification'),
                    // ),
                    GestureDetector(
                        onTap: () {
                          return showCalendarDialog(context);
                        },
                        child: Icon(Icons.calendar_today)),
                    Text(
                      allTranslations.text('dashboard')!.toUpperCase(),
                      style: TextStyle(fontSize: 20),
                    ),
                    RaisedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/set_goals'),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        allTranslations.text('set_goals')!,
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Color.fromRGBO(8, 112, 138, 1),
                    )
                  ],
                ),
                Container(
                  height: 150,
                  width: double.infinity,
                  child: Center(
                      child: Container(
                          child: WeekCalendarWidget(
                    visibleDayChanged: _onVisibleDaysChanged,
                    selectedDay: _selectedDay,
                    selectedDayCallback: _onDaySelected,
                    animationController: _animationController,
                  ))),
                ),
                MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 1,
                      itemBuilder: (BuildContext ctxt, int index) {
                        List<ProgramDay> dateProgramDay = programDayList
                            .where((programDay) =>
                                isSameDate(programDay.dateTime, _selectedDay))
                            .toList();
                        List<BodystatsDay?> dateBodyStats = bodystatsDayList
                            .where((bodyDay) =>
                                isSameDate(bodyDay!.dateTime, _selectedDay))
                            .toList();
                        return DashboardDayItem(
                          changeDayCallBack: changeDayCallBack,
                          programDay: dateProgramDay,
                          dateBodyStats: dateBodyStats,
                          quickWorkoutCallback: quickWorkoutCallback,
                          dateTime: _selectedDay,
                        );
                      }),
                ),
                Container(
                    padding: EdgeInsets.all(15),
                    margin: EdgeInsets.symmetric(vertical: 15),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: theme.currentTheme() == ThemeMode.dark
                          ? Colors.blueGrey
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 3,
                          spreadRadius: 1,
                          offset: Offset(1, 2),
                          color: Color(0xffd6d6d6),
                        )
                      ],
                    ),
                    child: watchDataList == null
                        ? GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/sync_devices'),
                            child: Container(
                              decoration: BoxDecoration(),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      allTranslations
                                          .text('today')!
                                          .toUpperCase(),
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 50),
                                      alignment: Alignment.center,
                                      child: Text(
                                        allTranslations
                                            .text('connect_devices')!,
                                        style: TextStyle(
                                          fontSize: 25,
                                          color: theme.currentTheme() ==
                                                  ThemeMode.dark
                                              ? Colors.blue[200]
                                              : Colors.blue,
                                        ),
                                      ),
                                    )
                                  ]),
                            ),
                          )
                        : WatchData(
                            watchDataList: watchDataList,
                            dateTime: DateTime(_selectedDay.year,
                                _selectedDay.month, _selectedDay.day),
                          )),
                Container(
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: theme.currentTheme() == ThemeMode.dark
                        ? Colors.blueGrey
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 3,
                          spreadRadius: 1,
                          offset: Offset(1, 2),
                          color: Color(0xffd6d6d6))
                    ],
                  ),
                  child: exerciseGoals == null && bodyGoals == null
                      ? GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/set_goals'),
                          child: Container(
                            decoration: BoxDecoration(),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    allTranslations.text('current_goals')!,
                                    style: TextStyle(fontSize: 17),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(50),
                                    alignment: Alignment.center,
                                    child: Text(
                                      allTranslations.text('set_goals')!,
                                      style: TextStyle(
                                        fontSize: 30,
                                        color: theme.currentTheme() ==
                                                ThemeMode.dark
                                            ? Colors.blue[200]
                                            : Colors.blue,
                                      ),
                                    ),
                                  )
                                ]),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              allTranslations.text('current_goals')!,
                              style: TextStyle(fontSize: 17),
                            ),
                            SizedBox(height: 3),
                            // if (bodyFat != null && bodyWeight != null)
                            ListView.builder(
                                itemCount: bodyGoals!.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  if (bodyGoals![index].name == 'Body Fat' &&
                                          bodyFat != null ||
                                      bodyGoals![index].name == 'Body Weight' &&
                                          bodyWeight != null) {
                                    double val =
                                        bodyGoals![index].name == 'Body Fat'
                                            ? bodyFat!.toDouble()
                                            : bodyWeight!.toDouble();
                                    return GoalsItem(
                                        bodyGoals![index], val, true);
                                  }
                                  return Container();
                                }),
                            SizedBox(height: 3),
                            if (exerciseList.isNotEmpty &&
                                exerciseGoals != null)
                              ListView.builder(
                                  itemCount: exerciseGoals!.length,
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    Exercise exercise = exerciseList
                                        .where((element) =>
                                            element.exerciseId ==
                                            exerciseGoals![index].exerciseId)
                                        .first;
                                    List<ExerciseHistoryElement>
                                        exerciseHistoryListFiltered =
                                        exerciseHistoryList
                                            .where((element) =>
                                                element.exerciseId.toString() ==
                                                exerciseGoals![index]
                                                    .exerciseId)
                                            .toList();

                                    ExerciseHistoryElement?
                                        exerciseHistoryElement =
                                        exerciseHistoryListFiltered.isNotEmpty
                                            ? exerciseHistoryListFiltered
                                                .reduce((a, b) => a.weight! >
                                                            b.weight! ||
                                                        a.rep! > b.rep!
                                                    ? a
                                                    : b)
                                            : null;
                                    return Container(
                                        margin:
                                            EdgeInsets.symmetric(vertical: 10),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: theme.currentTheme() ==
                                                  ThemeMode.dark
                                              ? Colors.grey[700]
                                              : Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 3,
                                              spreadRadius: 1,
                                              offset: Offset(1, 2),
                                              color: Color(0xffd6d6d6),
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(exercise.exerciseName!),
                                                Text(exerciseGoals![index]
                                                        .kg
                                                        .toString() +
                                                    ' ' +
                                                    measurementUnit +
                                                    ' / ' +
                                                    exerciseGoals![index]
                                                        .rep
                                                        .toString() +
                                                    ' Reps'),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  allTranslations.text(
                                                      'highest_progress')!,
                                                ),
                                                Text(exerciseHistoryList
                                                        .where((element) =>
                                                            element.exerciseId
                                                                .toString() ==
                                                            exerciseGoals![
                                                                    index]
                                                                .exerciseId)
                                                        .isNotEmpty
                                                    ? exerciseHistoryElement!
                                                            .weight
                                                            .toString() +
                                                        ' ' +
                                                        measurementUnit +
                                                        ' / ' +
                                                        exerciseHistoryElement
                                                            .rep
                                                            .toString() +
                                                        ' Reps'
                                                    : ''),
                                              ],
                                            ),
                                          ],
                                        ));

                                    // : Container(
                                    //   child: Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text(exercise.exerciseName),
                                    //     Column(
                                    //       crossAxisAlignment:
                                    //           CrossAxisAlignment.end,
                                    //       children: [
                                    //         Row(
                                    //           children: [
                                    //             if (exerciseHistoryList
                                    //                 .where((element) =>
                                    //                     element.exerciseId
                                    //                         .toString() ==
                                    //                     exerciseGoals[
                                    //                             index]
                                    //                         .exerciseId)
                                    //                 .isNotEmpty)
                                    //               Text(exerciseHistoryList
                                    //                   .where((element) =>
                                    //                       element
                                    //                           .exerciseId
                                    //                           .toString() ==
                                    //                       exerciseGoals[
                                    //                               index]
                                    //                           .exerciseId)
                                    //                   .first
                                    //                   .weight
                                    //                   .toString()),
                                    //             Text(' / ' +
                                    //                 exerciseGoals[index]
                                    //                     .kg
                                    //                     .toString()),
                                    //           ],
                                    //         ),
                                    //         Container(
                                    //           height: 20,
                                    //           width:
                                    //               MediaQuery.of(context)
                                    //                       .size
                                    //                       .width *
                                    //                   0.4,
                                    //           child: GoalProgressBarWidget(
                                    //               data1: exerciseHistoryList
                                    //                       .where((element) =>
                                    //                           element
                                    //                               .exerciseId
                                    //                               .toString() ==
                                    //                           exerciseGoals[
                                    //                                   index]
                                    //                               .exerciseId)
                                    //                       .isNotEmpty
                                    //                   ? exerciseHistoryList
                                    //                       .where((element) =>
                                    //                           element
                                    //                               .exerciseId
                                    //                               .toString() ==
                                    //                           exerciseGoals[
                                    //                                   index]
                                    //                               .exerciseId)
                                    //                       .first
                                    //                       .weight
                                    //                   : 1,
                                    //               data2:
                                    //                   exerciseGoals[index]
                                    //                       .kg),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ],
                                    // ));
                                  }),
                          ],
                        ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
