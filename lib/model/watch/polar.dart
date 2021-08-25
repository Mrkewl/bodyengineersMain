import '../../model/watch/running.dart';
import '../../model/watch/sleep.dart';

class Polar {
  DateTime? date;
  int? restingHeartRate;
  Sleep? sleep;
  int? stepsTaken;
  int? vo2Max;
  int? calories;
  String? activityLevel;
  Running? running;
  Polar();
  Map<String, dynamic> toJson() => {
        'date': date,
        'restingHeartRate': restingHeartRate,
        'sleep': sleep,
        'stepsTaken': stepsTaken,
        'vo2Max': vo2Max,
        'calories': calories,
        'activityLevel': activityLevel,
        'running': running,
      };

  Polar.fromLocalJson(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      date = DateTime.parse(json['date']);
      restingHeartRate = int.parse(json['restingHeartRate']);
      sleep = Sleep.fromLocalJson(json['sleep']);
      stepsTaken = int.parse(json['stepsTaken']);
      vo2Max = int.parse(json['vo2Max']);
      calories = int.parse(json['calories']);
      activityLevel = json['activityLevel'].toString();
      running = Running.fromLocalJson(json['running']);
    } catch (e, trace) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }
  Polar.mysqlDatabase({required Map<String, dynamic> json, DateTime? dateTime}) {
    try {
      // bulk edit //print(json);
      date = dateTime;
      if (json['running'] != null) {
        Map<String, dynamic> runData =
            Map<String, dynamic>.from(json['running']);
        running = Running.fromLocalJson(runData);
      }
      if (json['sleepDurationInSeconds'] != null) {
        sleep = Sleep();
        sleep!.totalSleepTime =
            Duration(seconds: json['sleepDurationInSeconds']);
      }

      if (json['steps'] != null) {
        stepsTaken = json['steps'];
      }
      if (json['calories'] != null) {
        calories = json['calories'];
      }
      if (json['restingHeartRateInBeatsPerMinute'] != null) {
        restingHeartRate = json['restingHeartRateInBeatsPerMinute'];
      }

      // vo2Max = int.parse(json['vo2Max']);
      // activityLevel = json['activityLevel'].toString();

    } catch (e, trace) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }
}
