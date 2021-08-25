import '../../../model/planner/bodystatsDay.dart';
import 'package:flutter/material.dart';

import '../../../be_theme.dart';
import '../../../model/program/programDay.dart';
import '../../../translations.dart';

// ignore: must_be_immutable
class DashboardDayItem extends StatefulWidget {
  List<ProgramDay>? programDay;
  List<BodystatsDay?>? dateBodyStats;
  Function? changeDayCallBack;
  Function? callbackProgramDay;
  Function? quickWorkoutCallback;
  Function? achievementCallback;
  DateTime? dateTime;
  DashboardDayItem(
      {this.programDay,
      this.dateBodyStats,
      this.changeDayCallBack,
      this.achievementCallback,
      this.callbackProgramDay,
      this.quickWorkoutCallback,
      this.dateTime});
  @override
  _DashboardDayItemState createState() => _DashboardDayItemState();
}

class _DashboardDayItemState extends State<DashboardDayItem> {
  MyTheme theme = MyTheme();

  @override
  void initState() {
    super.initState();
  }

  bool accepted = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.currentTheme() == ThemeMode.dark
          ? Colors.grey[850]
          : Colors.grey[50],
      child: Column(
        children: [
          MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.programDay!.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (widget.programDay![index] != null) {
                    return Column(
                      children: [
                        PlannerDayElement(
                          programDay: widget.programDay![index],
                          callbackProgramDay: widget.callbackProgramDay,
                          achievementCallback: widget.achievementCallback,
                        )
                      ],
                    );
                  } else {
                    return Container();
                  }
                }),
          ),
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.dateBodyStats!.length,
              itemBuilder: (ctx, index) {
                return BodystatsElement(widget.dateBodyStats![index]);
              }),
        ],
      ),
    );
  }
}

class BodystatsElement extends StatelessWidget {
  BodystatsDay? bodystatsDay;
  BodystatsElement(this.bodystatsDay);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/bs_menu',
            arguments: {'selectedDate': bodystatsDay!.dateTime});
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              children: [
                GestureDetector(
                  child: Icon(
                    bodystatsDay!.isCompleted!
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: bodystatsDay!.isCompleted!
                        ? Color.fromRGBO(8, 112, 138, 1)
                        : Colors.grey,
                    size: 40,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.025),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Body Stats',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      bodystatsDay!.isCompleted!
                          ? allTranslations.text('completed')!
                          : allTranslations.text('not_completed')!,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlannerDayElement extends StatefulWidget {
  ProgramDay? programDay;
  Function? callbackProgramDay;
  Function? achievementCallback;

  PlannerDayElement(
      {this.programDay, this.callbackProgramDay, this.achievementCallback});

  @override
  _PlannerDayElementState createState() => _PlannerDayElementState();
}

class _PlannerDayElementState extends State<PlannerDayElement> {
  bool statsCompleted = false;
  bool caloriesCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/workout_log', arguments: {
                        'programDay': widget.programDay,
                        'achievementCallback': widget.achievementCallback
                      });
                    },
                    child: Icon(
                      widget.programDay!.isDayCompleted
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: widget.programDay!.isDayCompleted
                          ? Color.fromRGBO(8, 112, 138, 1)
                          : Colors.grey,
                      size: 40,
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.025),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/workout_log', arguments: {
                        'programDay': widget.programDay,
                        'achievementCallback': widget.achievementCallback
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.programDay!.name!,
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          widget.programDay!.isDayCompleted
                              ? allTranslations.text('completed')!
                              : allTranslations.text('not_completed')!,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
