import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../../screen/program_library/widgets/workout_element.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:lottie/lottie.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sounds/sounds.dart';
import 'package:vibration/vibration.dart';

import '../../be_theme.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../model/planner/planner_model.dart';
import '../../model/program/programDay.dart';
import '../../model/program/workout.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';
import './widgets/workout_slideable_element.dart';

class WorkoutLog extends StatefulWidget {
  @override
  _WorkoutLogState createState() => _WorkoutLogState();
}

class _WorkoutLogState extends State<WorkoutLog> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  ProgramDay? programDay;
  Function? achievementCallback;
  ScrollController _scrollController = ScrollController();
  bool? isEdit;
  bool? isFirstTime;
  MyTheme theme = MyTheme();
  int? navigateIndex = 1;
  int? _start;
  Timer? _timer;
  late StreamController<int?> _events;
  double _duration = 0;
  // late SoundPlayer _trackPlayer;
  // final track = Track.fromAsset('assets/sounds/alarm.wav');
  int? _alarmValue;
  late SharedPreferences prefs;
  late AudioPlayer _player;
  AudioSource audioSource = AudioSource.uri(
    Uri.parse("asset:///assets/sounds/alarm.wav"),
  );
  // ignore: missing_return
  Function? changeWorkoutCallback(String workoutId, Workout workout) {
    setState(() {
      programDay!.workoutList
          .where((element) => element.workoutId == workoutId)
          .toList()
          .first = workout;
      // bulk edit //print(programDay.workoutList);
    });
  }

  // ignore: missing_return
  Function? removeWorkoutCallback(String workoutId, bool referExercise) {
    setState(() {
      programDay!.workoutList = programDay!.workoutList
          .where((element) => element.workoutId != workoutId)
          .toList();
      // bulk edit //print(programDay.workoutList);
    });
    if (referExercise) {
      Navigator.pushNamed(context, '/exercise_list', arguments: {
        'programDay': programDay,
        'addWorkoutCallback': addWorkoutCallback
      });
    }
  }

  void notesCallback() {
    setState(() {
      programDay = programDay;
    });
  }

  void addWorkoutCallback() {
    // bulk edit //print(programDay);
    setState(() {
      programDay = programDay;
    });
    Future.delayed(Duration(milliseconds: 100), () async {
      await scrollBottom();
    });
  }

  Future<void> scrollBottom() async {
    await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.easeIn);
  }

  editProgramDay() {
    setState(() {
      isEdit = true;
    });
  }

  successPopup(BuildContext context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("You're Great!"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 100,
                  height: 100,
                  child: Lottie.asset('assets/json/success.json')),
              SizedBox(height: 20),
              Text(
                "Good job. Keep going!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                "Thanks!",
                style: TextStyle(
                    color: Color.fromRGBO(8, 112, 138, 1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await Provider.of<PlannerModel>(context, listen: false)
                    .saveWorkoutToPlanner(programDay!);

                Navigator.pushNamedAndRemoveUntil(
                    context, '/navigation', (route) => false,
                    arguments: {'index': navigateIndex});
                achievementCallback!();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    if (_timer != null) _timer!.cancel();
    _player.dispose();
    super.dispose();
  }

  alertVibrate() {
    // bulk edit //print(_alarmValue);
    switch (_alarmValue) {
      case 1:

        // bulk edit //print('ALARM and Vibration');
        Future.delayed(Duration.zero, () async {
          _player.play().whenComplete(() async {
            await _player.seek(Duration(seconds: 0));
            await _player.pause();
          });
          bool? hasVibrator = await Vibration.hasVibrator();

          if (hasVibrator != null && hasVibrator) {
            Vibration.vibrate(duration: 1000);
          }
        });
        break;

      case 2:
        // bulk edit //print('Only Vibration');
        Future.delayed(Duration.zero, () async {
          bool? hasVibrator = await Vibration.hasVibrator();

          if (hasVibrator != null && hasVibrator) {
            Vibration.vibrate(duration: 1000);
          }
        });
        break;

      case 3:
        // bulk edit //print('No Alarm No Vibration');

        break;

      default:
    }
  }

  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _start = _start ?? 0;
    int selectedstart = _start ?? 0;
    _events = new StreamController<int?>();
    _events.add(_start);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        (selectedstart > 0) ? selectedstart-- : _timer!.cancel();
      });
      // bulk edit //print(_start);
      _events.add(selectedstart);
    });
  }

  selectTimerDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () => Navigator.pop(context),
    );
    Widget saveButton = TextButton(
        child: Text("Save"),
        onPressed: () {
          Navigator.pop(context);
        });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(15),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ((_duration / 60).floor()).toString() +
                        ':' +
                        (_duration % 60).round().toString() +
                        ' Minutes',
                  ),
                  Slider(
                    min: 0,
                    max: 600,
                    divisions: 40,
                    value: _duration,
                    onChanged: (value) {
                      setState(() {
                        _duration = value;
                        _start = _duration
                            .round(); //(_duration.round() * 60).round();
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[cancelButton, saveButton],
            );
          },
        );
      },
    );
  }

  startTimerDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(
        "Dismiss",
        style: TextStyle(color: Colors.black),
      ),
      onPressed: () {
        _events.close();
        _timer!.cancel();
        // Vibration.cancel();
        // _trackPlayer.stop(wasUser: false);
        Navigator.pop(context);
      },
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                backgroundColor: Colors.white,
                title: Text(
                  'Timer',
                  style: TextStyle(color: Colors.black),
                ),
                contentPadding: EdgeInsets.all(15),
                actions: <Widget>[cancelButton],
                content: StreamBuilder<int?>(
                    stream: _events.stream,
                    builder:
                        (BuildContext context, AsyncSnapshot<int?> snapshot) {
                      // bulk edit //print(snapshot.data.toString());
                      if (snapshot.data != null) {
                        if (snapshot.data! < 1) {
                          alertVibrate();
                        }
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ((snapshot.data! / 60).floor()).toString() +
                                  ':' +
                                  (snapshot.data! % 60).round().toString(),
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    }));
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();

      // _trackPlayer = SoundPlayer.noUI();
      _alarmValue = prefs.getInt('alarmUnit') ?? 1;
      _player = AudioPlayer();
      await _player.setAudioSource(audioSource);
    });
  }

  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(15),
          actionsPadding: EdgeInsets.all(0),
          content: Text('''Here are the actions between the workout log:
1. To start your workout, scroll all the way down to tap on start workout

2. To edit your program and not start, tap on the sets and reps of each individual exercise

3. You are able to write notes on the notepad icon

4. You are able to save your workouts using the save button at the top right corner

5. You are able to view how to do the exercises by tapping on the icons

6. You can substitute, remove or add exercises in this plan'''),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    if (args['index'] != null) navigateIndex = args['index'];
    if (achievementCallback == null && args['achievementCallback'] != null)
      achievementCallback = args['achievementCallback'];
    programDay = args['programDay'];
    if (!programDay!.isDayCompleted) {
      isFirstTime = true;
    } else {
      isFirstTime = false;
    }
    if (isEdit == null && programDay != null && programDay!.isDayCompleted) {
      isEdit = false;
    } else {
      isEdit = true;
    }
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      floatingActionButton: isEdit! && !isFirstTime!
          ? SpeedDial(
              child: Icon(Icons.alarm),
              curve: Curves.easeIn,
              overlayColor: Colors.black,
              overlayOpacity: 0.5,
              onOpen: () => print('OPENING DIAL'),
              onClose: () => print('DIAL CLOSED'),
              backgroundColor: Color.fromRGBO(8, 112, 138, 1),
              foregroundColor: Colors.white,
              elevation: 8.0,
              shape: CircleBorder(),
              children: [
                SpeedDialChild(
                    child: Icon(
                      Icons.alarm,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.grey,
                    label: 'Start Timer',
                    labelStyle: TextStyle(
                      fontSize: 18.0,
                      color: Color.fromRGBO(44, 44, 44, 1),
                    ),
                    onTap: () {
                      _startTimer();
                      return startTimerDialog(context);
                    }),
                SpeedDialChild(
                  child: Icon(
                    Icons.alarm,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.red,
                  label: 'Select Timer',
                  labelStyle: TextStyle(
                    fontSize: 18.0,
                    color: Color.fromRGBO(44, 44, 44, 1),
                  ),
                  onTap: () => selectTimerDialog(context),
                ),
              ],
            )
          : null,
      body: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                        onTap: () => Navigator.pushNamedAndRemoveUntil(
                            context, '/navigation', (route) => false,
                            arguments: {'index': navigateIndex}),
                        child: Text(allTranslations.text('cancel')!)),
                    GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/workout_notes',
                              arguments: {
                                'callback': notesCallback,
                                'programDay': programDay
                              });
                        },
                        child: Icon(Icons.article)),
                    Text(allTranslations.text('workout_log')!),
                    GestureDetector(
                        onTap: () => showAlertDialog(context),
                        child: Icon(Icons.info_outline)),
                    GestureDetector(
                        onTap: () async {
                          if (!isEdit! &&
                              programDay!.isDayCompleted &&
                              programDay!.workoutList
                                  .where(
                                      (element) => !element.exercise!.isCardio!)
                                  .isNotEmpty) {
                            editProgramDay();
                          } else {
                            await Provider.of<PlannerModel>(context,
                                    listen: false)
                                .saveWorkoutToPlannerWithouCompleted(
                                    programDay!);
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/navigation', (route) => false,
                                arguments: {'index': navigateIndex});
                          }
                          // else {
                          //   await successPopup(context);
                          // }
                        },
                        child: Text(isEdit!
                            ? allTranslations.text('save')!
                            : programDay!.isDayCompleted &&
                                    programDay!.workoutList
                                        .where((element) =>
                                            !element.exercise!.isCardio!)
                                        .isNotEmpty
                                ? allTranslations.text('edit')!
                                : allTranslations.text('save')!)),
                  ],
                ),
                if (isEdit! && programDay!.isDayCompleted)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: programDay!.workoutList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return WorkoutElement(
                            workout: programDay!.workoutList[index],
                            changeWorkoutCallback: changeWorkoutCallback,
                            removeWorkoutCallback: removeWorkoutCallback,
                            isEdit: false,
                            programDay: programDay,
                          );
                        }),
                  ),
                if (!programDay!.isDayCompleted)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: programDay!.workoutList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return WorkoutSlideableElement(
                            programDay: programDay,
                            workout: programDay!.workoutList[index],
                            showKg: false,
                            removeWorkoutCallback: removeWorkoutCallback,
                            changeWorkoutCallback: changeWorkoutCallback,
                          );
                        }),
                  ),
                if (!isEdit!)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: programDay!.workoutList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return WorkoutElement(
                            workout: programDay!.workoutList[index],
                            changeWorkoutCallback: changeWorkoutCallback,
                            removeWorkoutCallback: removeWorkoutCallback,
                            isEdit: true,
                            programDay: programDay,
                          );
                        }),
                  ),
                if (isEdit!) Divider(thickness: 2),
                if (isEdit!)
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/exercise_list',
                        arguments: {
                          'programDay': programDay,
                          'addWorkoutCallback': addWorkoutCallback
                        }),
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Spacer(),
                          Icon(Icons.add),
                          SizedBox(width: 10),
                          Text(
                            allTranslations.text('add_new_set')!,
                            style: TextStyle(
                              fontSize: 17,
                              color: theme.currentTheme() == ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                if (isEdit!) Divider(thickness: 2),
                Visibility(
                  visible: programDay!.workoutList
                          .where((element) => !element.exercise!.isCardio!)
                          .isEmpty
                      ? false
                      : programDay!.isDayCompleted
                          ? false
                          : true,
                  child: ElevatedButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      Navigator.pushNamed(context, '/workout_day', arguments: {
                        'programDay': programDay,
                        'achievementCallback': achievementCallback
                      });
                    },
                    // color: Color.fromRGBO(8, 112, 138, 1),
                    child: Text(
                      allTranslations.text('start_workout')!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: programDay!.workoutList
                          .where((element) => !element.exercise!.isCardio!)
                          .isEmpty
                      ? false
                      : programDay!.isDayCompleted && isEdit!
                          ? true
                          : false,
                  child: ElevatedButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                    ),
                    onPressed: () async {
                      if (!isEdit! &&
                          programDay!.isDayCompleted &&
                          programDay!.workoutList
                              .where((element) => !element.exercise!.isCardio!)
                              .isNotEmpty) {
                        editProgramDay();
                      } else {
                        await Provider.of<PlannerModel>(context, listen: false)
                            .saveWorkoutToPlannerWithouCompleted(programDay!);
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/navigation', (route) => false,
                            arguments: {'index': navigateIndex});
                      }
                    },
                    child: Text(
                      allTranslations.text('save_workout')!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
