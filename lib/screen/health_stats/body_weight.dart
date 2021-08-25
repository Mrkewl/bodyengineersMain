import '../../model/goal/body_goal.dart';
import '../../model/goal/goal_model.dart';
import '../../model/planner/measurement.dart';
import '../../model/planner/planner_model.dart';
import '../../model/program/workout.dart';
import '../../screen/dashboard/goals/widgets/goal_progress_bar.dart';
import '../../screen/health_stats/widget/detail/body_weight_detail_chart.dart';
import '../../screen/widget/calendar/calendar_widget.dart';
import 'package:flutter/material.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart' as intl;

import '../../be_theme.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class BodyWeight extends StatefulWidget {
  @override
  _BodyWeightState createState() => _BodyWeightState();
}

class _BodyWeightState extends State<BodyWeight> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  MyTheme theme = MyTheme();

  List<Measurement>? bodyWeightMeasurements;
  List<BodyGoal> bodyWeightGoalList = [];
  double? bodyWeight;
  UserObject? user;

  DateTime? selectedDay;
  DateTime? firstDay;
  DateTime? lastDay;
  String format = 'dd MMMM yyyy';
  // CalendarController _calendarControllerMonth;
  AnimationController? _animationController;
  Map<DateTime, List<Workout>> _events = {};
  // CalendarController _calendarController;

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
              elevation: 3,
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
    if (bodyWeightMeasurements!.isNotEmpty) {
      setState(() {
        bodyWeight = bodyWeightMeasurements!.last.value != null
            ? bodyWeightMeasurements!.last.value!.toDouble()
            : user!.bodyWeightInKilo;
      });
    } else {
      setState(() {
        bodyWeight = user!.bodyWeightInKilo;
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
    String measurement = Provider.of<UserModel>(context, listen: true)
                .user!
                .unitOfMeasurementId ==
            1
        ? 'kg'
        : 'lbs';
    bodyWeightGoalList = Provider.of<GoalModel>(context, listen: true)
        .bodyGoalList
        .where(
            (element) => element.name == 'Body Weight' && !element.isCompleted!)
        .toList();
    bodyWeightMeasurements = Provider.of<PlannerModel>(context, listen: true)
            .bodystatsDayList
            .isEmpty
        ? []
        : Provider.of<PlannerModel>(context, listen: true)
            .bodystatsDayList
            .map((e) => e!.measurements
                    .where((element) => element.name == 'Body Weight')
                    .map((e2) {
                  e2.dateTime = e.dateTime;
                  return e2;
                }).toList())
            .toList()
            .reduce((a, b) {
            a.addAll(b);
            return a;
          });

    List<Measurement>? listviewMeasurementList = [];

    // bulk edit //print(bodyWeightMeasurements);
    if (firstDay != null &&
        lastDay != null &&
        bodyWeightMeasurements!.isNotEmpty) {
      setState(() {
        listviewMeasurementList = bodyWeightMeasurements!
            .where((element) =>
                element.dateTime!.isAfter(firstDay!) &&
                element.dateTime!.isBefore(lastDay!))
            .toList();
      });
    } else if (bodyWeightMeasurements!.isNotEmpty) {
      setState(() {
        listviewMeasurementList = bodyWeightMeasurements;
      });
    }
    listviewMeasurementList!.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));

    if (bodyWeight == null && user != null && bodyWeightMeasurements != null)
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
                        allTranslations.text('bodyweight')!,
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
              if (bodyWeightMeasurements!.isNotEmpty)
                BodyWeightDetailChart(
                  firstDate: firstDay,
                  lastDate: lastDay,
                ),
              SizedBox(height: 15),
              if (bodyWeightGoalList.isNotEmpty)
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(bodyWeightGoalList.first.name == 'Body Weight'
                                ? bodyWeight!.toDouble().toString()
                                : bodyWeight!.toDouble().toString()),
                            Text(' / '),
                            Text(bodyWeightGoalList.first.goal.toString()),
                            Text('kg'),
                          ],
                        ),
                        if (bodyWeightGoalList.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                allTranslations.text('bodyweight')!,
                                style: TextStyle(fontSize: 16),
                              ),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: GoalProgressBarWidget(
                                    data1: (bodyWeightGoalList.first.initial! -
                                                    bodyWeight!.toDouble())
                                                .abs() ==
                                            0
                                        ? 1
                                        : (bodyWeightGoalList.first.initial! -
                                                bodyWeight!.toDouble())
                                            .abs(),
                                    data2: (bodyWeightGoalList.first.goal! -
                                            bodyWeightGoalList.first.initial!)
                                        .abs(),
                                  )),
                            ],
                          )
                      ],
                    ),
                  ],
                ),
              _buildChoiceChips(),
              SizedBox(height: 15),
              Text(
                allTranslations.text('bodyweight')!,
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(height: 10),
              Text(
                'Successful weight management is a lifestyle. Any healthy weight management plan should incorporate the principles of healthy eating and active living. These habits should become something you grow to enjoy and can include in your daily life. Changing your diet alone or becoming more physically active without managing your food intake will not be as effective as doing both at the same time. However, it does not mean that if you are overweight, you are unhealthy. Another way to confirm it is by checking your bodyfat%.',
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
                                    ' ' +
                                    measurement,
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
