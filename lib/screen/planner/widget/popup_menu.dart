import '../../../model/planner/bodystatsDay.dart';
import '../../../model/planner/planner_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class PopupMenu extends PopupMenuEntry<int> {
  Function? quickWorkoutCallback;
  DateTime? dateTime;
  PopupMenu({this.quickWorkoutCallback, this.dateTime});
  @override
  double height = 100;

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  PopupMenuState createState() => PopupMenuState();
}

class PopupMenuState extends State<PopupMenu> {
  BodystatsDay? bodystatsDay;
  @override
  Widget build(BuildContext context) {
    if (Provider.of<PlannerModel>(context)
        .bodystatsDayList
        .where((element) =>
            element!.dateTime ==
            DateTime(widget.dateTime!.year, widget.dateTime!.month,
                widget.dateTime!.day))
        .isNotEmpty)
      bodystatsDay = Provider.of<PlannerModel>(context)
          .bodystatsDayList
          .firstWhere((element) =>
              element!.dateTime ==
              DateTime(widget.dateTime!.year, widget.dateTime!.month,
                  widget.dateTime!.day));
    return Column(
      children: <Widget>[
        if (Provider.of<PlannerModel>(context, listen: false)
                .plannerMainProgram !=
            null)
          GestureDetector(
            onTap: () {
              Navigator.pop(context);

              Navigator.pushNamed(context, '/add_workout',
                  arguments: {'dateTime': widget.dateTime});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Workout'),
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
            // bulk edit //print('Quick Workout Tapped');
            widget.quickWorkoutCallback!(widget.dateTime);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Quick Workout'),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                ),
                Icon(Icons.add),
              ],
            ),
          ),
        ),
        if (bodystatsDay == null)
          GestureDetector(
            onTap: () {
              // bulk edit //print('Add Bodystats Tapped');
              Provider.of<PlannerModel>(context, listen: false)
                  .addBodyStatsDay(dateTime: widget.dateTime);
              Navigator.pop(context);
              // Navigator.pushNamed(context, '/bs_menu',
              //     arguments: {'selectedDate': widget.dateTime});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Bodystats'),
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
