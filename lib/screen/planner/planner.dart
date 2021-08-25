import 'package:bodyengineer/screen/widget/calendar/week_calendar_widget.dart';

import '../../model/achievement/achievement.dart';
import '../../model/achievement/achievement_model.dart';
import '../../model/planner/bodystatsDay.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../screen/widget/achievement_modal_content.dart';
import '../../screen/widget/calendar/calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../translations.dart';
import './widget/planner_day_item.dart';
import '../../model/planner/planner_model.dart';
import '../../model/program/programDay.dart';
import '../../model/program/workout.dart';

class Planner extends StatefulWidget {
  @override
  _PlannerState createState() => _PlannerState();
}

class _PlannerState extends State<Planner> with TickerProviderStateMixin {
  TextEditingController _postponeDayController = TextEditingController();
  DateTime? startDay;
  DateTime selectedDay = DateTime.now();
  Map<DateTime, List<Workout>> _events = {};
  late List _selectedEvents;
  AnimationController? _animationController;
  List<ProgramDay> programDayList = [];
  List<BodystatsDay?> bodystatsDayList = [];
  List<DateTime> visibleDays = [];
  UserObject? user;
  DateTime? rescheudle;
  // Example holidays
  bool isSameDate(date1, date2) {
    return date2.year == date1.year &&
        date2.month == date1.month &&
        date2.day == date1.day;
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
                height: 375,
                child: CalendarWidget(
                  selectedDay: selectedDay,
                  selectedDayCallback: _onDaySelected,
                  animationController: _animationController,
                  selectWholeWeek: true,
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    allTranslations.text('select')!,
                    style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
                  ),
                  onPressed: () => Navigator.pop(context),
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
    print('Planner Page is Created =>' + DateTime.now().second.toString());

    super.initState();

    // _calendarController = CalendarController();
    // _calendarControllerMonth = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    for (var i = 0; i < 7; i++) {
      if (DateTime.now().subtract(Duration(days: i)).weekday == 1) {
        startDay = DateTime.now().subtract(Duration(days: i));
      }
    }

    _animationController!.forward();
    DateTime last = startDay!.add(Duration(days: 7));
    for (var i = 0; i < 7; i++) {
      visibleDays.add(startDay!.add(Duration(days: i)));
    }
    setState(() {
      visibleDays = visibleDays;
    });
  }

  @override
  void dispose() {
    _animationController!.dispose();

    super.dispose();
  }

  // ignore: unused_element
  void _onDaySelected(DateTime day) {
    // bulk edit //print('CALLBACK: _onDaySelected');
    setState(() {
      selectedDay = day;
      startDay = selectedDay.weekday != 1
          ? selectedDay.subtract(Duration(days: (7 - selectedDay.weekday)))
          : selectedDay;

      visibleDays = [];
      DateTime? start;
      for (var i = 0; i < 7; i++) {
        if (selectedDay.subtract(Duration(days: i)).weekday == 1) {
          start = selectedDay.subtract(Duration(days: i));
        }
      }

      for (var i = 0; i < 7; i++) {
        visibleDays.add(start!.add(Duration(days: i)));
      }

      setState(() {
        visibleDays = visibleDays;
      });
    });
  }

  void _onVisibleDaysChanged(List<DateTime> callbackVisibleDays) {
    // bulk edit //print('CALLBACK: _onVisibleDaysChanged');
    setState(() {
      visibleDays = callbackVisibleDays;
    });
  }

  rescheduleDayCallback(DateTime date) {
    setState(() {
      rescheudle = date;
    });
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

    Navigator.pushNamed(context, '/workout_log',
        arguments: {'programDay': programDay, 'index': 1});
  }

  rescheduleCalendarDialog(BuildContext context, ProgramDay programDay) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(5),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Please select a day to reschedule.'),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.47,
                    child: CalendarWidget(
                      selectedDay: rescheudle,
                      selectedDayCallback: rescheduleDayCallback,
                      animationController: _animationController,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text(
                    "Reschedule",
                    style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
                  ),
                  onPressed: () {
                    if (rescheudle != null) {
                      // bulk edit //print(rescheudle);
                      // bulk edit //print(programDay);
                      Provider.of<PlannerModel>(context, listen: false)
                          .changeProgramDayDate(
                              newDateTime: rescheudle, programDay: programDay);
                      // _onVisibleDaysChanged(visibleDays.first, visibleDays.last,
                      //     CalendarFormat.week);
                      setEvents();
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  achievementCallback(BuildContext context) async {
    Map<String, dynamic> data = {};
    data['total_workout_number'] =
        Provider.of<PlannerModel>(context, listen: false)
            .getTotalCompletedWorkout();
    if (data['total_workout_number'] > 0) {
      Achievement achievement =
          Provider.of<AchievementModel>(context, listen: false)
              .checkAchievement(data);
      // bulk edit //print(achievement);
      if (achievement.id != null) {
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) {
            return AchievementModalContent(
              achievement: achievement,
            );
          },
        );
      }
    }
  }

  Future callbackProgramDay(ProgramDay programDay, bool reschedule) async {
    // bulk edit //print(programDay);
    // bulk edit //print(reschedule);
    if (!reschedule) {
      deleteEventFromCalendar(programDay.dateTime);

      await Provider.of<PlannerModel>(context, listen: false)
          .removeProgramDay(programDay: programDay);
      // _onVisibleDaysChanged(
      //     visibleDays.first, visibleDays.last, CalendarFormat.week);
      setEvents();
    } else {
      rescheduleCalendarDialog(context, programDay);
    }
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

  void setEvents() {
    final _selectedDay = DateTime.now();
    setState(() {
      _events = {};
    });
    programDayList.forEach((element) {
      setState(() {
        _events = {};
      });
    });
    setState(() {
      _selectedEvents = [];
    });

    // bulk edit //print(_events);
  }

  changeDayCallBack(ProgramDay data, DateTime dateTime) async {
    // deleteEventFromCalendar(data.dateTime);

    await Provider.of<PlannerModel>(context, listen: false)
        .changeProgramDayDate(programDay: data, newDateTime: dateTime);
    // _onVisibleDaysChanged(
    //     visibleDays.first, visibleDays.last, CalendarFormat.week);
    // setEvents();
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

  postponeDialog(BuildContext context) {
    Widget saveButton = TextButton(
      child: Text(
        "Postpone!",
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        int postponeDays = int.parse(_postponeDayController.text);
        Provider.of<PlannerModel>(context, listen: false)
            .postponePlanner(postponeDay: postponeDays);
        // _onVisibleDaysChanged(
        //     visibleDays.first, visibleDays.last, CalendarFormat.week);
        setEvents();
        Navigator.pop(context);
        _postponeDayController.clear();
        // bulk edit //print(_postponeDayController.text);
      },
    );
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Postpone the Program"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('I want postpone my programme for'),
          Row(
            children: [
              Container(
                width: 50,
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: TextField(
                  controller: _postponeDayController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(0.0),
                    isDense: true,
                  ),
                ),
              ),
              Text('days.'),
            ],
          )
        ],
      ),
      actions: [
        cancelButton,
        saveButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () => Navigator.pop(context),
    );

    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.all(15),
      actionsPadding: EdgeInsets.all(0),
      content: Text(
        '''This is your planner, it will show you all the workouts that you have planned for yourself. 
In order to have a plan, you can find a workout plan in the workout library or create it on your own.\n
Here are the options in this page:\n
1. You can view events using the calendar icon or the carousel\n
2. You can drag and drop exercise days that are not marked as DONE to reschedule them to another day\n
3. You can add workout programs days that you have already planned\n
4. You can create a quick workout program in this page\n
5. You can add bodystats to any days\n
      ''',
        textAlign: TextAlign.left,
      ),
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

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context, listen: true).user;

    programDayList =
        Provider.of<PlannerModel>(context, listen: true).programDayList;
    bodystatsDayList =
        Provider.of<PlannerModel>(context, listen: true).bodystatsDayList;
    if (_events.isEmpty) setEvents();
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          // color: Colors.red,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 65),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () {
                          return showCalendarDialog(context);
                        },
                        child: Icon(Icons.calendar_today)),
                    Text(
                      allTranslations.text('scheduler')!,
                      style: TextStyle(fontSize: 20),
                    ),
                    GestureDetector(
                        onTap: () => showAlertDialog(context),
                        child: Icon(
                          Icons.info_outline,
                        )),
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: double.infinity,
                  child: Center(
                      child: WeekCalendarWidget(
                    visibleDayChanged: _onVisibleDaysChanged,
                    selectedDay: selectedDay,
                    startDay: selectedDay,
                    selectedDayCallback: _onDaySelected,
                    animationController: _animationController,
                  )),
                ),
                // if (programDayList
                //     .where(
                //         (element) => element.dateTime!.isAfter(DateTime.now()))
                //     .isNotEmpty)
                //   SizedBox(
                //     width: MediaQuery.of(context).size.width * 0.65,
                //     child: FlatButton(
                //       color: Color.fromRGBO(86, 177, 191, 1),
                //       onPressed: () => postponeDialog(context),
                //       child: Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Icon(
                //             Icons.watch_later,
                //             color: Colors.white,
                //           ),
                //           SizedBox(width: 10),
                //           Text(
                //             allTranslations.text('postpone_program')!,
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                if (visibleDays.isNotEmpty)
                  ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: visibleDays.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        List<ProgramDay> dateProgramDay = programDayList
                            .where((programDay) => isSameDate(
                                programDay.dateTime, visibleDays[index]))
                            .toList();
                        List<BodystatsDay?> dateBodyStats = bodystatsDayList
                            .where((bodyDay) => isSameDate(
                                bodyDay!.dateTime, visibleDays[index]))
                            .toList();

                        return PlannerDayItem(
                          achievementCallback: () =>
                              achievementCallback(context),
                          callbackProgramDay: callbackProgramDay,
                          changeDayCallBack: changeDayCallBack,
                          programDay: dateProgramDay,
                          dateBodyStats: dateBodyStats,
                          quickWorkoutCallback: quickWorkoutCallback,
                          dateTime: visibleDays[index],
                          isDashboard: false,
                        );
                      }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
