import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class WeekCalendarWidget extends StatefulWidget {
  Function? selectedDayCallback;
  Function? visibleDayChanged;
  DateTime? selectedDay;
  DateTime? startDay;
  AnimationController? animationController;
  WeekCalendarWidget(
      {this.visibleDayChanged,
      this.selectedDayCallback,
      this.selectedDay,
      this.startDay,
      this.animationController});
  @override
  _WeekCalendarWidgetState createState() => _WeekCalendarWidgetState();
}

class _WeekCalendarWidgetState extends State<WeekCalendarWidget> {
  List<DateTime> visibleDays = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: TableCalendar(
        firstDay: DateTime(2000, 1, 1),
        lastDay: DateTime(2100, 1, 1),
        locale: 'en_EN',
        calendarFormat: CalendarFormat.week,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableGestures: AvailableGestures.all,
        availableCalendarFormats: const {
          CalendarFormat.week: '',
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle().copyWith(
            color: Colors.black,
            fontFamily: 'Lato',
            fontSize: 17,
          ),
          holidayTextStyle: TextStyle().copyWith(
            color: Colors.black,
            fontFamily: 'Lato',
            fontSize: 17,
          ),
          outsideTextStyle: TextStyle().copyWith(
            color: Colors.black,
            fontFamily: 'Lato',
            fontSize: 17,
          ),
          disabledTextStyle: TextStyle().copyWith(
            color: Colors.black,
            fontFamily: 'Lato',
            fontSize: 17,
          ),
          defaultTextStyle: TextStyle().copyWith(
            color: Colors.black,
            fontFamily: 'Lato',
            fontSize: 17,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          dowTextFormatter: (dateTime, dynamics) {
            return DateFormat('E').format(dateTime).characters.first;
          },
          weekendStyle: TextStyle()
              .copyWith(color: Colors.black, fontFamily: 'Lato', fontSize: 16),
          weekdayStyle: TextStyle().copyWith(fontFamily: 'Lato', fontSize: 16),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(fontFamily: 'Lato', fontSize: 17),
        ),
        onPageChanged: (date) {
          print(date);
          visibleDays = [];
          widget.selectedDayCallback!(date);
          DateTime? start;
          for (var i = 0; i < 7; i++) {
            if (date.subtract(Duration(days: i)).weekday == 1) {
              start = date.subtract(Duration(days: i));
            }
          }

          for (var i = 0; i < 7; i++) {
            visibleDays.add(start!.add(Duration(days: i)));
          }
          widget.visibleDayChanged!(visibleDays);
        },
        focusedDay: widget.selectedDay!,
        selectedDayPredicate: (day) {
          // Use `selectedDayPredicate` to determine which day is currently selected.
          // If this returns true, then `day` will be marked as selected.

          // Using `isSameDay` is recommended to disregard
          // the time-part of compared DateTime objects.
          return isSameDay(widget.selectedDay, day);
        },
        calendarBuilders: CalendarBuilders(
          selectedBuilder: (context, date, _) {
            return FadeTransition(
              opacity: Tween(begin: 0.0, end: 1.0)
                  .animate(widget.animationController!),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4.0),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(86, 177, 191, 1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle().copyWith(
                    fontSize: 17,
                    color: Colors.white,
                    fontFamily: 'Lato',
                  ),
                ),
              ),
            );
          },
          todayBuilder: (context, date, _) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(4.0),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 17,
                ),
              ),
            );
          },
          defaultBuilder: (context, date, _) {
            return Container(
              alignment: Alignment.center,
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 17,
                ),
              ),
            );
          },
          markerBuilder: (context, date, holidays) {
            final children = <Widget>[];

            // if (events.isNotEmpty) {
            //   children.add(
            //     Container(),
            //   );
            // }

            if (holidays.isNotEmpty) {
              children.add(
                Container(),
              );
            }

            return Column(
              children: children,
            );
          },
        ),
        onDaySelected: (date, _selectedDay) {
          widget.animationController!.forward(from: 0.0);
          setState(() {
            widget.selectedDay = date;
          });
          widget.selectedDayCallback!(widget.selectedDay);
        },
        enabledDayPredicate: (date) {
          print(date);
          // visibleDays.add(date);

          // widget.visibleDayChanged!(visibleDays);

          return true;
        },
      ),
    );
  }
}
