import '../../model/goal/body_goal.dart';
import '../../model/goal/goal_model.dart';
import '../../model/planner/measurement.dart';
import '../../model/planner/planner_model.dart';
import '../../model/program/workout.dart';
import '../../screen/dashboard/goals/widgets/goal_progress_bar.dart';
import '../../screen/health_stats/widget/detail/body_fat_detail_chart.dart';
import '../../screen/widget/calendar/calendar_widget.dart';
import 'package:flutter/material.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:table_calendar/table_calendar.dart';

import '../../be_theme.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class Bodyfat extends StatefulWidget {
  @override
  _BodyfatState createState() => _BodyfatState();
}

class _BodyfatState extends State<Bodyfat> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  MyTheme theme = MyTheme();
  double? bodyWeight;
  UserObject? user;
  List<Measurement>? bodyFatMeasurements;
  List<BodyGoal> bodyFatGoalList = [];
  DateTime? selectedDay;
  DateTime? firstDay;
  DateTime? lastDay;
  String format = 'dd MMMM yyyy';
  // CalendarController _calendarControllerMonth;
  AnimationController? _animationController;
  Map<DateTime, List<Workout>> _events = {};
  // CalendarController _calendarController;
  double? averageBodyfat;

  List<String> _choices = ["1 m", "3 m", "6 m", "1 y", "All"];
  int selectedDate = 0;

  filterByDate() {
    switch (_choices[selectedDate]) {
      case '1 m':
        setState(() {
          firstDay = DateTime.now().subtract(Duration(days: 30));
          lastDay = DateTime.now();
        });
        break;
      case '3 m':
        setState(() {
          firstDay = DateTime.now().subtract(Duration(days: 30 * 3));
          lastDay = DateTime.now();
        });
        break;
      case '6 m':
        setState(() {
          firstDay = DateTime.now().subtract(Duration(days: 30 * 6));
          lastDay = DateTime.now();
        });
        break;
      case '1 y':
        setState(() {
          firstDay = DateTime.now().subtract(Duration(days: 30 * 12));
          lastDay = DateTime.now();
        });
        break;
      default:
        firstDay = null;
        lastDay = null;
    }
  }

  Widget _buildChoiceChips() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.07,
      child: ListView.builder(
        itemCount: _choices.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 3),
            child: ChoiceChip(
              padding: EdgeInsets.symmetric(horizontal: 9),
              elevation: 5,
              label: Text(_choices[index]),
              selected: selectedDate == index,
              selectedColor: Color.fromRGBO(86, 177, 191, 1),
              onSelected: (bool selected) {
                setState(() {
                  selectedDate = selected ? index : _choices.length - 1;
                });
                filterByDate();
              },
              backgroundColor: Colors.white,
              labelStyle: TextStyle(color: Colors.black),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // _calendarController = CalendarController();
    // _calendarControllerMonth = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController!.forward();
    filterByDate();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    // _calendarController.dispose();
    // _calendarControllerMonth.dispose();
    super.dispose();
  }

  Future<void> setMeasurement() async {
    if (bodyFatMeasurements!.isNotEmpty) {
      setState(() {
        bodyWeight = bodyFatMeasurements!.last.value ?? user!.bodyFatPercentage!.toDouble();
      });
    } else {
      setState(() {
        bodyWeight =
            user != null && user!.bodyFatPercentage != null ? user!.bodyFatPercentage!.toDouble() : 0.0;
      });
    }
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
                height: 325,
                child: CalendarWidget(
                  selectedDay: selectedDay,
                  selectedDayCallback: _onDaySelectedFromMonth,
                  animationController: _animationController,
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    "Select",
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

  // Widget _buildTableCalendarWithBuildersSecond() {
  //   return Container(
  //     height: MediaQuery.of(context).size.height,
  //     width: MediaQuery.of(context).size.width,
  //     child: TableCalendar(
  //       locale: 'en_EN',
  //       calendarController: _calendarControllerMonth,
  //       events: _events,
  //       initialCalendarFormat: CalendarFormat.month,
  //       formatAnimation: FormatAnimation.scale,
  //       startingDayOfWeek: StartingDayOfWeek.monday,
  //       availableGestures: AvailableGestures.all,
  //       availableCalendarFormats: const {
  //         CalendarFormat.month: '',
  //       },
  //       calendarStyle: CalendarStyle(
  //         outsideDaysVisible: false,
  //         weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
  //         holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
  //       ),
  //       daysOfWeekStyle: DaysOfWeekStyle(
  //         weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
  //       ),
  //       headerStyle: HeaderStyle(
  //         centerHeaderTitle: true,
  //         formatButtonVisible: false,
  //       ),
  //       builders: CalendarBuilders(
  //         selectedDayBuilder: (context, date, _) {
  //           return FadeTransition(
  //             opacity:
  //                 Tween(begin: 0.0, end: 1.0).animate(_animationController),
  //             child: Container(
  //               margin: const EdgeInsets.all(4.0),
  //               padding: const EdgeInsets.only(top: 5.0, left: 6.0),
  //               width: 100,
  //               height: 100,
  //               child: Text(
  //                 '${date.day}',
  //                 style: TextStyle().copyWith(fontSize: 16.0),
  //               ),
  //             ),
  //           );
  //         },
  //         todayDayBuilder: (context, date, _) {
  //           return Container(
  //             margin: const EdgeInsets.all(4.0),
  //             padding: const EdgeInsets.only(top: 5.0, left: 6.0),
  //             width: 100,
  //             height: 100,
  //             child: Text(
  //               '${date.day}',
  //               style: TextStyle().copyWith(fontSize: 16.0),
  //             ),
  //           );
  //         },
  //         markersBuilder: (context, date, events, holidays) {
  //           final children = <Widget>[];

  //           if (events.isNotEmpty) {
  //             children.add(
  //               Container(),
  //             );
  //           }

  //           if (holidays.isNotEmpty) {
  //             children.add(
  //               Container(),
  //             );
  //           }

  //           return children;
  //         },
  //       ),
  //       onDaySelected: (date, events, holidays) {
  //         _onDaySelectedFromMonth(date);
  //         _animationController.forward(from: 0.0);
  //       },
  //       onVisibleDaysChanged: (_, x, y) => null,
  //       onCalendarCreated: _onCalendarCreatedForWeeks,
  //     ),
  //   );
  // }

  void _onDaySelectedFromMonth(DateTime day) {
    // bulk edit //print('CALLBACK: _onDaySelected');
    // bulk edit //print(day);
    // setState(() {
    //   _selectedEvents = events;
    // });
    setState(() {
      selectedDay = day;
      rangeOfTheMonth(selectedDay!);
    });
    Navigator.pop(context);
  }

  void rangeOfTheMonth(DateTime dateTime) {
    var beginningNextMonth = (dateTime.month < 12)
        ? DateTime(dateTime.year, dateTime.month + 1, 1)
        : DateTime(dateTime.year + 1, 1, 1);
    var last = beginningNextMonth.subtract(Duration(days: 1)).day;
    setState(() {
      firstDay = DateTime(dateTime.year, dateTime.month, 1);
      lastDay = DateTime(dateTime.year, dateTime.month, last);
    });
  }

  void _onCalendarCreatedForWeeks(
      DateTime first, DateTime last, CalendarFormat format) {
    // bulk edit //print('CALLBACK: _onCalendarCreated');
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context, listen: true).user;
    bodyFatGoalList = Provider.of<GoalModel>(context, listen: true)
        .bodyGoalList
        .where((element) => element.name == 'Body Fat' && !element.isCompleted!)
        .toList();

    bodyFatMeasurements = Provider.of<PlannerModel>(context, listen: true)
            .bodystatsDayList
            .isEmpty
        ? []
        : Provider.of<PlannerModel>(context, listen: true)
            .bodystatsDayList
            .map((e) => e!.measurements
                    .where((element) => element.name == 'Body Fat')
                    .map((e2) {
                  e2.dateTime = e.dateTime;
                  return e2;
                }).toList())
            .toList()
            .reduce((a, b) {
            a.addAll(b);
            return a;
          });

    if (averageBodyfat == null && bodyFatMeasurements!.isNotEmpty) {
      averageBodyfat =
          bodyFatMeasurements!.map((m) => m.value).reduce((a, b) => a! + b!)! /
              bodyFatMeasurements!.length;
    }

    List<Measurement>? listviewMeasurementList = [];

    // bulk edit //print(bodyFatMeasurements);
    if (firstDay != null &&
        lastDay != null &&
        bodyFatMeasurements!.isNotEmpty) {
      setState(() {
        listviewMeasurementList = bodyFatMeasurements!
            .where((element) =>
                element.dateTime!.isAfter(firstDay!) &&
                element.dateTime!.isBefore(lastDay!))
            .toList();
      });
    } else if (bodyFatMeasurements!.isNotEmpty) {
      setState(() {
        listviewMeasurementList = bodyFatMeasurements;
      });
    }
    listviewMeasurementList!.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));

    if (bodyWeight == null && user != null && bodyFatMeasurements != null)
      setMeasurement();

    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: theme.currentTheme() == ThemeMode.dark
                ? Colors.grey[700]
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        allTranslations.text('bodyfat')! + '%',
                        style: TextStyle(fontSize: 16),
                      ),
                      // Row(
                      //   children: [
                      //     Text(
                      //       selectedDay != null
                      //           ? intl.DateFormat(format)
                      //                   .format(firstDay)
                      //                   .toString() +
                      //               ' - ' +
                      //               intl.DateFormat(format)
                      //                   .format(lastDay)
                      //                   .toString()
                      //           : 'All',
                      //       style: TextStyle(fontSize: 12),
                      //     ),
                      //     SizedBox(width: 3),
                      //     GestureDetector(
                      //       onTap: () {
                      //         return showCalendarDialog(context);
                      //       },
                      //       child: Icon(
                      //         Icons.calendar_today,
                      //         color: Colors.grey,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      allTranslations.text('back')!,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              if (bodyFatMeasurements!.isNotEmpty)
                BodyFatDetailChart(
                  firstDate: firstDay,
                  lastDate: lastDay,
                ),
              SizedBox(height: 15),
              if (bodyFatGoalList.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allTranslations.text('goals')!,
                      style: TextStyle(fontSize: 17),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (bodyFatGoalList.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                allTranslations.text('bodyfat')! + ' %',
                                style: TextStyle(fontSize: 17),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Text(bodyFatGoalList.first.name ==
                                              'Body Fat'
                                          ? bodyWeight!.toInt().toString()
                                          : bodyWeight!.toInt().toString()),
                                      Text(' / '),
                                      Text(bodyFatGoalList.first.goal
                                          .toString()),
                                      Text('%'),
                                    ],
                                  ),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      child: GoalProgressBarWidget(
                                        data1: (bodyFatGoalList.first.initial! -
                                                        bodyWeight!.toDouble())
                                                    .abs() ==
                                                0
                                            ? 1
                                            : (bodyFatGoalList.first.initial! -
                                                    bodyWeight!.toDouble())
                                                .abs(),
                                        data2: (bodyFatGoalList.first.goal! -
                                                bodyFatGoalList.first.initial!)
                                            .abs(),
                                      )),
                                ],
                              ),
                            ],
                          )
                      ],
                    ),
                  ],
                ),
              _buildChoiceChips(),
              SizedBox(height: 15),
              Text(
                allTranslations.text('bodyfat')!,
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(height: 10),
              if (averageBodyfat != null && averageBodyfat! < 12)
                Text(
                  'Acceptable in some cases for short periods of time. However, we do not recommend staying at this range for a prolonged period of time if not necessary.',
                  style: TextStyle(
                    color: theme.currentTheme() == ThemeMode.dark
                        ? Colors.white
                        : Colors.black38,
                  ),
                ),
              if (averageBodyfat != null &&
                  averageBodyfat! > 12 &&
                  averageBodyfat! < 15)
                Text(
                  'This is the average range for athletes. It is not necessary for most people to be within this range but is considered find for aesthetics or sports performance.',
                  style: TextStyle(
                    color: theme.currentTheme() == ThemeMode.dark
                        ? Colors.white
                        : Colors.black38,
                  ),
                ),
              if (averageBodyfat != null &&
                  averageBodyfat! > 16 &&
                  averageBodyfat! < 30)
                Text(
                  'This is the average range for non-athlete fitness. You are in a healty range and should work towards maintain your body fat percentage within this range. Good job.',
                  style: TextStyle(
                    color: theme.currentTheme() == ThemeMode.dark
                        ? Colors.white
                        : Colors.black38,
                  ),
                ),
              if (averageBodyfat != null &&
                  averageBodyfat! > 31 &&
                  averageBodyfat! < 36)
                Text(
                  'You are considered overweight and should work towards reducing your body fat percentage to healthy levels, through proper diet and exercise. Having a high body fat percentage puts you at a high risk of many preventable cardiovascular diseases.',
                  style: TextStyle(
                    color: theme.currentTheme() == ThemeMode.dark
                        ? Colors.white
                        : Colors.black38,
                  ),
                ),
              if (averageBodyfat != null && averageBodyfat! > 36)
                Text(
                  'You are considered severely overweight and should work towards reducing your body fat percentage to healthy levels, through proper diet and exercise. Having an overly high body fat percentage puts yo at a very high risk of many preventable cardiovascular diseases.',
                  style: TextStyle(
                    color: theme.currentTheme() == ThemeMode.dark
                        ? Colors.white
                        : Colors.black38,
                  ),
                ),
              if (selectedDay != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    intl.DateFormat('MMMM')
                        .format(selectedDay!)
                        .toString()
                        .toUpperCase(),
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: listviewMeasurementList != null
                    ? listviewMeasurementList!.length
                    : 0,
                itemBuilder: (context, index) {
                  return Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                listviewMeasurementList![index]
                                        .dateTime!
                                        .day
                                        .toString() +
                                    ' ' +
                                    intl.DateFormat('MMM')
                                        .format(listviewMeasurementList![index]
                                            .dateTime!)
                                        .toString() +
                                    ' ' +
                                    listviewMeasurementList![index]
                                        .dateTime!
                                        .year
                                        .toString(),
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                listviewMeasurementList![index]
                                        .value
                                        .toString() +
                                    ' %',
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
