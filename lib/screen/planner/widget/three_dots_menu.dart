import '../../../model/program/programDay.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ThreeDotsMenu extends PopupMenuEntry<int> {
  @required
  ProgramDay? programDay;
  Function? callbackProgramDay;
  ThreeDotsMenu({this.programDay, this.callbackProgramDay});

  @override
  double height = 100;

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  PopupMenuState createState() => PopupMenuState();
}

class PopupMenuState extends State<ThreeDotsMenu> {
  removePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove Program Day"),
          content: Text(
              "If you remove this day, you won't be able to reach it again. You can just reschedule it instead of removing. Still do you want to remove it?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Remove"),
              onPressed: () {
                widget.callbackProgramDay!(widget.programDay, false);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            // bulk edit //print('Edit Tapped');
            Navigator.pop(context);

            Navigator.pushNamed(context, '/workout_log',
                arguments: {'programDay': widget.programDay});
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
            Navigator.pop(context);
            removePopup(context);
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
        if (widget.programDay!.isDayCompleted != true)
          GestureDetector(
            onTap: () {
              // bulk edit //print('Reschedule Tapped');
              Navigator.pop(context);

              widget.callbackProgramDay!(widget.programDay, true);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reschedule'),
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
