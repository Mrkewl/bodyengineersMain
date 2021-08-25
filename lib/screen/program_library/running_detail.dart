import '../../model/program/runningWorkout.dart';
import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../model/program/programDay.dart';
import '../../model/planner/planner_model.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class RunningDetailPage extends StatefulWidget {
  @override
  _RunningDetailPageState createState() => _RunningDetailPageState();
}

class _RunningDetailPageState extends State<RunningDetailPage> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  ProgramDay? programDay;
  bool? isEdit;
  TextEditingController _kilometerController = TextEditingController();
  TextEditingController _hourController = TextEditingController();
  TextEditingController _minuteController = TextEditingController();
  TextEditingController _secondController = TextEditingController();
  RunningWorkout? runningWorkout;
  RunningWorkout? oldrunningWorkout;
  Function? achievementCallback;

  bool didChange = false;
  void notesCallback() {
    setState(() {
      programDay = programDay;
    });
  }

  editProgramDay() {
    setState(() {
      isEdit = true;
    });
  }

  successPopup(BuildContext context) {
    Widget okButton = FlatButton(
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
            arguments: {'index': 1});
        if (achievementCallback != null) achievementCallback!();
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

  // @override
  // void didChangeDependencies() {
  //
  //   super.didChangeDependencies();
  //   if (!didChange) {
  //     if (runningWorkout != null) {
  //       setState(() {
  //         _kilometerController.text = runningWorkout.distance.toString();
  //         _hourController.text = runningWorkout.hours.toString();
  //         _minuteController.text = runningWorkout.minutes.toString();
  //         _secondController.text = runningWorkout.seconds.toString();
  //         didChange = true;
  //       });
  //     }
  //   }
  // }

  setRunningData() {
    setState(() {
      _kilometerController.text = runningWorkout!.distance.toString();
      _hourController.text = runningWorkout!.hours.toString();
      _minuteController.text = runningWorkout!.minutes.toString();
      _secondController.text = runningWorkout!.seconds.toString();
    });
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () => Navigator.pop(context),
    );

    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.all(15),
      actionsPadding: EdgeInsets.all(0),
      content: Text("There will be an info message withing this alert dialog"),
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

    if (isEdit == null && programDay != null && programDay!.isDayCompleted) {
      isEdit = false;
    } else {
      isEdit = true;
    }
    Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    if (achievementCallback == null)
      achievementCallback = args['achievementCallback'];
    programDay = args['programDay'];
    if (runningWorkout == null) {
      setState(() {
        runningWorkout = args['runningWorkout'];
        oldrunningWorkout = runningWorkout;
      });
      setRunningData();
    }

    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: runningWorkout == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                            onTap: () => Navigator.pushNamedAndRemoveUntil(
                                context, '/navigation', (route) => false,
                                arguments: {'index': 1}),
                            child: Text('Cancel')),
                        Text('Workout Log'),
                        GestureDetector(
                            onTap: () => showAlertDialog(context),
                            child: Icon(Icons.info_outline)),
                        GestureDetector(
                            onTap: () {
                              runningWorkout!.distance =
                                  double.parse(_kilometerController.text);
                              runningWorkout!.hours =
                                  int.parse(_hourController.text);
                              runningWorkout!.minutes =
                                  int.parse(_minuteController.text);
                              runningWorkout!.seconds =
                                  int.parse(_secondController.text);
                              programDay!.workoutList
                                  .where((element) =>
                                      element.runningWorkout ==
                                      oldrunningWorkout)
                                  .first
                                  .runningWorkout = runningWorkout;
                              successPopup(context);
                            },
                            child: Text('Save')),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      child: Row(
                        children: [
                          Container(
                            width: 35,
                            child: Image.asset(
                              'assets/images/workout/running.png',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Running',
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Distance',
                      style: TextStyle(fontSize: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 30),
                      child: Row(
                        children: [
                          Container(
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  spreadRadius: 3,
                                )
                              ],
                            ),
                            padding: EdgeInsets.only(
                                top: 5, bottom: 5, left: 3, right: 3),
                            child: TextField(
                              controller: _kilometerController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(0.0),
                                isDense: true,
                              ),
                            ),
                          ),
                          SizedBox(width: 15),
                          Text('Km'),
                        ],
                      ),
                    ),
                    Text(
                      'Time',
                      style: TextStyle(fontSize: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 30),
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  spreadRadius: 3,
                                )
                              ],
                            ),
                            padding: EdgeInsets.only(
                                top: 5, bottom: 5, left: 3, right: 3),
                            child: TextField(
                              controller: _hourController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(0.0),
                                isDense: true,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('HH'),
                          ),
                          Container(
                            width: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  spreadRadius: 3,
                                )
                              ],
                            ),
                            padding: EdgeInsets.only(
                                top: 5, bottom: 5, left: 3, right: 3),
                            child: TextField(
                              controller: _minuteController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(0.0),
                                isDense: true,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('MM'),
                          ),
                          Container(
                            width: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  spreadRadius: 3,
                                )
                              ],
                            ),
                            padding: EdgeInsets.only(
                                top: 5, bottom: 5, left: 3, right: 3),
                            child: TextField(
                              controller: _secondController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(0.0),
                                isDense: true,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('SS'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
