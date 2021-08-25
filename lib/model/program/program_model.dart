import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' as convert;
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/index.dart';
import './program.dart';
import './programCategory.dart';
import './programLevel.dart';

import '../../helper/sqflite_helper.dart';
import '../../model/program/exercise.dart';
import '../../model/program/programDay.dart';
import '../../model/program/programPhase.dart';
import '../../model/program/programWeek.dart';
import '../../model/program/workout.dart';

class ProgramModel with ChangeNotifier {
  final Services _service = Services();
  final _sqfLiteDatabase = SqfliteHelper.instance;
  SharedPreferences? sharedPreferences;
  final LocalStorage storage = LocalStorage('bodyengineer');
  // final PlannerModel _plannerModel = PlannerModel();
  ProgramModel() {
    getProgramCategoryList().then((value) async {
      sharedPreferences = await SharedPreferences.getInstance();
      await fetchProgram();
    });
  }
  Program? newProgram;
  List<Program> programList = [];
  List<ProgramCategory> programCategoryList = [];
  List<ProgramLevel> programLevelList = [];
  List<Exercise> allExerciseList = [];
  List<String> bookmarkedIdList = [];
  Future<void> fetchProgram() async {
    await getProgramLevelList().then((value) async {
      await getExerciseList().then((value) async {
        await getProgramList().then((value) async {
          await getBookmarkProgramList();
        });
      });
    });
  }

  // ignore: missing_return
  createNewProgram(
      {DateTime? startDate,
      DateTime? endDate,
      int? durationWeek,
      required int phaseCount,
      List<String>? dayList,
      String? uid}) {
    newProgram = Program();

    newProgram!.programId = '0';
    newProgram!.programDuration = durationWeek;
    newProgram!.startDate = startDate;
    newProgram!.endDate = endDate;
    newProgram!.createdDate = DateTime.now();
    newProgram!.isAddOn = false;
    newProgram!.isFeatured = false;

    newProgram!.phaseList = generateProgramPhases(
        programId: '0',
        dayList: dayList,
        weekDuration: durationWeek,
        startDate: startDate,
        phaseCount: phaseCount,
        uid: uid);

    notifyListeners();
  }

  Future<void> bookmarkProgram(String? programId) async {
    if (bookmarkedIdList.where((element) => element == programId).isNotEmpty) {
      bookmarkedIdList.removeWhere((element) => element == programId);
    } else {
      bookmarkedIdList.add(programId!);
    }
    saveBookmarkProgramList();
    notifyListeners();
  }

  Future<void> saveBookmarkProgramList() async {
    await sharedPreferences!.setStringList('bookmarkProgram', bookmarkedIdList);
    getUserProgramBookmarked();
  }

  Future<void> getBookmarkProgramList() async {
    bookmarkedIdList = [];
    List<dynamic> rawList =
        sharedPreferences!.getStringList('bookmarkProgram') ?? [];
    for (var id in rawList) {
      bookmarkedIdList.add(id.toString());
    }
    notifyListeners();
    getUserProgramBookmarked();
  }

  Future<void> getUserProgramBookmarked() async {
    programList.forEach((element) {
      element.isBookMarked = false;
    });
    if (programList.isNotEmpty) {
      bookmarkedIdList.forEach((element) {
        if (programList
            .where((welement) => welement.programId == element)
            .isNotEmpty)
          programList
              .where((welement) => welement.programId == element)
              .first
              .isBookMarked = true;
      });
      notifyListeners();
    }
  }

  List<ProgramPhase> generateProgramPhases(
      {String? programId,
      DateTime? startDate,
      int? weekDuration,
      String? uid,
      required int phaseCount,
      List<String>? dayList}) {
    List<ProgramPhase> programPhases = [];
    int weekForLoopCount = 0;

    for (var phaseNumber = 0; phaseNumber < phaseCount; phaseNumber++) {
      ProgramPhase programPhase = ProgramPhase();
      programPhase.phaseNumber = phaseNumber.toString();
      programPhase.programId = programId;
      List<ProgramWeek> programWeeks = [];

      for (var weekNumber = 0;
          weekNumber < (weekDuration! / phaseCount);
          weekNumber++) {
        ProgramWeek programWeek = ProgramWeek();
        programWeek.weekNumber = weekNumber.toString();
        programWeek.startDate =
            startDate!.add(Duration(days: (7 * (weekForLoopCount))));
        programWeek.endDate = programWeek.startDate!.add(Duration(days: 6));
        weekForLoopCount++;
        programWeek.maxDay = dayList!.length;
        int forLoopCount = 1;
        for (var i = 0;
            i <= programWeek.endDate!.difference(programWeek.startDate!).inDays;
            i++) {
          DateTime date = programWeek.startDate!.add(Duration(days: i));
          if (dayList.contains(date.weekday.toString())) {
            ProgramDay programDay = generateProgramDay(
                countDay: forLoopCount,
                programId: programId,
                uid: uid,
                date: date);
            programWeek.weekDays.add(programDay);
            forLoopCount++;
          }
        }
        programWeeks.add(programWeek);
      }
      programPhase.programWeek = programWeeks;
      programPhases.add(programPhase);
    }
    return programPhases;
  }

  ProgramDay generateProgramDay(
      {DateTime? date, String? programId, int? countDay, String? uid}) {
    ProgramDay programDay = ProgramDay();
    programDay.dateTime = date;
    programDay.name = 'Day ' + countDay.toString();
    programDay.countDay = countDay;
    programDay.programId = programId;
    programDay.uid = uid;

    return programDay;
  }

  void deleteWorkoutFromNewProgram(Workout? workout) {
    newProgram!.phaseList.forEach((phase) {
      phase.programWeek.forEach((week) {
        week.weekDays.forEach((day) {
          day.workoutList =
              day.workoutList.where((element) => element != workout).toList();
        });
      });
    });
    notifyListeners();
  }

  Future<void> cleanAllProgram() async {
    await _sqfLiteDatabase.plannerDeleteAll();
    // _plannerModel.programDayList = [];
    notifyListeners();
  }

  Future<void> getProgramCategoryList() async {
    if (programCategoryList.isEmpty) {
      programCategoryList = await _service.phpGetProgramCategoryList();
      notifyListeners();
    }
  }

  Future<void> getExerciseList() async {
    if (allExerciseList.isEmpty) {
      allExerciseList = await _service.phpGetExerciseList();
      notifyListeners();
    }
  }

  Future<void> rateProgram({String? programId, required double rate}) async {
    double avgRate =
        await _service.rateProgram(programId: programId, rate: rate);
    programList
        .where((element) => element.programId == programId)
        .first
        .avgRate = avgRate;
    programList
        .where((element) => element.programId == programId)
        .first
        .userRate = rate.toInt();
    notifyListeners();
  }

  List<Exercise> getExerciseListLocal() => allExerciseList;

  Future<void> getProgramLevelList() async {
    if (programLevelList.isEmpty) {
      programLevelList = await _service.phpGetProgramLevelList();
      notifyListeners();
    }
  }

  Future<void> getProgramList() async {
    if (programList.isEmpty) {
      programList = await _service.phpGetProgramList();
      notifyListeners();
      await Future.delayed(Duration(seconds: 3), () async {
        await getProgramRates().then((value) async {
          await getUserProgramRates();
        });
      });
    }
  }

  Future<void> getProgramRates() async {
    if (programList.isNotEmpty) {
      List<Map<String, dynamic>?> rateResult = await _service.getProgramRates();
      // bulk edit //print(rateResult);
      Map<String?, List<Map<String, dynamic>?>> groupedRate = groupBy(
          rateResult, (Map<String, dynamic>? data) => data!['program_id']);
      groupedRate.forEach((key, value) {
        double rate = 0;
        value.forEach((v) {
          rate += double.parse(v!['rate']);
        });

        rate = rate / value.length;

        if (programList
            .where((welement) => welement.programId == key)
            .isNotEmpty)
          programList
              .where((welement) => welement.programId == key)
              .first
              .avgRate = rate;
      });

      notifyListeners();
    }
  }

  Future<void> getUserProgramRates() async {
    if (programList.isNotEmpty) {
      List<Map<String, dynamic>?> rateResult =
          await _service.getUserProgramRates();
      if (rateResult != null) {
        rateResult.forEach((element) {
          if (programList
              .where((welement) => welement.programId == element!['program_id'])
              .isNotEmpty)
            programList
                .where(
                    (welement) => welement.programId == element!['program_id'])
                .first
                .userRate = int.parse(element!['rate']);
        });
      }

      notifyListeners();
    }
  }

  Future<void> getProgramCalender({String? programId}) async {
    if (programList
        .where((element) => element.programId == programId)
        .isNotEmpty) {
      if (programList
          .where((element) => element.programId == programId)
          .first
          .phaseList
          .isEmpty) {
        List<ProgramPhase> result =
            await _service.phpGetProgramCalender(programId: programId);
        // bulk edit //print(result);
        List<ProgramPhase> programPhase = [];
        for (var phase in result) {
          programPhase.add(phase);
        }
        programList
            .where((element) => element.programId == programId)
            .first
            .phaseList = programPhase;
        // bulk edit //print(programList);
        notifyListeners();
        if (programList.isNotEmpty)
          programList.forEach((element) {
            setExerciseObjectForWorkout(programId: element.programId);
          });
      }
    }
  }

  // ignore: missing_return
  setExerciseObjectForWorkout({String? programId}) {
    programList
        .where((element) => element.programId == programId)
        .first
        .phaseList
        .forEach((phase) {
      phase.programWeek.forEach((week) {
        week.weekDays.forEach((day) {
          day.workoutList.forEach((workout) {
            if (allExerciseList
                .where((element) =>
                    element.exerciseId == workout.exerciseId.toString())
                .isNotEmpty)
              workout.exercise = allExerciseList
                  .where((element) =>
                      element.exerciseId == workout.exerciseId.toString())
                  .first;
            if (workout.exercise != null)
              workout.exercise!.equipmentGroup.forEach((equipment) {
                if (programList
                    .where((element) => element.programId == programId)
                    .first
                    .equipmentList
                    .where((element) =>
                        element.equipmentId == equipment.equipmentId)
                    .isEmpty)
                  programList
                      .where((element) => element.programId == programId)
                      .first
                      .equipmentList
                    ..add(equipment);
              });
          });
        });
      });
    });
    notifyListeners();
  }
}
