import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  Function? selectedDayCallback;
  DateTime? selectedDay;
  AnimationController? animationController;
  bool? selectWholeWeek = false;
  CalendarWidget(
      {this.selectedDayCallback,
      this.selectedDay,
      this.animationController,
      this.selectWholeWeek});
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
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
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableGestures: AvailableGestures.all,
        availableCalendarFormats: const {
          CalendarFormat.month: '',
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: TextStyle().copyWith(
            color: Colors.blue[800],
            fontFamily: 'Lato',
            fontSize: 16,
          ),
          holidayTextStyle: TextStyle().copyWith(
            color: Colors.blue[800],
            fontFamily: 'Lato',
            fontSize: 16,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekendStyle: TextStyle().copyWith(
            color: Colors.blue[600],
            fontFamily: 'Lato',
            fontSize: 16,
          ),
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(
            fontFamily: 'Lato',
            fontSize: 19,
          ),
        ),
        focusedDay: widget.selectedDay ?? DateTime.now(),
        selectedDayPredicate: (day) {
          // Use `selectedDayPredicate` to determine which day is currently selected.
          // If this returns true, then `day` will be marked as selected.

          // Using `isSameDay` is recommended to disregard
          // the time-part of compared DateTime objects.
          return isSameDay(widget.selectedDay, day);
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, date, _) {
            if (widget.selectWholeWeek != null && widget.selectWholeWeek!) {
              DateTime? focusedDay = widget.selectedDay ?? DateTime.now();
              switch (focusedDay.weekday) {
                case 1:
                  if (date.isAfter(focusedDay) &&
                      date.difference(focusedDay).inDays < 7)
                    return FadeTransition(
                        opacity: Tween(begin: 0.0, end: 1.0)
                            .animate(widget.animationController!),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 7.0),
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(86, 177, 191, 0.6),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle().copyWith(fontSize: 16.0),
                          ),
                        ));
                  break;
                case 2:
                  if (date.isBefore(focusedDay) &&
                          date.difference(focusedDay).inDays == -1 ||
                      date.isAfter(focusedDay) &&
                          date.difference(focusedDay).inDays < 6)
                    return FadeTransition(
                        opacity: Tween(begin: 0.0, end: 1.0)
                            .animate(widget.animationController!),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 7),
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(86, 177, 191, 0.6),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle().copyWith(fontSize: 16.0),
                          ),
                        ));
                  break;
                case 3:
                  if (date.isBefore(focusedDay) &&
                          date.difference(focusedDay).inDays >= -2 ||
                      date.isAfter(focusedDay) &&
                          date.difference(focusedDay).inDays < 5)
                    return FadeTransition(
                        opacity: Tween(begin: 0.0, end: 1.0)
                            .animate(widget.animationController!),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 7),
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(86, 177, 191, 0.6),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle().copyWith(fontSize: 16.0),
                          ),
                        ));
                  break;
                case 4:
                  if (date.isBefore(focusedDay) &&
                          date.difference(focusedDay).inDays >= -3 ||
                      date.isAfter(focusedDay) &&
                          date.difference(focusedDay).inDays < 4)
                    return FadeTransition(
                        opacity: Tween(begin: 0.0, end: 1.0)
                            .animate(widget.animationController!),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 7),
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(86, 177, 191, 0.6),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle().copyWith(fontSize: 16.0),
                          ),
                        ));
                  break;

                case 5:
                  if (date.isBefore(focusedDay) &&
                          date.difference(focusedDay).inDays >= -4 ||
                      date.isAfter(focusedDay) &&
                          date.difference(focusedDay).inDays < 3)
                    return FadeTransition(
                        opacity: Tween(begin: 0.0, end: 1.0)
                            .animate(widget.animationController!),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 7),
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(86, 177, 191, 0.6),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle().copyWith(fontSize: 16.0),
                          ),
                        ));
                  break;
                case 6:
                  if (date.isBefore(focusedDay) &&
                          date.difference(focusedDay).inDays >= -5 ||
                      date.isAfter(focusedDay) &&
                          date.difference(focusedDay).inDays == 1)
                    return FadeTransition(
                        opacity: Tween(begin: 0.0, end: 1.0)
                            .animate(widget.animationController!),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 7),
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(86, 177, 191, 0.6),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle().copyWith(fontSize: 16.0),
                          ),
                        ));
                  break;
                case 7:
                  if (date.isBefore(focusedDay) &&
                          date.difference(focusedDay).inDays >= -6 ||
                      date.isAfter(focusedDay) &&
                          date.difference(focusedDay).inDays == 0)
                    return FadeTransition(
                        opacity: Tween(begin: 0.0, end: 1.0)
                            .animate(widget.animationController!),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 7),
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(86, 177, 191, 0.6),
                            borderRadius: BorderRadius.circular(35),
                          ),
                          child: Text(
                            '${date.day}',
                            style: TextStyle().copyWith(fontSize: 16.0),
                          ),
                        ));
                  break;
              }
            } else {
              return FadeTransition(
                opacity: Tween(begin: 0.0, end: 1.0)
                    .animate(widget.animationController!),
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 7),
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle().copyWith(fontSize: 16.0),
                  ),
                ),
              );
            }

            return FadeTransition(
              opacity: Tween(begin: 0.0, end: 1.0)
                  .animate(widget.animationController!),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4.0),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle().copyWith(fontSize: 16.0),
                ),
              ),
            );
          },
          selectedBuilder: (context, date, _) {
            return FadeTransition(
              opacity: Tween(begin: 0.0, end: 1.0)
                  .animate(widget.animationController!),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 7),
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(8, 112, 138, 1),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle().copyWith(
                    color: Colors.white,
                    fontFamily: 'Lato',
                    fontSize: 17,
                  ),
                ),
              ),
            );
          },
          todayBuilder: (context, date, _) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 7),
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: Color.fromRGBO(86, 177, 191, 1),
                borderRadius: BorderRadius.circular(35),
              ),
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(
                  fontFamily: 'Lato',
                  fontSize: 17,
                  color: Colors.white,
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
      ),
    );
  }
}
