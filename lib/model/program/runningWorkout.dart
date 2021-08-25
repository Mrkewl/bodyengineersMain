import './program_model.dart';

// ignore: unused_element
ProgramModel? _programModel;

class RunningWorkout {
  String? workoutId;
  double distance = 0;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  // Workout() {
  //   checkDone();
  // }
  RunningWorkout();
  RunningWorkout.fromMysqlDatabase(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      workoutId = json['id'].toString();
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }

  RunningWorkout.fromLocalJson(Map<String, dynamic> json) {
    try {
      workoutId = json['workoutId'].toString();
      distance = double.parse(json['distance'].toString());
      hours = int.parse(json['hours'].toString());
      minutes = int.parse(json['minutes'].toString());
      seconds = int.parse(json['seconds'].toString());
    } catch (e, trace) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }

  Map<String, dynamic> toJson() => {
        'workoutId': workoutId,
        'distance': distance,
        'hours': hours,
        'minutes': minutes,
        'seconds': seconds,
      };

  @override
  String toString() => 'Running workout { workoutId: $workoutId }';
}
