import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';

import '../../screen/program_library/widgets/workout_element.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sounds/sounds.dart';
// import 'package:vibration/vibration.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../model/planner/planner_model.dart';
import '../../model/program/programDay.dart';
import '../../model/program/workout.dart';
import '../../model/program/workoutSet.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class WorkoutDay extends StatefulWidget {
  @override
  _WorkoutDayState createState() => _WorkoutDayState();
}

class _WorkoutDayState extends State<WorkoutDay> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  double _duration = 0;
  ProgramDay? programDay;
  var _tapPosition;
  var _count = 0;
  String timerString = '';
  int? _start;
  Timer? _timer;
  late StreamController<int?> _events;
  late SharedPreferences prefs;
  int? _alarmValue;
  // late SoundPlayer _trackPlayer;
  ScrollController _scrollController = ScrollController();
  bool? isEdit;
  Function? achievementCallback;
  int? navigateIndex = 1;
  late AudioPlayer _player;

  AudioSource audioSource = AudioSource.uri(
    Uri.parse("asset:///assets/sounds/alarm.wav"),
  );
  // final track = Track.fromAsset('assets/sounds/alarm.wav');
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

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();

      _alarmValue = prefs.getInt('alarmUnit') ?? 1;
      _player = AudioPlayer();
      await _player.setAudioSource(audioSource);
    });
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

  successPopup(BuildContext context) {
    Widget okButton = TextButton(
      child: Text(
        "Thanks!",
        style: TextStyle(
            color: Color.fromRGBO(8, 112, 138, 1),
            fontSize: 16,
            fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        Provider.of<PlannerModel>(context, listen: false)
            .saveWorkoutToPlanner(programDay!);
        Navigator.pushNamedAndRemoveUntil(
            context, '/navigation', (route) => false,
            arguments: {'index': navigateIndex ?? 1});
        if (achievementCallback != null) achievementCallback!;
      },
    );

    AlertDialog alert = AlertDialog(
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
        okButton,
      ],
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () => Navigator.pop(context),
    );

    AlertDialog alert = AlertDialog(
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
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;

    Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    if (args['index'] != null) navigateIndex = args['index'];

    if (achievementCallback == null)
      achievementCallback = args['achievementCallback'];
    programDay = args['programDay'];
    if (isEdit == null && programDay != null && programDay!.isDayCompleted) {
      isEdit = false;
    } else {
      isEdit = true;
    }
    programDay!.workoutList.forEach((element) {
      if (element.userWorkoutSet == null) {
        element.userWorkoutSet = [];
        element.userWorkoutSet
            .add(WorkoutSet.fromLocalJson({'rep': 0, 'kg': 0.0}));
      }
    });
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      floatingActionButton: SpeedDial(
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
              label: allTranslations.text('start_timer')!,
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
            label: allTranslations.text('select_timer')!,
            labelStyle: TextStyle(
              fontSize: 18.0,
              color: Color.fromRGBO(44, 44, 44, 1),
            ),
            onTap: () => selectTimerDialog(context),
          ),
        ],
      ),
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
                      onTap: () => Navigator.pop(context),
                      child: Text(allTranslations.text('cancel')!),
                    ),
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
                          // // bulk edit //print(programDay);
                          // await Provider.of<PlannerModel>(context,
                          //         listen: false)
                          //     .saveWorkoutToPlanner(programDay);
                          // Navigator.pushNamed(context, '/workout_log',
                          //     arguments: {'programDay': programDay});

                          // Provider.of<PlannerModel>(context, listen: false)
                          //     .saveWorkoutToPlanner(programDay);
                          // Navigator.pushNamedAndRemoveUntil(
                          //     context, '/navigation', (route) => false,
                          //     arguments: {'index': 1});
                          if (!isEdit! && programDay!.isDayCompleted) {
                            editProgramDay();
                          } else {
                            successPopup(context);
                          }
                        },
                        child: Text(isEdit!
                            ? allTranslations.text('save')!
                            : programDay!.isDayCompleted
                                ? allTranslations.text('edit')!
                                : allTranslations.text('save')!)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: programDay!.workoutList.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return programDay!
                                .workoutList[index].exercise!.isCardio!
                            ? Container()
                            : WorkoutElement(
                                workout: programDay!.workoutList[index],
                                changeWorkoutCallback: changeWorkoutCallback,
                                removeWorkoutCallback: removeWorkoutCallback,
                                isEdit: false,
                                programDay: programDay,
                              );
                      }),
                ),
                Divider(thickness: 2),
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
                          allTranslations.text('add_new_exercise')!,
                          style: TextStyle(
                            fontSize: 17,
                            color: Color.fromRGBO(44, 44, 44, 1),
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
                Divider(thickness: 2),
                Visibility(
                  visible: isEdit! ? true : false,
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    onPressed: () async {
                      if (!isEdit! && programDay!.isDayCompleted) {
                        editProgramDay();
                      } else {
                        successPopup(context);
                      }
                    },
                    color: Color.fromRGBO(8, 112, 138, 1),
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
