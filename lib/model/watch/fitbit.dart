import '../../model/watch/running.dart';
import '../../model/watch/sleep.dart';

class Fitbit {
  DateTime? date;
  int? restingHeartRate;
  Sleep? sleep;
  int? stepsTaken;
  int? vo2Max;
  String? activityLevel;
  Running? running;

  Fitbit();

  Map<String, dynamic> toJson() => {
        'date': date,
        'restingHeartRate': restingHeartRate,
        'sleep': sleep,
        'stepsTaken': stepsTaken,
        'vo2Max': vo2Max,
        'activityLevel': activityLevel,
        'running': running,
      };

  Fitbit.fromLocalJson(Map<String, dynamic> json) {
    try {
      date = DateTime.parse(json['date']);
      restingHeartRate = json['restingHeartRate'];
      sleep = Sleep.fromLocalJson(json['sleep']);
      stepsTaken = int.parse(json['stepsTaken']);
      vo2Max = int.parse(json['vo2Max']);
      activityLevel = json['activityLevel'].toString();
      running = Running.fromLocalJson(json['running']);
    } catch (e) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }

  Fitbit.mysqlDatabase(
      {required Map<String, dynamic> json, DateTime? dateTime}) {
    try {
      // bulk edit //print(json);
      date = dateTime;
      // if (json['running'] != null) {
      //   Map<String, dynamic> runData =
      //       Map<String, dynamic>.from(json['running']);
      //   running = Running.fromLocalJson(runData);
      // }
      if (json['sleep'] != null) {
        sleep = Sleep();
        sleep!.totalSleepTime = Duration(seconds: json['sleep']);
      }

      if (json['steps'] != null) {
        stepsTaken = int.parse(json['steps']);
      }

      if (json['heart'] != null) {
        restingHeartRate = int.parse(json['heart'].toString());
      }

      // vo2Max = int.parse(json['vo2Max']);
      // activityLevel = json['activityLevel'].toString();

    } catch (e) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }
}
