import 'dart:math';
import 'dart:io';
import '../../model/planner/bodystatsDay.dart';
import '../../model/planner/exercise_history.dart';
import '../../model/planner/progress_photo.dart';
import '../../model/program/program.dart';
import '../../model/program/programPhase.dart';
import '../../model/program/programWeek.dart';
import '../../model/program/workout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert' as convert;
import 'package:collection/collection.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../services/index.dart';
import '../../helper/sqflite_helper.dart';
import '../../helper/timezone.dart';
import '../../model/program/exercise.dart';
import '../../model/planner/measurement.dart';
import '../../model/program/programDay.dart';
import '../../model/program/program_model.dart';
import '../../model/user/user.dart';

class PlannerModel with ChangeNotifier {
  bool isChecked = false;
  bool subscribeWarning = false;
  final Services _service = Services();
  final ProgramModel _programModel = ProgramModel();
  final _sqfLiteDatabase = SqfliteHelper.instance;
  Program? plannerMainProgram;
  Program? plannerAddonProgram;
  List<ProgramDay> programDayList = [];
  List<BodystatsDay?> bodystatsDayList = [];
  List<Exercise> allExerciseList = [];
  List<ExerciseHistoryElement> exerciseHistory = [];
  List<ProgressPhoto?> progressPhotoList = [];
  final FirebaseAuth auth = FirebaseAuth.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  UserObject? loggedInuser;
  String? lastProgramId;
  DateTime lastProgramRegisterDate = DateTime.now();
  bool isCompleted = false;
  PlannerModel() {
    appInit();
  }

  appInit() {
    getExerciseList()
      ..then((value) async {
        await getUserDataSqflite().then((val) async {
          await setExerciseOfWorkouts().then((value) async {
            await setProgramFromPlanner();
            await getBodystatDays();
            await getExerciseHistories();
            isCompleted = true;
            notifyListeners();
            await getProgressPhotoList();
            await getUserInfo();
            await setNotification();
          });
        });
      });
  }

  setNotification() async {
    bool isSameDate(date1, date2) {
      return date2.year == date1.year &&
          date2.month == date1.month &&
          date2.day == date1.day;
    }

    DateTime today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    List<PendingNotificationRequest> pendingNotification =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    if (pendingNotification
        .where((element) => element.payload == '')
        .isNotEmpty) {
      await flutterLocalNotificationsPlugin.cancelAll();
    }
    pendingNotification
        .where((element) =>
            !isSameDate(DateTime.parse(element.payload!), today) &&
            DateTime.parse(element.payload!).isAfter(today))
        .forEach((element) async {
      print(element);
      await flutterLocalNotificationsPlugin.cancel(element.id);
    });
    // print(pendingNotification);
    programDayList
        .where((element) =>
            element.dateTime!.isAfter(today) &&
            !isSameDate(element.dateTime, today) &&
            !element.isDayCompleted)
        .forEach((element) async {
      await scheduleNotification(
          id: element.id as int? ?? Random().nextInt(99999),
          title: 'Work Out Reminder',
          body: element.name,
          scheduledDate: DateTime(element.dateTime!.year,
              element.dateTime!.month, element.dateTime!.day, 9, 0));
    });
  }

  deletePlannerData() async {
    await _sqfLiteDatabase.plannerDeleteAll();
    await _sqfLiteDatabase.bodystatsDeleteAll();
    bodystatsDayList = [];
    programDayList = [];
    plannerMainProgram = null;
    plannerAddonProgram = null;
    subscribeWarning = false;
    notifyListeners();
  }

  // ignore: missing_return
  makeSubscribeWarningTrue() {
    subscribeWarning = true;
    notifyListeners();
  }

  filterBodystatsDay() async {
    int beforeBodyStatCount = bodystatsDayList.length;

    programDayList
        .where((element) => element.isBodyStatsDay!)
        .forEach((element) {
      if (element.isBodyStatsDay!) {
        element.isBodyStatsDay = false;
        DateTime dateTime = DateTime(element.dateTime!.year,
            element.dateTime!.month, element.dateTime!.day);
        if (bodystatsDayList
            .where((element) => element!.dateTime == dateTime)
            .isEmpty) addBodyStatsDay(dateTime: dateTime);
      }
    });

    int afterBodyStatCount = bodystatsDayList.length;

    notifyListeners();
    if (beforeBodyStatCount < afterBodyStatCount) {
      await updateUserSqflite();
    }
  }

  deleteBodyStatsDay({BodystatsDay? bodystatsDay}) {
    if (bodystatsDay != null) {
      bodystatsDayList.removeWhere((element) => element == bodystatsDay);
      notifyListeners();
      updateBodystatsJson();
    }
  }

  addBodyStatsDay({BodystatsDay? bodystatsDay, DateTime? dateTime}) {
    BodystatsDay? objectBodystatsDay = BodystatsDay();

    if (dateTime == null) {
      bodystatsDayList.removeWhere((element) =>
          element!.dateTime ==
          DateTime(bodystatsDay!.dateTime!.year, bodystatsDay.dateTime!.month,
              bodystatsDay.dateTime!.day));
      objectBodystatsDay = bodystatsDay;
    } else {
      bodystatsDayList.removeWhere((element) =>
          element!.dateTime ==
          DateTime(dateTime.year, dateTime.month, dateTime.day));
      objectBodystatsDay.id = DateTime.now().microsecondsSinceEpoch.toString();
      objectBodystatsDay.dateTime =
          DateTime(dateTime.year, dateTime.month, dateTime.day);
    }

    if (objectBodystatsDay!.measurements.isNotEmpty) {
      objectBodystatsDay.isCompleted = true;
    }

    bodystatsDayList.add(objectBodystatsDay);
    updateBodystatsJson();
    notifyListeners();
  }

  addProgressPhoto({ProgressPhoto? progressPhoto}) {
    progressPhotoList
        .removeWhere((element) => element!.dateTime == progressPhoto!.dateTime);
    progressPhotoList.add(progressPhoto);
    updateProgressPhotoJson();
    notifyListeners();
  }

  Future<void> setProgramFromPlanner() async {
    plannerMainProgram = getPlannerAsProgram(isAddon: false);
    plannerAddonProgram = getPlannerAsProgram(isAddon: true);
    // bulk edit //print(programDayList);
    notifyListeners();
  }

  Program? getPlannerAsProgram({required bool isAddon}) {
    Program? program;
    List<ProgramDay> programDayLocalList = programDayList
        .where((element) =>
            element.isAddonDay == isAddon && element.programId != null)
        .toList();

    if (!isAddon && programDayLocalList.isNotEmpty) {
      programDayLocalList = programDayLocalList
          .where((day) =>
              day.programId == lastProgramId &&
              (lastProgramRegisterDate == day.dateTime! ||
                  lastProgramRegisterDate.isBefore(day.dateTime!)))
          .toList();
    }

    // bulk edit //print(programDayLocalList);
    if (programDayLocalList.isNotEmpty) {
      program = Program();
      program.programId = programDayLocalList.first.programId;
      program.phaseList = [];
      Map<dynamic, List<ProgramDay>> groupByPhase = groupBy(
          programDayLocalList.toList(), (ProgramDay day) => day.phaseNumber);

      groupByPhase.forEach((phaseNumber, phaseDayList) {
        ProgramPhase programPhase = ProgramPhase();
        programPhase.programId = program!.programId;
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

  int getTotalCompletedWorkout() {
    return programDayList.where((element) => element.isDayCompleted).length;
  }

  Future<void> getExerciseList() async {
    if (allExerciseList.isEmpty) {
      allExerciseList = await _service.phpGetExerciseList();
      notifyListeners();
      await getCustomExercise();
    }
  }

  addCustomExercise(Exercise exercise) {
    allExerciseList.add(exercise);
    notifyListeners();
    updateCustomExerciseJson();
  }

  Future<void> deleteCustomExercise(Exercise? exercise) async {
    allExerciseList.removeWhere((element) => element == exercise);
    updateCustomExerciseJson();

    exerciseHistory.removeWhere(
        (element) => element.exerciseId.toString() == exercise!.exerciseId);
    updateExerciseHistoryJson();

    programDayList.forEach((day) {
      day.workoutList.removeWhere(
          (workout) => workout.exerciseId.toString() == exercise!.exerciseId);
    });

    await updateUserSqflite();
    await setProgramFromPlanner();

    notifyListeners();
  }

  Future<void> cleanAllProgram() async {
    programDayList.removeWhere((day) =>
        !day.isDayCompleted &&
            lastProgramRegisterDate.isBefore(day.dateTime!) ||
        lastProgramRegisterDate == day.dateTime! &&
            day.programId == lastProgramId ||
        day.isAddonDay!);
    lastProgramId = null;
    updateUserSqflite();
    notifyListeners();
    await setProgramFromPlanner();
  }

  Future<void> setPlanner() async {
    await getExerciseList();
    await getPlannerProgram();
    await setProgramFromPlanner();
  }

  Future<void> changeProgramDayDate(
      {required ProgramDay programDay, DateTime? newDateTime}) async {
    programDayList.where((element) => element == programDay).first.dateTime =
        newDateTime;
    await updateUserSqflite();
    notifyListeners();
    await setProgramFromPlanner();
  }

  Future<void> removeProgramDay({required ProgramDay programDay}) async {
    programDayList.removeWhere((element) => element == programDay);
    programDay.workoutList.forEach((workout) {
      exerciseHistory.removeWhere(
          (exHist) => exHist.workoutId.toString() == workout.workoutId);
    });
    notifyListeners();
    await updateExerciseHistoryJson();
    await updateUserSqflite();
    notifyListeners();
    await setProgramFromPlanner();
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
    //         // bulk edit //print(item);
    //         // bulk edit //print(element['isAddon']);
    //         programDayList.add(ProgramDay.fromLocalJson(
    //             convert.jsonDecode(item),
    //             );
    //       }
    //     }
    //   });
    //   notifyListeners();
    //   await setExerciseOfWorkouts();
    // }
    // if (programDayList.where((element) => element.isBodyStatsDay!).isNotEmpty) {
    //   filterBodystatsDay();
    // }
    // isChecked = true;
  }

  Future<void> saveProgramToPlanner(
      {required List<ProgramDay> newProgramDayList}) async {
    print(newProgramDayList);
    print(programDayList);
    if (newProgramDayList.isNotEmpty) {
      programDayList.removeWhere((element) =>
          element.dateTime!.isAfter(newProgramDayList.first.dateTime!) &&
          !element.isDayCompleted);

      programDayList.addAll(newProgramDayList);
      lastProgramRegisterDate = newProgramDayList.first.dateTime!;
      lastProgramId = newProgramDayList.first.programId;
      updateUserSqflite();
    }

    // bulk edit //print('Save Program to Planner');
    // List<String> jsonEncodedList = [];
    // String jsonEncoded = '';
    // programDayList.forEach((programDay) async {
    //   // var programDayJson = programDay.toJson();
    //   jsonEncodedList.add(convert.jsonEncode(programDay.toJson()));
    //   // // bulk edit //print(jsonEncoded);
    //   // ProgramDay convertedJson =
    //   //     ProgramDay.fromLocalJson(convert.jsonDecode(jsonEncoded));
    //   // // bulk edit //print(convertedJson);
    //   //   await _sqfLiteDatabase.plannerInsert(addElement);
    // });
    // jsonEncoded = convert.jsonEncode(jsonEncodedList);

    // Map<String, dynamic> insertElement = {
    //   'json': jsonEncoded,
    //   'program_id': programDayList.first.programId,
    //   'uid': programDayList.first.uid,
    //   'register_date': DateTime.now().toIso8601String(),
    //   'isActive': 1,
    //   'isAddon': 0,
    // };

    // await _sqfLiteDatabase.plannerInsert(insertElement);
  }

  Future<void> updateUserSqflite() async {
    if (auth.currentUser != null) {
      String uid = auth.currentUser!.uid;
      await setExerciseOfWorkouts();

      Map<String, dynamic> userData = {
        'programDayList': programDayList,
        'lastProgramRegisterDate': lastProgramRegisterDate.toIso8601String(),
        'lastProgramId': lastProgramId,
        // 'userSets': userSets,
        // 'userWordFavorites': userWordFavorites,
      };

      String jsonEncoded = '';

      jsonEncoded = convert.jsonEncode(userData);

      Map<String, dynamic> element = {
        'json': jsonEncoded,
        'uid': uid,
      };
      await _sqfLiteDatabase.userDataTableDeleteAll();
      await _sqfLiteDatabase.userDataInsert(element);
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
          if (decodedData['lastProgramRegisterDate'] != null)
            lastProgramRegisterDate =
                DateTime.parse(decodedData['lastProgramRegisterDate']);
          if (decodedData['lastProgramId'] != null)
            lastProgramId = decodedData['lastProgramId'];

          // for (var item in decodedData['userSets']) {
          //   userSets.add(item);
          // }

        } catch (e) {
          print(e.toString());
        }
      });
      notifyListeners();
    }
  }

  Future<void> syncProgramDayList() async {
    await setExerciseOfWorkouts();
    if (programDayList.where((element) => element.isBodyStatsDay!).isNotEmpty) {
      filterBodystatsDay();
    }
    isChecked = true;
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
          BodystatsDay bodystatsDay =
              BodystatsDay.fromLocalJson(convert.jsonDecode(item));
          if (bodystatsDayList
              .where((element) => element!.dateTime == bodystatsDay.dateTime)
              .isEmpty)
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

  Future<void> getProgressPhotoList() async {
    // bulk edit //print('Get Planner Program');
    List<Map<String, dynamic>>? progressPhotoRaw = [];
    progressPhotoRaw = await _sqfLiteDatabase.progresPhotoHistoryQueryAllRows();
    // bulk edit //print(progressPhotoRaw);
    if (progressPhotoRaw != null) {
      progressPhotoRaw.forEach((element) {
        // bulk edit //print(element);
        for (var item in convert.jsonDecode(element['json'])) {
          progressPhotoList
              .add(ProgressPhoto.fromSqfliteJson(convert.jsonDecode(item)));
        }
      });
      notifyListeners();
    }
  }

  Future<void> getCustomExercise() async {
    // bulk edit //print('Get Planner Program');
    List<Map<String, dynamic>>? customExerciseRaw = [];
    customExerciseRaw = await _sqfLiteDatabase.customExerciseQueryAllRows();
    // bulk edit //print(progressPhotoRaw);
    if (customExerciseRaw != null) {
      customExerciseRaw.forEach((element) {
        // bulk edit //print(element);
        for (var item in convert.jsonDecode(element['json'])) {
          allExerciseList.add(Exercise.fromSqflite(convert.jsonDecode(item)));
        }
      });
      notifyListeners();
    }
  }

  // ignore: missing_return
  addQuickWorkout(
      {required DateTime dateTime,
      String? uid,
      String? programDayId,
      String? dayName}) {
    // ProgramDay closestProgramDay = programDayList.reduce((a, b) =>
    //     a.dateTime!.difference(dateTime).abs() <
    //             b.dateTime!.difference(dateTime).abs()
    //         ? a
    //         : b);

    ProgramDay programDay = ProgramDay();
    programDay.id = programDayId;
    programDay.name = dayName;
    programDay.phaseNumber = null;
    programDay.programId = null;
    programDay.uid = uid;
    programDay.weekNumber = null;
    programDay.workoutList = [];
    programDay.dateTime = dateTime;
    programDay.countDay = dateTime.weekday;
    programDay.isAddonDay = false;

    programDayList.add(programDay);
    notifyListeners();
    setProgramFromPlanner();
  }

  static const _scopes = const [CalendarApi.calendarScope];

  sendPlannerToGoogleCalendar(prompt) {
    var _credentials;
    if (Platform.isAndroid) {
      _credentials = ClientId(
          "141337567543-pqrg5rtnd4j5oh66d7ohemo2r8k09es1.apps.googleusercontent.com",
          "");
    } else if (Platform.isIOS) {
      _credentials = ClientId(
          "141337567543-1coiomk6pt2jgo6ge3s243a7ajur70fr.apps.googleusercontent.com",
          "");
    }

    if (_credentials != null) {
      List<Event> listofEvent = getListofEvents();

      clientViaUserConsent(_credentials, _scopes, prompt)
          .then((AuthClient client) async {
        var calendar = CalendarApi(client);

        listofEvent.forEach((event) async {
          await Future.delayed(Duration(seconds: 1), () async {
            String calendarId = 'primary';
            try {
              await Future.delayed(Duration(seconds: 2), () async {
                await calendar.events
                    .insert(event, calendarId)
                    .then((value) async {
                  // bulk edit //print("ADDEDDD_________________${value.status}");
                  if (value.status == "confirmed") {
                    // bulk edit //print('Event added in google calendar');
                  } else {
                    // bulk edit //print("Unable to add event in google calendar");
                  }
                }).catchError((e) {
                  // bulk edit //print(e.toString());
                });
              });
            } catch (e) {
              // bulk edit //print(e.toString());
            }
          });
        });
      });
    }
  }

  List<Event> getListofEvents() {
    List<Event> listOfEvent = [];

    programDayList.forEach((element) {
      Event event = Event(); // Create object of event
      event.summary = 'Workout Reminder'; //Setting summary of object
      EventCreator eventCreator = EventCreator();
      eventCreator.displayName = 'Body Engineers';
      eventCreator.email = 'info@bodyengineers.sg';
      event.creator = eventCreator;

      DateTime dateTime = DateTime(element.dateTime!.year,
          element.dateTime!.month, element.dateTime!.day);

      EventDateTime start = new EventDateTime(); //Setting start time
      start.date = dateTime;
      event.start = start;

      EventDateTime end = new EventDateTime(); //setting end time
      end.date = dateTime;
      event.end = end;
      // event.eventType = 'default';
      listOfEvent.add(event);
    });

    return listOfEvent;
  }

  Future<void> deleteProgramDay(ProgramDay programDay) async {
    programDayList.removeWhere((element) => element == programDay);
    await updateUserSqflite();
    await setProgramFromPlanner();
  }

  // ignore: missing_return
  Future<void> addProgramDay(
      {DateTime? dateTime, required List<ProgramDay> listProgramday}) async {
    ProgramDay closestProgramDay = programDayList.reduce((a, b) =>
        a.dateTime!.difference(dateTime!).abs() <
                b.dateTime!.difference(dateTime).abs()
            ? a
            : b);
    listProgramday.forEach((element) {
      ProgramDay programDay = ProgramDay();
      programDay.id = DateTime.now().microsecondsSinceEpoch.toString();

      programDay.dateTime = dateTime;
      programDay.uid = element.uid;
      int randomCount = 0;
      element.workoutList.forEach((workout) {
        workout.workoutId =
            (DateTime.now().millisecondsSinceEpoch + randomCount).toString();
        randomCount = randomCount + 1;
        workout.userWorkoutSet = [];
        workout.equalizeSets();
        programDay.workoutList.add(workout);
      });
      programDay.name = 'Custom ' + element.name!;
      programDay.isDayCompleted = false;
      programDay.weekNumber =
          closestProgramDay.weekNumber ?? element.weekNumber;
      programDay.phaseNumber =
          closestProgramDay.phaseNumber ?? element.phaseNumber;
      programDay.programId = element.programId;
      programDay.isAddonDay = false;
      programDayList.add(programDay);
    });
    await setProgramFromPlanner();
    await updateUserSqflite();
    notifyListeners();
  }

  T getRandomElement<T>(List<T> list) {
    final random = new Random();
    var i = random.nextInt(list.length);
    return list[i];
  }

  generateExerciseHistory() {
    for (var i = 1; i < 60; i++) {
      DateTime date = DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day, 12, 0)
          .subtract(Duration(days: 60))
          .add(Duration(days: i));

      List<ExerciseHistoryElement> generatedExerciseHistory =
          List<ExerciseHistoryElement>.generate(
              Random().nextInt(12),
              (index) => ExerciseHistoryElement.fromSqfliteJson({
                    'dateTime': date,
                    'exerciseId': int.parse(
                        getRandomElement(allExerciseList).exerciseId!),
                    'rep': Random().nextInt(20),
                    'weight': Random().nextInt(140)
                  }));

      exerciseHistory.addAll(generatedExerciseHistory);
    }

    // bulk edit //print(exerciseHistory);
  }

  addExerciseHistory({required List<Workout> workoutList, DateTime? date}) {
    List<ExerciseHistoryElement> exHistory = [];
    workoutList.forEach((workout) {
      exerciseHistory.removeWhere((element) =>
          element.dateTime == date &&
          element.exerciseId.toString() == workout.exercise!.exerciseId &&
          element.workoutId.toString() == workout.workoutId);
      String name = '';
      programDayList.forEach((day) {
        day.workoutList.forEach((workout) {
          if (workout.workoutId == workout.workoutId.toString()) {
            workout.userWorkoutSet.forEach((element) {
              element.name = day.name;
            });
          }
        });
      });
      workout.userWorkoutSet.forEach((userWorkout) {
        // 19 means Kneeling Push Up
        if (((workout.exercise!.equipmentGroup.any((equipment) => equipment.equipmentName == 'Bodyweight')) ||
                userWorkout.kg > 0) &&
            userWorkout.rep! > 0)
          exHistory.add(ExerciseHistoryElement.fromSqfliteJson({
            'dateTime': date,
            'exerciseId': workout.exercise!.exerciseId,
            'workoutId': workout.workoutId,
            'rep': userWorkout.rep,
            'weight': userWorkout.kg,
            'name': userWorkout.name,
          }));
      });
    });
    exerciseHistory.addAll(exHistory);
    updateExerciseHistoryJson();
    notifyListeners();
  }

  Future<void> updateExerciseHistoryJson() async {
    List<String> jsonEncodedList = [];
    String jsonEncoded = '';
    exerciseHistory.forEach((exHistory) async {
      jsonEncodedList.add(convert.jsonEncode(exHistory.toJson()));
    });
    jsonEncoded = convert.jsonEncode(jsonEncodedList);
    if (auth.currentUser!.uid != null) {
      Map<String, dynamic> updateElement = {
        'json': jsonEncoded,
        'uid': auth.currentUser!.uid,
        'date': DateTime.now().toIso8601String(),
      };
      // bulk edit //print(updateElement);
      var result = await _sqfLiteDatabase.exerciseHistoryQueryAllRows();
      if (result != null) {
        await _sqfLiteDatabase.exerciseHistoryDeleteAll().then((value) async {
          await _sqfLiteDatabase.exerciseHistoryInsert(updateElement);
        });
      } else {
        await _sqfLiteDatabase.exerciseHistoryInsert(updateElement);
      }
    }
  }

  Future<void> updateProgressPhotoJson() async {
    List<String> jsonEncodedList = [];
    String jsonEncoded = '';
    progressPhotoList.forEach((pp) async {
      jsonEncodedList.add(convert.jsonEncode(pp!.toJson()));
    });
    jsonEncoded = convert.jsonEncode(jsonEncodedList);
    if (auth.currentUser!.uid != null) {
      Map<String, dynamic> updateElement = {
        'json': jsonEncoded,
        'uid': auth.currentUser!.uid,
        'date': DateTime.now().toIso8601String(),
      };
      // bulk edit //print(updateElement);
      var result = await _sqfLiteDatabase.progresPhotoHistoryQueryAllRows();
      if (result != null) {
        await _sqfLiteDatabase
            .progresPhotoHistoryDeleteAll()
            .then((value) async {
          await _sqfLiteDatabase.progresPhotoHistoryInsert(updateElement);
        });
      } else {
        await _sqfLiteDatabase.progresPhotoHistoryInsert(updateElement);
      }
    }
  }

  Future<void> updateCustomExerciseJson() async {
    List<String> jsonEncodedList = [];
    String jsonEncoded = '';
    List<Exercise> customExerciseList =
        allExerciseList.where((element) => element.isCustom!).toList();
    customExerciseList.forEach((ex) async {
      jsonEncodedList.add(convert.jsonEncode(ex.toJson()));
    });
    jsonEncoded = convert.jsonEncode(jsonEncodedList);
    if (auth.currentUser!.uid != null) {
      Map<String, dynamic> updateElement = {
        'json': jsonEncoded,
        'uid': auth.currentUser!.uid,
        'date': DateTime.now().toIso8601String(),
      };
      // bulk edit //print(updateElement);
      var result = await _sqfLiteDatabase.customExerciseQueryAllRows();
      if (result != null) {
        await _sqfLiteDatabase.customExerciseDeleteAll().then((value) async {
          await _sqfLiteDatabase.customExerciseInsert(updateElement);
        });
      } else {
        await _sqfLiteDatabase.customExerciseInsert(updateElement);
      }
    }
  }

  Future<void> scheduleNotification(
      {required int id,
      String? title,
      String? body,
      required DateTime scheduledDate}) async {
    // var scheduledNotificationDateTime =
    //     DateTime.now().add(Duration(seconds: 5));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel description',
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails notificationDetails = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    UILocalNotificationDateInterpretation
        uiLocalNotificationDateInterpretation =
        UILocalNotificationDateInterpretation.absoluteTime;
    String timezoneName = await TimeZone().getTimeZoneName();

    final location = tz.getLocation(timezoneName);
    tz.TZDateTime tzDateTime =
        tz.TZDateTime.from(scheduledDate.toLocal(), location);
    await flutterLocalNotificationsPlugin.schedule(
        id, title, body, tzDateTime, notificationDetails,
        androidAllowWhileIdle: false, payload: scheduledDate.toIso8601String());
  }

  Future<void> saveWorkoutToPlannerWithouCompleted(
      ProgramDay programDay) async {
    programDayList.where((element) => element == programDay).toList().first =
        programDay;
    DateTime date = DateTime(programDay.dateTime!.year,
        programDay.dateTime!.month, programDay.dateTime!.day, 12, 0);
    addExerciseHistory(workoutList: programDay.workoutList, date: date);

    notifyListeners();
    await updateUserSqflite();
    await setProgramFromPlanner();
  }

  Future<void> saveWorkoutToPlanner(ProgramDay programDay) async {
    programDay.checkCompleted(); // It is checking is day completed;
    programDayList.where((element) => element == programDay).toList().first =
        programDay;
    DateTime date = DateTime(programDay.dateTime!.year,
        programDay.dateTime!.month, programDay.dateTime!.day, 12, 0);

    addExerciseHistory(workoutList: programDay.workoutList, date: date);

    // bulk edit //print(programDayList);
    notifyListeners();
    await updateUserSqflite();
    await setProgramFromPlanner();
  }

  Future<void> postponePlanner({int? postponeDay}) async {
    if (programDayList.isNotEmpty) {
      programDayList
          .where((element) => element.dateTime!.isAfter(DateTime.now()))
          .forEach((element) {
        element.dateTime = element.dateTime!.add(Duration(days: postponeDay!));
      });
      notifyListeners();

      await updateUserSqflite();
      await setProgramFromPlanner();
    }
  }

  Future<void> rescheduleDays({DateTime? rescheudleDate}) async {
    if (programDayList.isNotEmpty) {
      int index = 0;
      late Duration difference;
      bool isAfter;
      ProgramDay firstNewDay = programDayList
          .firstWhere((day) => day.dateTime!.isAfter(DateTime.now()));
      programDayList
          .where((day) => day.dateTime!.isAfter(DateTime.now()))
          .forEach((element) {
        if (index == 0) {
          difference = firstNewDay.dateTime!.difference(rescheudleDate!);
          element.dateTime = rescheudleDate;
        } else {
          if (difference.isNegative) {
            Duration dff = difference * (-1);
            element.dateTime = element.dateTime!.add(dff);
          } else {
            element.dateTime = element.dateTime!.subtract(difference);
          }
        }

        index = index + 1;
      });
      notifyListeners();

      await updateUserSqflite();
      await setProgramFromPlanner();
    }
  }

  Future<void> updateBodystatsJson() async {
    List<String> jsonEncodedList = [];
    String jsonEncoded = '';
    bodystatsDayList.forEach((bodystatDay) async {
      String jsonConvertedString = convert.jsonEncode(bodystatDay!.toJson());
      if (jsonEncodedList
          .where((element) => element == jsonConvertedString)
          .isEmpty)
        jsonEncodedList.add(convert.jsonEncode(bodystatDay.toJson()));
    });
    jsonEncoded = convert.jsonEncode(jsonEncodedList);
    if (auth.currentUser!.uid != null) {
      Map<String, dynamic> updateElement = {
        'json': jsonEncoded,
        'uid': auth.currentUser!.uid,
        'date': DateTime.now().toIso8601String(),
      };
      var result = await _sqfLiteDatabase.bodystatsQueryAllRows();
      if (result != null) {
        await _sqfLiteDatabase.bodystatsDeleteAll().then((value) async {
          await _sqfLiteDatabase.bodystatsInsert(updateElement);
        });
      } else {
        await _sqfLiteDatabase.bodystatsInsert(updateElement);
      }
    }
  }

  getUserPrograms() async {
    List<String?>? userPrograms = await _service.phpGetUserPrograms();
    loggedInuser!.userPrograms = userPrograms ?? null;
    if (userPrograms != null && userPrograms.isNotEmpty) {
      lastProgramId = userPrograms.last;
    }
    notifyListeners();
  }

  Future<void> getUserInfo() async {
    if (FirebaseAuth.instance.currentUser != null) {
      // signed in
      loggedInuser = await _service.getUserInfo(
          uid: FirebaseAuth.instance.currentUser!.uid);
      if (loggedInuser!.isGeneralInfoFilled!) {
        BodystatsDay initialBodyStat = BodystatsDay();
        initialBodyStat.dateTime = DateTime(loggedInuser!.registerDate.year,
            loggedInuser!.registerDate.month, loggedInuser!.registerDate.day);
        initialBodyStat.isCompleted = true;
        initialBodyStat.measurements = [];
        initialBodyStat.isInitialBodyStat = true;

        Measurement? bodyWeight;
        if (loggedInuser!.bodyWeightInKilo != null) {
          bodyWeight = Measurement();
          bodyWeight.dateTime = initialBodyStat.dateTime;
          bodyWeight.name = 'Body Weight';
          bodyWeight.value = loggedInuser!.bodyWeightInKilo!.toDouble();
          initialBodyStat.measurements.add(bodyWeight);
        }
        Measurement? bodyFat;
        if (loggedInuser!.bodyFatPercentage != null) {
          bodyFat = Measurement();
          bodyFat.dateTime = initialBodyStat.dateTime;
          bodyFat.name = 'Body Fat';
          bodyFat.value = loggedInuser!.bodyFatPercentage;
          initialBodyStat.measurements.add(bodyFat);
        }
        List<BodystatsDay?> tempBodystatsDayList = bodystatsDayList
            .where((element) =>
                element!.dateTime ==
                DateTime(
                    initialBodyStat.dateTime!.year,
                    initialBodyStat.dateTime!.month,
                    initialBodyStat.dateTime!.day))
            .toList();

        if (tempBodystatsDayList.isEmpty) {
          bodystatsDayList.add(initialBodyStat);
        } else {
          tempBodystatsDayList.first!.isInitialBodyStat = true;
          if (bodyWeight != null &&
              tempBodystatsDayList.first!.measurements
                  .where((measure) => measure.name == 'Body Weight')
                  .isNotEmpty) {
            tempBodystatsDayList.first!.measurements
                .removeWhere((measure) => measure.name == 'Body Weight');
            tempBodystatsDayList.first!.measurements.add(bodyWeight);
          }
          if (bodyFat != null &&
              tempBodystatsDayList.first!.measurements
                  .where((measure) => measure.name == 'Body Fat')
                  .isNotEmpty) {
            tempBodystatsDayList.first!.measurements
                .removeWhere((measure) => measure.name == 'Body Fat');
            tempBodystatsDayList.first!.measurements.add(bodyFat);
          }
        }
      }

      notifyListeners();
    }
  }

  // Future<void> updateProgramJson({String? uid}) async {
  //   List<String?> programIdList =
  //       programDayList.map((e) => e.programId).toSet().toList(); // Uniquize

  //   programIdList.forEach((programId) async {
  //     List<String> jsonEncodedList = [];
  //     String jsonEncoded = '';
  //     List<ProgramDay> programDayLocalList = programDayList
  //         .where(
  //             (element) => element.programId == programId && element.uid == uid)
  //         .toList();
  //     programDayLocalList.forEach((programDay) async {
  //       jsonEncodedList.add(convert.jsonEncode(programDay.toJson()));
  //     });
  //     jsonEncoded = convert.jsonEncode(jsonEncodedList);

  //     Map<String, dynamic> updateElement = {
  //       'json': jsonEncoded,
  //       'program_id': programDayLocalList.first.programId,
  //       'uid': programDayLocalList.first.uid,
  //     };

  //     int? result = await _sqfLiteDatabase.plannerUpdate(updateElement);
  //     if (result != null && result < 1) {
  //       // If dont have program
  //       updateElement['register_date'] = DateTime.now().toIso8601String();
  //       updateElement['isActive'] = 1;
  //       updateElement['isAddon'] =
  //           programDayLocalList.first.isAddonDay! ? 1 : 0;
  //       await _sqfLiteDatabase.plannerInsert(updateElement);
  //     }
  //   });
  // }

  // ignore: missing_return
  Future<void> setExerciseOfWorkouts() async {
    if (programDayList.isNotEmpty) {
      programDayList.forEach((day) {
        day.workoutList.forEach((workout) {
          if (allExerciseList
              .where((element) =>
                  element.exerciseId == workout.exerciseId.toString())
              .isNotEmpty)
            workout.exercise = allExerciseList
                .where((element) =>
                    element.exerciseId == workout.exerciseId.toString())
                .first;
        });
      });
      notifyListeners();
    }
  }

  Future<void> logOut() async {
    plannerMainProgram = null;
    plannerAddonProgram = null;
    programDayList = [];
    bodystatsDayList = [];
    allExerciseList = [];
    exerciseHistory = [];
    progressPhotoList = [];
    loggedInuser = null;
    notifyListeners();
  }
}
