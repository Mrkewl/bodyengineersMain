import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';
import './widgets/program_phase_detail_item.dart';
import '../../model/planner/planner_model.dart';
import '../../model/program/program.dart';
import '../../model/program/programDay.dart';
import '../../model/program/program_model.dart';

class NewProgram extends StatefulWidget {
  @override
  _NewProgramState createState() => _NewProgramState();
}

class _NewProgramState extends State<NewProgram> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  Program? newProgram;
  // CalendarController _calendarControllerMonths;
  late AnimationController _animationController;
  late Map<DateTime, List> _events;
  List? _selectedEvents;
  // CalendarController _calendarController;
  int seenPhase = 0;
  int seenWeek = 0;
  bool openPhases = false;
  bool isFilled = false;
  bool isLoading = false;
  bool isWarning = false;
  DateTime? weekStart;
  DateTime? weekEnd;
  FirebaseAuth auth = FirebaseAuth.instance;

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

  showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () => Navigator.pop(context),
    );

    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.all(15),
      actionsPadding: EdgeInsets.all(0),
      content: Text(
          "Tap on the day to schedule an action.\nDrag and drop action to another day for quick rescheduling"),
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
    final _selectedDay = DateTime.now();

    _events = {
      _selectedDay.subtract(Duration(days: 30)): [
        'Event A0',
        'Event B0',
        'Event C0'
      ],
      _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
      _selectedDay.subtract(Duration(days: 20)): [
        'Event A2',
        'Event B2',
        'Event C2',
        'Event D2'
      ],
      _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
      _selectedDay.subtract(Duration(days: 10)): [
        'Event A4',
        'Event B4',
        'Event C4'
      ],
      _selectedDay.subtract(Duration(days: 4)): [
        'Event A5',
        'Event B5',
        'Event C5'
      ],
      _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
      _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
      _selectedDay.add(Duration(days: 1)): [
        'Event A8',
        'Event B8',
        'Event C8',
        'Event D8'
      ],
      _selectedDay.add(Duration(days: 3)):
          Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
      _selectedDay.add(Duration(days: 7)): [
        'Event A10',
        'Event B10',
        'Event C10'
      ],
      _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
      _selectedDay.add(Duration(days: 17)): [
        'Event A12',
        'Event B12',
        'Event C12',
        'Event D12'
      ],
      _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
      _selectedDay.add(Duration(days: 26)): [
        'Event A14',
        'Event B14',
        'Event C14'
      ],
    };

    _selectedEvents = _events[_selectedDay] ?? [];

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    newProgram = Provider.of<ProgramModel>(context, listen: true).newProgram;
    weekStart =
        newProgram!.phaseList[seenPhase].programWeek[seenWeek].startDate;
    weekEnd = newProgram!.phaseList[seenPhase].programWeek[seenWeek].endDate;
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: newProgram == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (openPhases) {
                        setState(() {
                          openPhases = false;
                        });
                      } else {}
                    },
                    child: Container(
                      decoration: BoxDecoration(),
                      height: MediaQuery.of(context).size.height,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(allTranslations
                                            .text('training_program')!),
                                        SizedBox(width: 10),
                                        GestureDetector(
                                            onTap: () =>
                                                showAlertDialog(context),
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
                                  Row(
                                    children: [
                                      Text(
                                        allTranslations.text('week')! +
                                            ' ' +
                                            (seenWeek + 1).toString() +
                                            ' (${weekStart!.day}-${weekStart!.month}-${weekStart!.year} / ${weekEnd!.day}-${weekEnd!.month}-${weekEnd!.year})',
                                        style: TextStyle(
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7),
                                        child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                openPhases = !openPhases;
                                              });
                                            },
                                            child: Icon(Icons.edit)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, '/add_new_workout',
                                            arguments: {
                                              'programDayCallback':
                                                  programDayCallback,
                                              'programDay': programDay,
                                            });
                                      },
                                      // onLongPress: _showCustomMenu,
                                      // onTapDown: _storePosition,
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.only(left: 15.0),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: isFilled
                                                ? Color.fromRGBO(8, 112, 138, 1)
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
                            if (newProgram!.phaseList[seenPhase]
                                    .programWeek[seenWeek].maxDay >
                                newProgram!.phaseList[seenPhase]
                                    .programWeek[seenWeek].weekDays.length)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/add_new_workout',
                                        arguments: {
                                          'programDayCallback':
                                              programDayCallback
                                        });
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Spacer(),
                                      Icon(Icons.add),
                                      SizedBox(width: 10),
                                      Text(
                                        'Add New Workout',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color.fromRGBO(44, 44, 44, 1),
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                            if (isWarning)
                              Text('Please Add At Least One Workout!',
                                  style: TextStyle(color: Colors.red)),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height:
                                    MediaQuery.of(context).size.height * 0.075,
                                child: RaisedButton(
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    List<ProgramDay> programDayList = [];
                                    newProgram!.phaseList.forEach((phase) {
                                      phase.programWeek.forEach((week) {
                                        week.weekDays.forEach((programDay) {
                                          programDay.weekNumber =
                                              week.weekNumber;
                                          programDay.phaseNumber =
                                              phase.phaseNumber;
                                          programDay.programId = '0';
                                          programDay.uid =
                                              auth.currentUser!.uid;
                                          programDay.isAddonDay = false;
                                          programDay.registerDate =
                                              DateTime.now();
                                          programDay.equalizeUserSets();

                                          programDayList.add(programDay);
                                        });
                                      });
                                    });
                                    if (programDayList.isNotEmpty) {
                                      await Provider.of<PlannerModel>(context,
                                              listen: false)
                                          .saveProgramToPlanner(
                                              newProgramDayList:
                                                  programDayList);
                                      await Provider.of<PlannerModel>(context,
                                              listen: false)
                                          .setPlanner();
                                      await Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          '/navigation',
                                          (route) => false,
                                          arguments: {'index': 1});
                                    } else {
                                      setState(() {
                                        isLoading = false;
                                        isWarning = true;
                                      });
                                    }
                                  },
                                  color: Color.fromRGBO(8, 112, 138, 1),
                                  child: !isLoading
                                      ? Text(
                                          allTranslations
                                              .text('save_go_planner')!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16),
                                        )
                                      : CircularProgressIndicator(),
                                ),
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
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Icon(
                                            Icons.close,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text('Lean Fit'),
                                    Text(
                                      'Program Duration',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Text(
                                      '(' +
                                          newProgram!.startDate!.day
                                              .toString() +
                                          '/' +
                                          newProgram!.startDate!.month
                                              .toString() +
                                          '/' +
                                          newProgram!.startDate!.year
                                              .toString() +
                                          '-' +
                                          newProgram!.endDate!.day.toString() +
                                          '/' +
                                          newProgram!.endDate!.month
                                              .toString() +
                                          '/' +
                                          newProgram!.endDate!.year.toString() +
                                          ')',
                                      style: TextStyle(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                              Padding(
                                padding: const EdgeInsets.only(bottom: 25),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Spacer(),
                                    Icon(Icons.add),
                                    SizedBox(width: 10),
                                    Text(
                                      'Create Own Program',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color.fromRGBO(44, 44, 44, 1),
                                      ),
                                    ),
                                    Spacer(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
                Text('Edit'),
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
                Text('Remove'),
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
                Text('Schedule'),
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
