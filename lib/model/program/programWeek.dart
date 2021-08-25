import 'dart:convert' as convert;

import '../../model/program/programDay.dart';

class ProgramWeek {
  String? weekNumber;
  List<ProgramDay> weekDays = [];
  DateTime? startDate; // Only create new program
  DateTime? endDate; // Only create new program
  int maxDay = 0; // Only create new program
  ProgramWeek.fromMysqlDatabase(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      weekNumber = json['week_number'];
      for (var day in convert.jsonDecode(json['week_json'])) {
        weekDays.add(ProgramDay.fromMysqlDatabase(day));
      }
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }

  DateTime? getStartDate() {
    DateTime? start;

    if (weekDays.isNotEmpty) {
      weekDays.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
      DateTime end;
      switch (weekDays.first.dateTime!.weekday) {
        case 1:
          start = weekDays.first.dateTime;
          break;
        case 2:
          start = weekDays.first.dateTime!.subtract(Duration(days: 1));
          break;
        case 3:
          start = weekDays.first.dateTime!.subtract(Duration(days: 2));
          break;
        case 4:
          start = weekDays.first.dateTime!.subtract(Duration(days: 3));
          break;
        case 5:
          start = weekDays.first.dateTime!.subtract(Duration(days: 4));
          break;
        case 6:
          start = weekDays.first.dateTime!.subtract(Duration(days: 5));
          break;
        case 7:
          start = weekDays.first.dateTime!.subtract(Duration(days: 6));
          break;
      }
    }

    return start;
  }

  ProgramWeek();
  @override
  String toString() => 'ProgramWeek { weekDays: $weekDays }';
}
