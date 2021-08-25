import 'dart:math';

import 'package:bodyengineer/model/watch/watch_data.dart';

import '../../model/watch/fitbit.dart';
import '../../model/watch/garmin.dart';
import '../../model/watch/polar.dart';
import '../../model/watch/running.dart';
import '../../model/watch/sleep.dart';
import '../../services/index.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchModel with ChangeNotifier {
  final Services _service = Services();
  late SharedPreferences prefs;
  List<Garmin>? garminDataList;
  List<Polar>? polarDataList;
  List<Fitbit>? fitbitDataList;
  List<WatchDataObject>? watchDataList;
  bool isCompleted = false;
  WatchModel() {
    appInit();
  }

  Future<void> appInit() async {
    await watchDataProcess();
    await getDataFromServer();
    isCompleted = true;
    notifyListeners();
  }

  Future<void> logOut() async {
    garminDataList = null;
    polarDataList = null;
    fitbitDataList = null;
    watchDataList = null;
    isCompleted = false;

    notifyListeners();
  }

  Future<void> watchDataProcess() async {
    prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('watch_data_date') ?? null;
    DateTime transferDataDate;
    Duration? duration;
    if (data != null) {
      transferDataDate = DateTime.parse(data);
      duration = transferDataDate.difference(DateTime.now());
    }
    print(duration);
    if (duration == null ||
        duration.inMinutes.abs() > Duration(days: 1).inMinutes)
      fetchNewDataFromWatches();
  }

  fetchNewDataFromWatches() async {
    await _service.fetchNewDataFromWatches();
    prefs.setString('watch_data_date', DateTime.now().toString());
  }

  getDataFromServer() async {
    List<dynamic> result = await _service.phpGetWatchesData();
    // bulk edit //print(result);

    result.forEach((element) {
      if (element is Garmin) {
        if (garminDataList == null) garminDataList = [];

        garminDataList!.add(element);
      }
      if (element is Polar) {
        if (polarDataList == null) polarDataList = [];
        polarDataList!.add(element);
      }
      if (element is Fitbit) {
        if (fitbitDataList == null) fitbitDataList = [];

        fitbitDataList!.add(element);
      }
    });
    if (garminDataList != null)
      garminDataList!.sort((a, b) => a.date!.compareTo(b.date!));

    if (polarDataList != null)
      polarDataList!.sort((a, b) => a.date!.compareTo(b.date!));

    if (fitbitDataList != null)
      fitbitDataList!.sort((a, b) => a.date!.compareTo(b.date!));

    if (garminDataList != null ||
        polarDataList != null ||
        fitbitDataList != null) syncEveryData();

    notifyListeners();
    // bulk edit //print(garminDataList);
  }

  syncEveryData() {
    watchDataList = [];
    if (garminDataList != null)
      watchDataList!.addAll(
          garminDataList!.map((e) => WatchDataObject.fromGarmin(e)).toList());

    if (polarDataList != null)
      watchDataList!.addAll(
          polarDataList!.map((e) => WatchDataObject.fromPolar(e)).toList());

    if (fitbitDataList != null)
      watchDataList!.addAll(
          fitbitDataList!.map((e) => WatchDataObject.fromFitbit(e)).toList());

    print(watchDataList);
    if (watchDataList!.isNotEmpty)
      watchDataList!.sort((a, b) => a.date!.compareTo(b.date!));

    notifyListeners();
  }

  dataGenerator() {
    for (var i = 1; i < 21; i++) {
      Garmin garminData = Garmin();
      garminData.activityLevel = i % 2 == 0 ? 'High' : 'Low';
      garminData.date = i == 1
          ? DateTime.now()
          : DateTime(2020, 12, 18).add(Duration(days: i));
      garminData.restingHeartRate = Random().nextInt(i * 20);
      Running running = Running();
      running.distance = Random(50).nextDouble();
      running.duration = Duration(hours: Random().nextInt(5));
      garminData.running = running;
      Sleep sleep = Sleep();
      sleep.awake = Duration(hours: Random().nextInt(5));
      sleep.deepSleep = Duration(hours: Random().nextInt(2));
      sleep.lightSleep = Duration(hours: Random().nextInt(2));
      sleep.remSleep = Duration(hours: Random().nextInt(2));
      sleep.sleepTiming = Duration(hours: Random().nextInt(2));
      sleep.totalSleepTime =
          sleep.deepSleep! + sleep.lightSleep! + sleep.remSleep!;
      garminData.sleep = sleep;
      garminData.stepsTaken = Random().nextInt(5250);
      garminData.vo2Max = Random().nextInt(100);
      garminDataList!.add(garminData);
    }
  }
}
