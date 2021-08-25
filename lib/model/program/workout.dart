import '../../model/program/runningWorkout.dart';

import './workoutSet.dart';

import './exercise.dart';
import './program_model.dart';

List<int> cardioExerciseList = [37];

// ignore: unused_element
ProgramModel? _programModel;

class Workout {
  String? workoutId;
  int? exerciseId;
  Exercise? exercise;
  String? reps;
  int? sets;
  int? order = 99999999; // Order default
  String? rpe;
  List<WorkoutSet> userWorkoutSet = [];
  int? userRpe = 0;
  RunningWorkout? runningWorkout;
  bool? isItDone = false;
  // Workout() {
  //   checkDone();
  // }
  Workout();
  Workout.fromMysqlDatabase(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      workoutId = json['id'].toString();
      exerciseId = int.parse(json['exercise_id'].toString());
      reps = json['reps'].toString();
      sets = int.parse(json['sets'].toString());
      rpe = json['rpe'].toString();
      if (json['order'] != null &&
          json['order'] != null &&
          int.tryParse(json['order'].toString()) != null) {
        order = int.parse(json['order'].toString());
      }
      if (cardioExerciseList.contains(exerciseId)) {
        runningWorkout = RunningWorkout();
        // runningWorkout.distance = 0.0;
        // runningWorkout.hours = 0;
        // runningWorkout.minutes = 0;
        // runningWorkout.seconds = 0;
        // runningWorkout.workoutId = workoutId;
      }
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }

  Workout.fromLocalJson(Map<String, dynamic> json) {
    try {
      workoutId = json['workoutId'].toString();
      exerciseId = json['exerciseId'];
      reps = json['reps'].toString();
      sets = json['sets'];
      order = json['order'];
      rpe = json['rpe'].toString();
      if (json['userWorkoutSet'] != null) {
        for (var workoutSet in json['userWorkoutSet']) {
          userWorkoutSet.add(WorkoutSet.fromLocalJson(workoutSet));
        }
      }

      userRpe = json['userRpe'];
      if (json['isItDone'] != null) {
        isItDone = json['isItDone'];
      }
      if (json['runningWorkout'] != null) {
        runningWorkout = RunningWorkout.fromLocalJson(json['runningWorkout']);
      }
    } catch (e, trace) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }

  Map<String, dynamic> toJson() => {
        'workoutId': workoutId,
        'exerciseId': exerciseId,
        'reps': reps,
        'sets': sets,
        'order': order,
        'rpe': rpe,
        'userWorkoutSet': userWorkoutSet,
        'userRpe': userRpe,
        'isItDone': isItDone,
        'runningWorkout': runningWorkout,
      };

  equalizeSets() {
    if (sets! > userWorkoutSet.length) {
      WorkoutSet workoutSet = WorkoutSet();
      // workoutSet.rep = reps;
      workoutSet.kg = 0;
      userWorkoutSet.add(workoutSet);
      equalizeSets();
    } else if (sets! < userWorkoutSet.length) {
      while (sets! < userWorkoutSet.length) {
        userWorkoutSet.removeAt(0);
      }
      equalizeSets();
    }
  }

  checkDone() {
    if (userWorkoutSet.length == sets) {
      isItDone = true;
    } else {
      isItDone = false;
    }
  }

  @override
  String toString() => 'workout { workoutId: $workoutId }';
}
