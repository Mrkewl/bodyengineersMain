import '../../model/program/workout.dart';
import '../../model/watch/garmin.dart';
import '../../model/watch/watch_model.dart';
import '../../screen/widget/calendar/calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../be_theme.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class Vo2Max extends StatefulWidget {
  @override
  _Vo2MaxState createState() => _Vo2MaxState();
}

class _Vo2MaxState extends State<Vo2Max> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  MyTheme theme = MyTheme();
  List<Garmin> garminList = [];
  UserObject? user;
  AnimationController? _animationController;
  // CalendarController _calendarController;
  List<DateTime> visibleDays = [];
  // CalendarController _calendarControllerMonth;
  Map<DateTime, List<Workout>> _events = {};
  DateTime? selectedDay;
  DateTime? firstDay;
  DateTime? lastDay;
  String format = 'dd MMMM yyyy';

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
    user = Provider.of<UserModel>(context, listen: true).user;
    garminList =
        Provider.of<WatchModel>(context, listen: true).garminDataList == null
            ? []
            : Provider.of<WatchModel>(context, listen: true)
                .garminDataList!
                .where((element) => element.vo2Max != null)
                .toList();
    List<Garmin> listviewGarminList = [];

    // bulk edit //print(garminList);
    if (firstDay != null && lastDay != null && garminList.isNotEmpty) {
      setState(() {
        listviewGarminList = garminList
            .where((element) =>
                element.date!.isAfter(firstDay!) &&
                element.date!.isBefore(lastDay!))
            .toList();
      });
    } else if (garminList.isNotEmpty) {
      setState(() {
        listviewGarminList = garminList;
      });
    }
    listviewGarminList.sort((a, b) => a.date!.compareTo(b.date!));
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
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 1, color: Colors.black45),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                spreadRadius: 3,
              ),
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
                        'Vo2Max',
                        style: TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: [
                          Text(
                            selectedDay != null
                                ? intl.DateFormat(format)
                                        .format(firstDay!)
                                        .toString() +
                                    ' - ' +
                                    intl.DateFormat(format)
                                        .format(lastDay!)
                                        .toString()
                                : 'All',
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(width: 3),
                          GestureDetector(
                            onTap: () {
                              return showCalendarDialog(context);
                            },
                            child: Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Back',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                'Vo2 Max',
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(height: 10),
              Text(
                'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est eopksio laborum. Sed ut perspiciatis unde omnis istpoe natus error sit voluptatem accusantium doloremque eopsloi laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunot explicabo. ',
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
              SizedBox(height: 20),
              if (listviewGarminList.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 5,
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
                                  garminList[index].date!.day.toString() +
                                      '.' +
                                      garminList[index].date!.month.toString() +
                                      '.' +
                                      garminList[index].date!.year.toString(),
                                  style: TextStyle(fontSize: 15),
                                ),
                                Text(
                                  garminList[index].vo2Max.toString() +
                                      ' ml/kg/min',
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
