import '../../helper/sqflite_helper.dart';
import '../../model/goal/body_goal.dart';
import '../../model/goal/exercise_goal.dart';
import '../../model/planner/bodystatsDay.dart';
import '../../model/planner/exercise_history.dart';
import '../../model/program/program.dart';
import '../../model/program/programDay.dart';
import '../../model/program/programPhase.dart';
import '../../model/program/programWeek.dart';
import '../../services/index.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;

import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel with ChangeNotifier {
  final Services _service = Services();
  final _sqfLiteDatabase = SqfliteHelper.instance;
  final LocalStorage storage = LocalStorage('bodyengineer');
  late SharedPreferences prefs;

  List<ExerciseGoal> exerciseGoalList = [];
  List<BodyGoal> bodyGoalList = [];
  List<ProgramDay> programDayList = [];
  List<BodystatsDay> bodystatsDayList = [];
  List<ExerciseHistoryElement> exerciseHistory = [];
  Map<String, dynamic> transferableData = {};
  bool isCompleted = false;
  SettingsModel() {
    appInit();
  }

  Future<void> appInit() async {
    await dataTransferProcess();
    isCompleted = true;
    notifyListeners();
  }

  dataTransferProcess() async {
    prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('transfer_data_date') ?? null;
    DateTime? transferDataDate;
    if (data != null) {
      transferDataDate = DateTime.parse(data);
    }
    int difference = Duration(days: 5).inHours;
    if (transferDataDate != null)
      difference = transferDataDate.difference(DateTime.now()).inHours.abs();
    print(difference);
    if (transferDataDate == null || difference > Duration(days: 4).inHours)
      prepareData()
        ..then((value) async {
          await prepareDataForMysql().then((value) async {
            await transferData();
          });
        });
  }

  Future<void> prepareData() async {
    await getGoalsHistories().then((value) async {
      // bulk edit //print(exerciseGoalList);
      // bulk edit //print(bodyGoalList);
      await getUserDataSqflite().then((value) async {
        // bulk edit //print(programDayList);
        await getBodystatDays().then((value) async {
          // bulk edit //print(bodystatsDayList);
          await getExerciseHistories().then((value) async {
            // bulk edit //print(exerciseHistory);
          });
        });
      });
    });
  }

  Future<void> prepareDataForMysql() async {
    transferableData = {};

    transferableData['goals'] = [exerciseGoalList, bodyGoalList];
    transferableData['planner'] = programDayList;
    transferableData['bodystats'] = bodystatsDayList;
    transferableData['exercise_history'] = exerciseHistory;
  }

  Future<void> transferData() async {
    prefs = await SharedPreferences.getInstance();
    DateTime? result;
    if (transferableData.isNotEmpty)
      result = await _service.phpTransferLocalDataToServer(transferableData);
    if (result != null) {
      // bulk edit //print(result);
      prefs.setString('transfer_data_date', result.toString());
    }
  }

  Future<void> getGoalsHistories() async {
    // bulk edit //print('Get Planner Program');
    List<Map<String, dynamic>>? goalsRaw = [];
    goalsRaw = await _sqfLiteDatabase.goalsQueryAllRows();
    // bulk edit //print(goalsRaw);
    if (goalsRaw != null) {
      goalsRaw.forEach((element) {
        // bulk edit //print(element);
        for (var item in convert.jsonDecode(element['json'])) {
          Map<String, dynamic> json = convert.jsonDecode(item);
          if (json['exerciseId'] != null) {
            exerciseGoalList.add(ExerciseGoal.fromJson(json));
          } else {
            bodyGoalList.add(BodyGoal.fromJson(json));
          }
        }
      });
      notifyListeners();
    }
  }

  Future<void> getUserDataSqflite() async {
    List<Map<String, dynamic>>? userDataSqflite = [];
    userDataSqflite = await _sqfLiteDatabase.userDataQueryAllRows();
    print(userDataSqflite);
    if (userDataSqflite != null) {
      userDataSqflite.forEach((data) {
        try {
          Map<String, dynamic> decodedData = convert.jsonDecode(data['json']);
          for (var item in decodedData['programDayList']) {
            programDayList.add(ProgramDay.fromLocalJson(item));
          }
        } catch (e) {
          print(e.toString());
        }
      });
      notifyListeners();
    }
  }

  Future<void> getPlannerProgram() async {
    // // bulk edit //print('Get Planner Program');
    // programDayList = [];
    // List<Map<String, dynamic>>? plannerProgramRaw = [];
    // plannerProgramRaw = await _sqfLiteDatabase.plannerQueryAllRows();
    // // bulk edit //print(plannerProgramRaw);
    // if (plannerProgramRaw != null) {
    //   plannerProgramRaw.forEach((element) {
    //     if (element['isActive'] == 1) {
    //       for (var item in convert.jsonDecode(element['json'])) {
    //         programDayList.add(ProgramDay.fromLocalJson(
    //             convert.jsonDecode(item),
    //             element['isAddon'] == 1 ? true : false));
    //       }
    //     }
    //   });
    // }
  }

  Future<void> getBodystatDays() async {
    // bulk edit //print('Get Planner Program');
    List<Map<String, dynamic>>? bodystatRaw = [];
    bodystatRaw = await _sqfLiteDatabase.bodystatsQueryAllRows();
    // bulk edit //print(bodystatRaw);
    if (bodystatRaw != null) {
      bodystatRaw.forEach((element) {
        // bulk edit //print(element);
        for (var item in convert.jsonDecode(element['json'])) {
          bodystatsDayList
              .add(BodystatsDay.fromLocalJson(convert.jsonDecode(item)));
        }
      });
      notifyListeners();
    }
  }

  Future<void> getExerciseHistories() async {
    // bulk edit //print('Get Planner Program');
    List<Map<String, dynamic>>? bodystatRaw = [];
    bodystatRaw = await _sqfLiteDatabase.exerciseHistoryQueryAllRows();
    // bulk edit //print(bodystatRaw);
    if (bodystatRaw != null) {
      bodystatRaw.forEach((element) {
        // bulk edit //print(element);
        for (var item in convert.jsonDecode(element['json'])) {
          exerciseHistory.add(
              ExerciseHistoryElement.fromSqfliteJson(convert.jsonDecode(item)));
        }
      });
      notifyListeners();
    }
  }

  Program getPlannerAsProgram() {
    Program program = Program();
    if (programDayList.isNotEmpty) {
      program.programId = programDayList.first.programId;
      program.phaseList = [];
      Map<dynamic, List<ProgramDay>> groupByPhase = groupBy(
          programDayList
              .where((element) => element.programId == program.programId)
              .toList(),
          (ProgramDay day) => day.phaseNumber);

      groupByPhase.forEach((phaseNumber, phaseDayList) {
        ProgramPhase programPhase = ProgramPhase();
        programPhase.programId = program.programId;
        programPhase.phaseNumber = phaseNumber;
        programPhase.programWeek = [];

        Map<dynamic, List<ProgramDay>> groupByWeek =
            groupBy(phaseDayList, (ProgramDay day) => day.weekNumber);

        groupByWeek.forEach((weekNumber, weekDayList) {
          ProgramWeek programWeek = ProgramWeek();
          programWeek.weekNumber = weekNumber;
          programWeek.startDate = weekDayList.first.dateTime;
          programWeek.endDate = weekDayList.last.dateTime;
          programWeek.weekDays = weekDayList;

          programPhase.programWeek.add(programWeek);
        });
        program.phaseList.add(programPhase);
      });

      // // bulk edit //print(program);
    }
    return program;
  }
}
