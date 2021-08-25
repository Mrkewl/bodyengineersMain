import 'package:bodyengineer/model/watch/watch_data.dart';

import '../../model/program/workout.dart';

import '../../model/watch/watch_model.dart';
import '../../screen/health_stats/widget/detail/sleep_detail_chart.dart';
import '../../screen/health_stats/widget/general/listview_element_healthstat_detail.dart';
import '../../screen/widget/calendar/calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../be_theme.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class SleepStats extends StatefulWidget {
  @override
  _SleepStatsState createState() => _SleepStatsState();
}

class _SleepStatsState extends State<SleepStats> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  MyTheme theme = MyTheme();

  List<WatchDataObject> watchDataList = [];
  AnimationController? _animationController;
  // CalendarController _calendarController;
  List<DateTime> visibleDays = [];
  // CalendarController _calendarControllerMonth;
  Map<DateTime, List<Workout>> _events = {};
  DateTime? selectedDay;
  DateTime? firstDay;
  DateTime? lastDay;
  String format = 'dd MMMM yyyy';

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
  //               // Positioned(
  //               //   right: 1,
  //               //   bottom: 1,
  //               //   child: _buildEventsMarker(date, events),
  //               // ),
  //             );
  //           }

  //           if (holidays.isNotEmpty) {
  //             children.add(
  //               Container(),

  //               // Positioned(
  //               //   right: -2,
  //               //   top: -2,
  //               //   child: _buildHolidaysMarker(),
  //               // ),
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
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;

    watchDataList =
        Provider.of<WatchModel>(context, listen: true).watchDataList == null
            ? []
            : Provider.of<WatchModel>(context, listen: true)
                .watchDataList!
                .where((element) => element.sleep != null)
                .toList();
    List<WatchDataObject> listviewWatchDataObjectList = [];

    // bulk edit //print(garminList);
    if (firstDay != null && lastDay != null && watchDataList.isNotEmpty) {
      setState(() {
        listviewWatchDataObjectList = watchDataList
            .where((element) =>
                element.date!.isAfter(firstDay!) &&
                element.date!.isBefore(lastDay!))
            .toList();
      });
    } else if (watchDataList.isNotEmpty) {
      setState(() {
        listviewWatchDataObjectList = watchDataList;
      });
    }
    listviewWatchDataObjectList.sort((a, b) => a.date!.compareTo(b.date!));

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
                        allTranslations.text('sleep')!,
                        style: TextStyle(fontSize: 16),
                      ),
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
              if (watchDataList.isNotEmpty) SleepDetailChart(),
              _buildChoiceChips(),
              SizedBox(height: 15),
              Text(
                allTranslations.text('sleep')!,
                style: TextStyle(fontSize: 17),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  allTranslations.text('benefits')! + ': ',
                  style: TextStyle(
                      color: theme.currentTheme() == ThemeMode.dark
                          ? Colors.white
                          : Colors.black54,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                """
∙ Better Reaction Time
∙ Improved Motor Function
∙ Higher Motivation
∙ More Focus
∙ Stress Regulation
∙ Muscle Recovery
∙ Sprint Performance
∙ Improve Memory and Learning
∙ Reduce Injury Risk
∙ Reduce Illness Rates
∙ Reduce Unwanted Weight Gain
                """,
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
              SizedBox(height: 15),
              ListViewElementHealthStatDetail(
                watchDataList: watchDataList,
                firstDay: firstDay,
                lastDay: lastDay,
                filterBy: 'hrs',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
