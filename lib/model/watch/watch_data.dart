import 'package:bodyengineer/model/watch/fitbit.dart';
import 'package:bodyengineer/model/watch/garmin.dart';
import 'package:bodyengineer/model/watch/polar.dart';

import '../../model/watch/running.dart';
import '../../model/watch/sleep.dart';

class WatchDataObject {
  DateTime? date;
  int? restingHeartRate;
  Sleep? sleep;
  int? stepsTaken;
  int? vo2Max;
  String? activityLevel;
  Running? running;
  WatchDataObject();
  Map<String, dynamic> toJson() => {
        'date': date,
        'restingHeartRate': restingHeartRate,
        'sleep': sleep,
        'stepsTaken': stepsTaken,
        'vo2Max': vo2Max,
        'activityLevel': activityLevel,
        'running': running,
      };

  WatchDataObject.fromLocalJson(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      date = DateTime.parse(json['date']);
      restingHeartRate = int.parse(json['restingHeartRate']);
      sleep = Sleep.fromLocalJson(json['sleep']);
      stepsTaken = int.parse(json['stepsTaken']);
      vo2Max = int.parse(json['vo2Max']);
      activityLevel = json['activityLevel'].toString();
      running = Running.fromLocalJson(json['running']);
    } catch (e, trace) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }

  WatchDataObject.fromGarmin(Garmin garmin) {
    try {
      // bulk edit //print(json);
      date = garmin.date;
      restingHeartRate = garmin.restingHeartRate;
      sleep = garmin.sleep;
      stepsTaken = garmin.stepsTaken;
      vo2Max = garmin.vo2Max;
      activityLevel = garmin.activityLevel;
      running = garmin.running;
    } catch (e, trace) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }

  WatchDataObject.fromFitbit(Fitbit fitbit) {
    try {
      // bulk edit //print(json);
      date = fitbit.date;
      restingHeartRate = fitbit.restingHeartRate;
      sleep = fitbit.sleep;
      stepsTaken = fitbit.stepsTaken;
      vo2Max = fitbit.vo2Max;
      activityLevel = fitbit.activityLevel;
      running = fitbit.running;
    } catch (e, trace) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }

  WatchDataObject.fromPolar(Polar polar) {
    try {
      // bulk edit //print(json);
      date = polar.date;
      restingHeartRate = polar.restingHeartRate;
      sleep = polar.sleep;
      stepsTaken = polar.stepsTaken;
      vo2Max = polar.vo2Max;
      activityLevel = polar.activityLevel;
      running = polar.running;
    } catch (e, trace) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }
}
