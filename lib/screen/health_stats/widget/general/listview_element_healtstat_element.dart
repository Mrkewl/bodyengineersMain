import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

class ListViewElementHealtStatElement extends StatelessWidget {
  final DateTime? garminDate;
  final String? garminValueString;

  ListViewElementHealtStatElement({this.garminDate, this.garminValueString});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  garminDate!.day.toString() +
                      ' ' +
                      intl.DateFormat('MMM').format(garminDate!).toString() +
                      ' ' +
                      garminDate!.year.toString(),
                  style: TextStyle(fontSize: 15),
                ),
                Text(
                  garminValueString!,
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
