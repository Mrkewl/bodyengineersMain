import '../../helper/sqflite_helper.dart';
import '../../model/goal/body_goal.dart';
import '../../model/goal/exercise_goal.dart';
import '../../model/planner/exercise_history.dart';
import '../../model/user/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert' as convert;

class GoalModel with ChangeNotifier {
  List<BodyGoal> bodyGoalList = [];
  List<ExerciseGoal> exerciseGoalList = [];
  final _sqfLiteDatabase = SqfliteHelper.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isCompleted = false;
  GoalModel() {
    appInit();
  }

  appInit() async {
    await getGoalsHistories();
    isCompleted = true;
    notifyListeners();
  }

  Future<void> logOut() async {
    bodyGoalList = [];
    exerciseGoalList = [];
    notifyListeners();
  }

  deleteGoals() async {
    await _sqfLiteDatabase.goalsDeleteAll();

    bodyGoalList = [];
    exerciseGoalList = [];
    notifyListeners();
  }

  checkExerciseGoals(List<ExerciseHistoryElement> exerciseHistory) {
    // bulk edit //print(exerciseHistory);
    exerciseGoalList.where((element) => !element.isCompleted!).forEach((el) {
      exerciseHistory
          .where((element) => element.exerciseId.toString() == el.exerciseId)
          .forEach((ex) {
        if (ex.exerciseId != 19) {
          if (ex.weight! >= el.kg! && ex.rep! >= el.rep!) {
            el.isCompleted = true;
          }
        } else {
          if (ex.rep! >= el.rep!) {
            el.isCompleted = true;
          }
        }
      });
    });
    updateGoalsJson();
  }

  checkBodyGoals({double? bodyFat, double? bodyWeight, UserObject? user}) {
    bodyGoalList.where((element) => !element.isCompleted!).forEach((el) {
      switch (el.name) {
        case 'Body Fat':
          if (el.isLoose!) {
            // Loose Fat
            if (bodyFat! <= el.goal!) {
              el.isCompleted = true;
            }
          } else {
            // Gain Fat
            if (bodyFat! >= el.goal!) {
              el.isCompleted = true;
            }
          }
          break;
        case 'Body Weight':
          if (el.isLoose!) {
            // Loose Weight
            if (bodyWeight! <= el.goal!) {
              el.isCompleted = true;
            }
          } else {
            // Gain Weight
            if (bodyWeight! >= el.goal!) {
              el.isCompleted = true;
            }
          }
          break;
      }
    });
    updateGoalsJson();
  }

  removeBodyGoal({BodyGoal? bodyGoal}) {
    bodyGoalList.removeWhere((element) => element == bodyGoal);
    notifyListeners();
    updateGoalsJson();
  }

  setBodyGoal(
      {String? name,
      double? goal,
      double? initial,
      double? bodyWeight,
      double? bodyFat}) {
    bool? isLoose;
    switch (name) {
      case 'Body Fat':
        if (bodyFat! > goal!) {
          // Loose Fat
          isLoose = true;
        } else {
          // Gain Fat
          isLoose = false;
        }
        break;
      case 'Body Weight':
        if (bodyWeight! > goal!) {
          // Loose Weight
          isLoose = true;
        } else {
          // Gain Weight
          isLoose = false;
        }
        break;
    }
    BodyGoal bodyGoal = BodyGoal.fromJson(
        {'name': name, 'goal': goal, 'initial': initial, 'isLoose': isLoose});
    bodyGoalList.removeWhere(
        (element) => element.name == name && !element.isCompleted!);
    bodyGoalList.add(bodyGoal);

    notifyListeners();
    updateGoalsJson();
  }

  removeExerciseGoal({ExerciseGoal? exerciseGoal}) {
    exerciseGoalList.removeWhere((element) => element == exerciseGoal);
    notifyListeners();
    updateGoalsJson();
  }

  setExerciseGoal(String? exerciseId, int kg, int rep) {
    ExerciseGoal exerciseGoal =
        ExerciseGoal.fromJson({'exerciseId': exerciseId, 'rep': rep, 'kg': kg});
    exerciseGoalList.removeWhere(
        (element) => element.exerciseId == exerciseId && !element.isCompleted!);
    exerciseGoalList.add(exerciseGoal);
    notifyListeners();
    updateGoalsJson();
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
            ExerciseGoal exerciseGoal = ExerciseGoal.fromJson(json);
            exerciseGoalList.removeWhere((element) =>
                element.exerciseId == exerciseGoal.exerciseId &&
                !element.isCompleted!);
            exerciseGoalList.removeWhere((element) =>
                element.exerciseId == exerciseGoal.exerciseId &&
                element.kg == exerciseGoal.kg &&
                element.rep == exerciseGoal.rep &&
                element.isCompleted!);
            exerciseGoalList.add(exerciseGoal);
          } else {
            BodyGoal bodyGoal = BodyGoal.fromJson(json);
            bodyGoalList.removeWhere((element) =>
                element.name == bodyGoal.name && !element.isCompleted!);
            bodyGoalList.removeWhere((element) =>
                element.name == bodyGoal.name &&
                element.isLoose == bodyGoal.isLoose &&
                element.goal == bodyGoal.goal &&
                element.initial == bodyGoal.initial &&
                element.isCompleted!);
            bodyGoalList.add(bodyGoal);
          }
        }
      });
      notifyListeners();
    }
  }

  Future<void> updateGoalsJson() async {
    List<String> jsonEncodedList = [];
    String jsonEncoded = '';

    exerciseGoalList.forEach((exHistory) async {
      jsonEncodedList.add(convert.jsonEncode(exHistory.toJson()));
    });
    bodyGoalList.forEach((bodyGoal) async {
      jsonEncodedList.add(convert.jsonEncode(bodyGoal.toJson()));
    });

    print(bodyGoalList);
    print('BODY GOAL SAYISI ==>' + bodyGoalList.length.toString());

    List<Map<String, dynamic>>? goalsRaw =
        await _sqfLiteDatabase.goalsQueryAllRows();

    jsonEncoded = convert.jsonEncode(jsonEncodedList);

    if (convert.jsonEncode(goalsRaw) != jsonEncoded) {
      if (auth.currentUser != null) if (auth.currentUser!.uid != null) {
        Map<String, dynamic> updateElement = {
          'json': jsonEncoded,
          'uid': auth.currentUser!.uid,
          'date': DateTime.now().toIso8601String(),
        };
        // bulk edit //print(updateElement);
        var result = await _sqfLiteDatabase.goalsQueryAllRows();
        if (result != null) {
          await _sqfLiteDatabase.goalsDeleteAll().then((value) async {
            await _sqfLiteDatabase.goalsInsert(updateElement);
          });
        } else {
          await _sqfLiteDatabase.goalsInsert(updateElement);
        }
      }
    }
  }
}
