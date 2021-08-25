import 'package:bodyengineer/model/achievement/achievement.dart';
import 'package:bodyengineer/model/achievement/achievement_model.dart';
import 'package:bodyengineer/screen/widget/achievement_modal_content.dart';

import '../../../model/program/program_model.dart';
import '../../../screen/widget/calendar/calendar_widget.dart';
import 'package:flutter/material.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import '../../be_theme.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../translations.dart';
import '../program_library/widgets/program_phase_detail_item.dart';
import '../../model/planner/planner_model.dart';
import '../../model/program/program.dart';
import '../../model/program/programDay.dart';
import '../../model/program/programWeek.dart';

class WorkoutList extends StatefulWidget {
  @override
  _WorkoutListState createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  Program? newProgram;
  Program? addonProgram;
  // CalendarController _calendarRescheudle;
  // CalendarController _calendarNewWorkout;
  DateTime rescheudle = DateTime.now();
  DateTime newWorkoutDate = DateTime.now();
  UserObject? user;
  AnimationController? _animationController;
  Map<DateTime, List>? _events;
  List? _selectedEvents;
  // CalendarController _calendarController;
  DateTime todayDate = DateTime
      .now(); // TODO to test changing workout date change variable to : DateTime(2021, 5, 12)
  int seenPhase = 0;
  int seenWeek = 0;
  bool openPhases = false;
  bool isFilled = false;
  bool isLoading = false;
  bool isWarning = false;
  bool findSeenPhaseandWeek = false;
  DateTime? weekStart;
  DateTime? weekEnd;
  MyTheme theme = MyTheme();
  String? programName = '';
  var _tapPosition;
  var _count = 0;

  // Example holidays
  final Map<DateTime, List> _holidays = {
    DateTime(2020, 1, 1): ['New Year\'s Day'],
    DateTime(2020, 1, 6): ['Epiphany'],
    DateTime(2020, 2, 14): ['Valentine\'s Day'],
    DateTime(2020, 4, 21): ['Easter Sunday'],
    DateTime(2020, 4, 22): ['Easter Monday'],
  };

  Function? achievementCallback(BuildContext context) {
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

  // ignore: unused_element
  void _onDaySelected(DateTime day, List events, List holidays) {
    // bulk edit //print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  // ignore: unused_element
  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    // bulk edit //print('CALLBACK: _onVisibleDaysChanged');
  }

  // ignore: unused_element
  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    // bulk edit //print('CALLBACK: _onCalendarCreated');
  }

  // ignore: unused_element
  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  void newWorkoutCallback(DateTime dateTime) {
    // bulk edit //print('Quick Workout ==>');
    // bulk edit //print(dateTime);
    String programDayId = DateTime.now().microsecondsSinceEpoch.toString();

    Provider.of<PlannerModel>(context, listen: false).addQuickWorkout(
        dateTime: dateTime,
        uid: user!.uid,
        programDayId: programDayId,
        dayName: 'New Workout');
    ProgramDay programDay = Provider.of<PlannerModel>(context, listen: false)
        .programDayList
        .where((element) => element.id == programDayId)
        .first;

    Navigator.pushNamed(
      context,
      '/workout_log',
      arguments: {
        'programDay': programDay,
        'index': 3,
        'achievementCallback': achievementCallback(context)
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
      content: Text('''In the workout management page,
you are able to update your programs.

1. You are able to add customised workout days into your program

2. You are able to update individual planned workout days.

3. By clicking on the icon below the picture on the right hand corner,
you are able to access the weeks and phases in your program

4. You can delete your program or workout days here.'''),
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

  // void _showCustomMenu() {
  //   final RenderBox overlay = Overlay.of(context).context.findRenderObject();

  //   showMenu(
  //           context: context,
  //           items: <PopupMenuEntry<int>>[PopupMenu()],
  //           position: RelativeRect.fromRect(
  //               _tapPosition & const Size(40, 40), Offset.zero & overlay.size))
  //       .then<void>((int delta) {
  //     if (delta == null) return;
  //     setState(() {
  //       _count = _count + delta;
  //     });
  //   });
  // }

  // void _storePosition(TapDownDetails details) {
  //   _tapPosition = details.globalPosition;
  // }

  @override
  void initState() {
    super.initState();

    // _calendarRescheudle = CalendarController();
    // _calendarNewWorkout = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController!.forward();
    print('Init Work ******');
  }

  @override
  void dispose() {
    _animationController!.dispose();
    // _calendarRescheudle.dispose();
    // _calendarNewWorkout.dispose();
    super.dispose();
  }

  void programDayCallback(ProgramDay programDay) {
    // bulk edit //print(programDay);
    setState(() {
      bool isNew = newProgram!
          .phaseList[seenPhase].programWeek[seenWeek].weekDays
          .where((element) => element == programDay)
          .isEmpty;
      if (isNew) {
        newProgram!.phaseList[seenPhase].programWeek[seenWeek].weekDays
            .add(programDay);
      } else {
        newProgram!.phaseList[seenPhase].programWeek[seenWeek].weekDays
            .where((element) => element == programDay)
            .toList()
            .first = programDay;
      }
      isWarning = false;
    });
  }

  void clickCallBack(phaseIndex, weekIndex) {
    setState(() {
      seenPhase = phaseIndex;
      seenWeek = weekIndex;
      openPhases = !openPhases;
    });
  }

  deletePopup(BuildContext context, UserObject? user, String? programId) {
    Widget okButton = TextButton(
      child: Text(
        allTranslations.text('delete')!,
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1), fontSize: 16),
      ),
      onPressed: () async {
        await Provider.of<ProgramModel>(context, listen: false)
            .cleanAllProgram();
        await Provider.of<PlannerModel>(context, listen: false)
            .cleanAllProgram();
        setState(() {
          newProgram = Provider.of<PlannerModel>(context, listen: false)
              .plannerMainProgram;
          addonProgram = Provider.of<PlannerModel>(context, listen: false)
              .plannerAddonProgram;
        });

        Navigator.pop(context);
      },
    );
    Widget cancelButton = TextButton(
      child: Text(
        allTranslations.text('cancel')!,
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1), fontSize: 16),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(allTranslations.text('delete_program')!),
      content: Text(allTranslations.text('delete_program_question')!),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  deleteWorkoutDayDialog(BuildContext context, ProgramDay programDay) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(allTranslations.text('delete_workout_day')!),
          content: Text(allTranslations.text('delete_workout_day_question')!),
          actions: [
            TextButton(
              child: Text(
                allTranslations.text('cancel')!,
                style: TextStyle(
                    color: Color.fromRGBO(8, 112, 138, 1), fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                allTranslations.text('delete')!,
                style: TextStyle(
                    color: Color.fromRGBO(8, 112, 138, 1), fontSize: 16),
              ),
              onPressed: () async {
                await Provider.of<PlannerModel>(context, listen: false)
                    .deleteProgramDay(programDay);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  workoutDayMenu(BuildContext context, ProgramDay programDay) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 40,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/workout_log', arguments: {
                      'programDay': programDay,
                      'index': 3,
                      'achievementCallback': () => achievementCallback(context)
                    });
                  },
                  child: Text(
                    allTranslations.text('edit_workout')!,
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Color.fromRGBO(8, 112, 138, 1),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: RaisedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    deleteWorkoutDayDialog(context, programDay);
                  },
                  child: Text(
                    allTranslations.text('delete_workout')!,
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Color.fromRGBO(8, 112, 138, 1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.symmetric(horizontal: 5),
              content: Container(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: CalendarWidget(
                    selectedDay: rescheudle,
                    selectedDayCallback: rescheudleCallback,
                    animationController: _animationController,
                  )),
              actions: [
                TextButton(
                  child: Text(
                    allTranslations.text('select')!,
                    style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
                  ),
                  onPressed: () {
                    if (rescheudle != null) {
                      // bulk edit //print('rescheudle ==>' + rescheudle.toString());

                      Provider.of<PlannerModel>(context, listen: false)
                          .rescheduleDays(rescheudleDate: rescheudle);
                    }
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

  showCalendarDialogNewWorkout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(5),
              content: Container(
                height: MediaQuery.of(context).size.height * 0.55,
                child: CalendarWidget(
                  selectedDay: newWorkoutDate,
                  selectedDayCallback: newWorkoutCallback,
                  animationController: _animationController,
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    allTranslations.text('select')!,
                    style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    newWorkoutCallback(newWorkoutDate);
                    // bulk edit //print(newWorkoutDate.toString());
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  rescheudleCallback(DateTime date) {
    setState(() {
      rescheudle = date;
    });
  }

  newWorkoutDateCallback(DateTime date) {
    setState(() {
      newWorkoutDate = date;
    });
  }

  void _onCalendarCreatedForWeeks(
      DateTime first, DateTime last, CalendarFormat format) {
    // bulk edit //print('CALLBACK: _onCalendarCreated');
  }

  findSeendPhaseAndSeenWeek() {
    List<ProgramWeek> programWeek = newProgram!.phaseList
        .map((e) => e.programWeek)
        .expand((element) => element)
        .toList();

    List<ProgramDay> programDaysList = programWeek
        .map((e) => e.weekDays)
        .expand((element) => element)
        .toList();

    ProgramDay closestDay = programDaysList.reduce((a, b) =>
        a.dateTime!.difference(todayDate).abs() <
                b.dateTime!.difference(todayDate).abs()
            ? a
            : b);

    setState(() {
      seenPhase = int.parse(closestDay.phaseNumber!);
      seenWeek = int.parse(closestDay.weekNumber!);
      findSeenPhaseandWeek = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context, listen: true).user;
    List<Program> programList =
        Provider.of<ProgramModel>(context, listen: false).programList;
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    newProgram =
        Provider.of<PlannerModel>(context, listen: true).plannerMainProgram;
    addonProgram =
        Provider.of<PlannerModel>(context, listen: true).plannerAddonProgram;

    if (newProgram != null) {
      if (programList
          .where((element) => element.programId == newProgram!.programId)
          .isNotEmpty)
        setState(() {
          programName = programList
              .firstWhere(
                  (element) => element.programId == newProgram!.programId)
              .programName;
        });
      if (newProgram!.phaseList.isNotEmpty) {
        if (!findSeenPhaseandWeek) findSeendPhaseAndSeenWeek();
        weekStart =
            newProgram!.phaseList[seenPhase].programWeek[seenWeek].startDate;
        weekEnd =
            newProgram!.phaseList[seenPhase].programWeek[seenWeek].endDate;
      }
    }

    if (addonProgram != null) {
      if (addonProgram!.phaseList.isNotEmpty) {
        weekStart =
            addonProgram!.phaseList[seenPhase].programWeek[seenWeek].startDate;
        weekEnd =
            addonProgram!.phaseList[seenPhase].programWeek[seenWeek].endDate;
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      key: _key,
      body: SingleChildScrollView(
        child: newProgram == null || newProgram!.programId == null
            ? Container(
                color: theme.currentTheme() == ThemeMode.dark
                    ? Colors.grey[850]
                    : Colors.white,
                height: MediaQuery.of(context).size.height * 0.75,
                alignment: Alignment.center,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      allTranslations.text('add_program_via_library')!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            : Stack(children: [
                GestureDetector(
                  onTap: () {
                    if (openPhases) {
                      setState(() {
                        openPhases = false;
                      });
                    } else {}
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.currentTheme() == ThemeMode.dark
                          ? Colors.grey[850]
                          : Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.2,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/workout/workout_image.jpg'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Text(
                                        allTranslations
                                            .text('training_program')!,
                                      ),
                                      SizedBox(width: 10),
                                      GestureDetector(
                                          onTap: () => showAlertDialog(context),
                                          child: Icon(Icons.info_outline)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        openPhases = !openPhases;
                                      });
                                    },
                                    child: Icon(Icons.logout)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: GestureDetector(
                              onTap: () => deletePopup(
                                  context, user, newProgram!.programId),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  color: Colors.grey,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.delete_forever,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      allTranslations.text('delete_program')!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  allTranslations.text('phase')! +
                                      ' ' +
                                      (seenPhase + 1).toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (newProgram != null)
                                  Row(
                                    children: [
                                      Text(
                                        allTranslations.text('week')! +
                                            ' ' +
                                            (seenWeek + 1).toString() +
                                            ' (${weekStart!.day}-${weekStart!.month}-${weekStart!.year} / ${weekEnd!.day}-${weekEnd!.month}-${weekEnd!.year})',
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.symmetric(
                                      //       horizontal: 7),
                                      //   child: GestureDetector(
                                      //       onTap: () {
                                      //         showCalendarDialog(context);
                                      //       },
                                      //       child: Icon(Icons.edit)),
                                      // ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          if (newProgram != null &&
                              newProgram!.phaseList != null)
                            ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: newProgram!.phaseList[seenPhase]
                                    .programWeek[seenWeek].weekDays.length,
                                itemBuilder: (BuildContext ctxt, int index) {
                                  ProgramDay programDay = newProgram!
                                      .phaseList[seenPhase]
                                      .programWeek[seenWeek]
                                      .weekDays[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 7,
                                      horizontal: 10,
                                    ),
                                    child: GestureDetector(
                                      onTap: () =>
                                          workoutDayMenu(context, programDay),
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.only(left: 15.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          color: programDay.isDayCompleted
                                              ? Color.fromRGBO(8, 112, 138, 1)
                                              : Color.fromRGBO(86, 177, 191, 1),
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 3,
                                                spreadRadius: 1,
                                                offset: Offset(1, 2),
                                                color: Color(0xffd6d6d6))
                                          ],
                                        ),
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.075,
                                        child: Container(
                                            padding: EdgeInsets.only(left: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(10.0),
                                                  bottomRight:
                                                      Radius.circular(10.0)),
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  programDay.name ?? '',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Color.fromRGBO(
                                                        44, 44, 44, 1),
                                                  ),
                                                ),
                                                Text(
                                                  programDay.workoutList.length
                                                          .toString() +
                                                      ' ' +
                                                      allTranslations
                                                          .text('exercises')!,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Color.fromRGBO(
                                                        44, 44, 44, 1),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ),
                                  );
                                }),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: GestureDetector(
                              onTap: () =>
                                  showCalendarDialogNewWorkout(context),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Spacer(),
                                  Icon(Icons.add),
                                  SizedBox(width: 10),
                                  Text(
                                    allTranslations.text('add_new_workout')!,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                            ),
                          ),
                          if (addonProgram != null &&
                              addonProgram!.phaseList != null &&
                              addonProgram!.phaseList.isNotEmpty)
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(
                                    thickness: 2,
                                    color: Color.fromRGBO(8, 112, 138, 1),
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Text(
                                        allTranslations.text('add_on_program')!,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          allTranslations.text('phase')! +
                                              ' ' +
                                              (seenPhase + 1).toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (newProgram != null)
                                          Row(
                                            children: [
                                              Text(
                                                allTranslations.text('week')! +
                                                    ' ' +
                                                    (seenWeek + 1).toString() +
                                                    ' (${weekStart!.day}-${weekStart!.month}-${weekStart!.year} / ${weekEnd!.day}-${weekEnd!.month}-${weekEnd!.year})',
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7),
                                                child: GestureDetector(
                                                    onTap: () {},
                                                    child: Icon(Icons.edit)),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (addonProgram != null &&
                                      addonProgram!.phaseList != null &&
                                      addonProgram!.phaseList.isNotEmpty)
                                    ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: addonProgram!
                                            .phaseList[seenPhase]
                                            .programWeek[seenWeek]
                                            .weekDays
                                            .length,
                                        itemBuilder:
                                            (BuildContext ctxt, int index) {
                                          ProgramDay programDay = addonProgram!
                                              .phaseList[seenPhase]
                                              .programWeek[seenWeek]
                                              .weekDays[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 7,
                                              horizontal: 10,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, '/workout_log',
                                                    arguments: {
                                                      'programDay': programDay,
                                                      'index': 3,
                                                      'achievementCallback': () =>
                                                          achievementCallback(
                                                              context)
                                                    });
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    color: programDay
                                                            .isDayCompleted
                                                        ? Color.fromRGBO(
                                                            8, 112, 138, 1)
                                                        : Color.fromRGBO(
                                                            86, 177, 191, 1),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black26,
                                                        offset: Offset(2, 3),
                                                        blurRadius: 3,
                                                        spreadRadius: 2,
                                                      )
                                                    ]),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.075,
                                                child: Container(
                                                    padding: EdgeInsets.only(
                                                        left: 10),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(
                                                                      10.0),
                                                              bottomRight: Radius
                                                                  .circular(
                                                                      10.0)),
                                                      color: Colors.white,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          programDay.name ?? '',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color:
                                                                Color.fromRGBO(
                                                                    44,
                                                                    44,
                                                                    44,
                                                                    1),
                                                          ),
                                                        ),
                                                        Text(
                                                          programDay.workoutList
                                                                  .length
                                                                  .toString() +
                                                              ' ' +
                                                              allTranslations.text(
                                                                  'exercises')!,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                Color.fromRGBO(
                                                                    44,
                                                                    44,
                                                                    44,
                                                                    1),
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                              ),
                                            ),
                                          );
                                        }),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: openPhases,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 4,
                        )
                      ]),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        openPhases = !openPhases;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.close,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(programName!),
                                  Text(
                                    allTranslations.text('program_duration')!,
                                    style: TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (newProgram != null &&
                                newProgram!.phaseList != null)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 25),
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: newProgram!.phaseList.length,
                                    itemBuilder:
                                        (BuildContext ctxt, int index) {
                                      return ProgramPhaseDetailItem(
                                        clickCallBack: clickCallBack,
                                        phaseNo: (index + 1).toString(),
                                        programPhase:
                                            newProgram!.phaseList[index],
                                      );
                                    }),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
      ),
    );
  }
}

// ignore: must_be_immutable
class PopupMenu extends PopupMenuEntry<int> {
  @override
  double height = 100;

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  PopupMenuState createState() => PopupMenuState();
}

class PopupMenuState extends State<PopupMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            // bulk edit //print('Edit Tapped');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  allTranslations.text('edit')!,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                ),
                Icon(Icons.add),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            // bulk edit //print('Remove Tapped');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  allTranslations.text('remove')!,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                ),
                Icon(Icons.add),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            // bulk edit //print('Schedule Tapped');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  allTranslations.text('schedule')!,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                ),
                Icon(Icons.add),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
