import '../../../model/planner/bodystatsDay.dart';
import '../../../model/planner/planner_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../be_theme.dart';
import '../../../model/program/programDay.dart';
import '../../../translations.dart';
import './popup_menu.dart';
import './three_dots_menu.dart';

// ignore: must_be_immutable
class PlannerDayItem extends StatefulWidget {
  List<ProgramDay>? programDay;
  List<BodystatsDay?>? dateBodyStats;
  Function? changeDayCallBack;
  Function? callbackProgramDay;
  Function? quickWorkoutCallback;
  Function? achievementCallback;
  DateTime? dateTime;
  bool? isDashboard = false;
  PlannerDayItem(
      {this.programDay,
      this.dateBodyStats,
      this.changeDayCallBack,
      this.achievementCallback,
      this.callbackProgramDay,
      this.quickWorkoutCallback,
      this.isDashboard,
      this.dateTime});
  @override
  _PlannerDayItemState createState() => _PlannerDayItemState();
}

class _PlannerDayItemState extends State<PlannerDayItem>
    with TickerProviderStateMixin {
  // bool dayCompleted = false;

  late var _clickPosition;
  var _count = 0;
  MyTheme theme = MyTheme();

  @override
  void initState() {
    super.initState();
  }

  void _showPopupMenu() {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    showMenu(
            context: context,
            items: <PopupMenuEntry<int>>[
              PopupMenu(
                quickWorkoutCallback: widget.quickWorkoutCallback,
                dateTime: widget.dateTime,
              )
            ],
            position: RelativeRect.fromRect(_clickPosition & const Size(40, 40),
                Offset.zero & overlay.size))
        .then<void>((int? delta) {
      if (delta == null) return;
      setState(() {
        _count = _count + delta;
      });
    });
  }

  void _storePopupPosition(TapDownDetails details) {
    _clickPosition = details.globalPosition;
  }

  bool accepted = false;
  @override
  Widget build(BuildContext context) {
    return DragTarget(
      onWillAccept: (ProgramDay? data) {
        // bulk edit //print('onWillAccept');
        // bulk edit //print('data.dateTime ==>');
        // bulk edit //print(data.dateTime);
        // bulk edit //print('widget.programDay ==>');
        // // bulk edit //print(programDay.dateTime);
        if (data!.dateTime != widget.dateTime && data.isDayCompleted != true) {
          // bulk edit //print('KABUL ETTİK!');
          return true;
        } else {
          // bulk edit //print('KABUL ETMEDİ ÇÜNKÜ AYNI GÜN!');

          return false;
        }
      },
      onAccept: (ProgramDay programDay) {
        widget.changeDayCallBack!(programDay, widget.dateTime);
      },
      onMove: (DragTargetDetails details) {},
      // onMove: (DragTargetDetails details) {
      //   // bulk edit //print('onMove');

      //   // bulk edit //print(details.data);
      //   // bulk edit //print(details.offset);
      // },
      builder: (context, List<ProgramDay?> candidateData, rejectedData) =>
          GestureDetector(
        onTap: _showPopupMenu,
        onTapDown: _storePopupPosition,
        child: Container(
          color: theme.currentTheme() == ThemeMode.dark
              ? Colors.grey[850]
              : Colors.grey[50],
          child: Column(
            children: [
              Divider(
                thickness: 2,
              ),
              if (!widget.isDashboard!)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE').format(widget.dateTime!),
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      DateFormat('d MMMM y', 'en_US').format(widget.dateTime!),
                    ),
                  ],
                ),
              SizedBox(height: 15),
              candidateData.isEmpty
                  ? Container()
                  : Container(
                      height: 40,
                    ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.programDay!.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (ctx, index) {
                    // if (widget.programDay[index] == null)

                    if (widget.programDay![index] != null) {
                      return Column(
                        children: [
                          AnimatedSize(
                            duration: Duration(milliseconds: 100),
                            vsync: this,
                            child: candidateData.isEmpty
                                ? Container()
                                : Opacity(
                                    opacity: 0.0,
                                    child: PlannerDayElement(
                                      programDay: widget.programDay![index],
                                      callbackProgramDay:
                                          widget.callbackProgramDay,
                                      achievementCallback:
                                          widget.achievementCallback,
                                    ),
                                  ),
                          ),
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

                    // return PlannerDayElement(
                    //   programDay: widget.programDay[index],
                    //   callbackProgramDay: widget.callbackProgramDay,
                    // );
                  }),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.dateBodyStats!.length,
                  itemBuilder: (ctx, index) {
                    return BodystatsElement(widget.dateBodyStats![index]);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class BodystatsElement extends StatelessWidget {
  BodystatsDay? bodystatsDay;
  BodystatsElement(this.bodystatsDay);

  surePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Bodystats"),
          content: Text('Are you sure to delete bodystats?'),
          actions: [
            FlatButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text(
                "Delete",
                style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
              ),
              onPressed: () {
                Provider.of<PlannerModel>(context, listen: false)
                    .deleteBodyStatsDay(bodystatsDay: bodystatsDay);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

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
            width: MediaQuery.of(context).size.width * 0.91,
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
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.025),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            allTranslations.text('body_stats')!,
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
                if (!bodystatsDay!.isInitialBodyStat)
                  GestureDetector(
                    onTap: () => surePopup(context),
                    child: Icon(
                      Icons.remove_circle_outline_sharp,
                      color: Color(0xffd6d6d6),
                    ),
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
  late var _tapPosition;
  var _count = 0;
  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  void _showThreeDotsMenu() {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    showMenu(
            context: context,
            items: <PopupMenuEntry<int>>[
              ThreeDotsMenu(
                  programDay: widget.programDay,
                  callbackProgramDay: widget.callbackProgramDay)
            ],
            position: RelativeRect.fromRect(
                _tapPosition & const Size(40, 40), Offset.zero & overlay.size))
        .then<void>((int? delta) {
      if (delta == null) return;
      setState(() {
        _count = _count + delta;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Draggable(
        onDraggableCanceled: (velocity, offset) {
          // bulk edit //print(velocity);
          // bulk edit //print(offset);
        },
        // axis: Axis.vertical,
        onDragStarted: () {
          // bulk edit //print('Drag Started');
        },
        onDragEnd: (DraggableDetails details) {
          // bulk edit //print(details.wasAccepted);
          // bulk edit //print(details.velocity);
          // bulk edit //print(details.offset);
          if (widget.programDay!.isDayCompleted == true)
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text(allTranslations.text('cant_move')!),
            ));
        },
        onDragCompleted: () {
          // bulk edit //print('On Drag Completed');
        },
        data: widget.programDay,
        childWhenDragging: Container(),
        feedback: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Material(
            type: MaterialType.card,
            elevation: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      widget.programDay!.isDayCompleted
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: widget.programDay!.isDayCompleted
                          ? Color.fromRGBO(8, 112, 138, 1)
                          : Colors.grey,
                      size: 40,
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.025),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/workout_log',
                            arguments: {
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
                GestureDetector(
                  onTap: _showThreeDotsMenu,
                  onTapDown: _storePosition,
                  child: Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
        ),
        child: Container(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/workout_log',
                              arguments: {
                                'programDay': widget.programDay,
                                'achievementCallback':
                                    widget.achievementCallback
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
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.025),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/workout_log',
                              arguments: {
                                'programDay': widget.programDay,
                                'achievementCallback':
                                    widget.achievementCallback
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
                GestureDetector(
                  onTap: _showThreeDotsMenu,
                  onTapDown: _storePosition,
                  child: Icon(Icons.more_vert),
                ),
              ],
            ),
            SizedBox(
                height: widget.programDay != null
                    ? widget.programDay!.isBodyStatsDay!
                        ? 5
                        : 0
                    : 0),
            SizedBox(height: 5),
            Visibility(
              visible: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Row(
                      children: [
                        Icon(
                          caloriesCompleted ? Icons.check_circle : Icons.cancel,
                          color: caloriesCompleted
                              ? Color.fromRGBO(8, 112, 138, 1)
                              : Colors.grey,
                          size: 40,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.025),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              allTranslations.text('target_calories')!,
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              '2300Kcal',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ));
  }
}
