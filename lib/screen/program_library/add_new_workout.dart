import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../model/program/programDay.dart';
import '../../model/program/program_model.dart';
import '../../model/program/workout.dart';
import '../../screen/program_library/widgets/workout_slideable_element.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class AddNewWorkout extends StatefulWidget {
  @override
  _AddNewWorkoutState createState() => _AddNewWorkoutState();
}

class _AddNewWorkoutState extends State<AddNewWorkout> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  ProgramDay? programDay;
  Function? programDayCallback;
  String? workoutName;
  TextEditingController _workoutNameController = TextEditingController();
  late var _tapPosition;
  var _count = 0;

  changeWorkoutName(BuildContext context, UserObject? user) {
    Widget okButton = TextButton(
      child: Text(
        "Save",
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        setState(() {
          workoutName = _workoutNameController.text;
          programDay!.name = workoutName;
        });
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Change Workout Name"),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: TextField(
          controller: _workoutNameController,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(0.0),
            isDense: true,
          ),
        ),
      ),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // ignore: missing_return
  Function? deleteWorkoutCallback(Workout workout) {
    setState(() {
      programDay!.workoutList = programDay!.workoutList
          .where((element) => element != workout)
          .toList();
    });
  }

  // ignore: missing_return
  Function? substituteWorkoutCallback(Workout workout) {
    setState(() {
      programDay!.workoutList = programDay!.workoutList
          .where((element) => element != workout)
          .toList();
    });
  }

  Function? _showCustomMenu(Workout workout) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;

    showMenu(
            context: context,
            items: <PopupMenuEntry<int>>[
              PopupMenu(
                workout: workout,
                deleteCallback: deleteWorkoutCallback,
                substituteWorkoutCallback: substituteWorkoutCallback,
                programDay: programDay,
                addWorkoutCallback: addWorkoutCallback,
              )
            ],
            position: RelativeRect.fromRect(
                _tapPosition & const Size(40, 40), Offset.zero & overlay.size))
        .then<void>((int? delta) {
      if (delta == null) return;
      setState(() {
        _count = _count + delta;
      });
    });
  }

  // ignore: unused_element
  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  void addWorkoutCallback() {
    // bulk edit //print(programDay);
    setState(() {
      programDay = programDay;
    });
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

  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
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
    Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    programDayCallback = args['programDayCallback'];
    if (args['programDay'] != null && programDay == null) {
      programDay = args['programDay'];
    }
    if (programDay == null) {
      programDay = ProgramDay();
    }
    if (programDay != null && workoutName == null) {
      workoutName = programDay!.name ?? 'Workout';
    }
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                    onTap: () => Navigator.pop(context), child: Text('Cancel')),
                // GestureDetector(
                //     onTap: () {
                //       Navigator.pushNamed(context, '/workout_notes');
                //     },
                //     child: Icon(Icons.article)),
                Text('New Workout'),
                GestureDetector(
                    onTap: () => showAlertDialog(context),
                    child: Icon(Icons.info_outline)),
                GestureDetector(
                    onTap: () {
                      programDayCallback!(programDay);
                      Navigator.pop(context);
                    },
                    child: Text('Save')),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  Text(workoutName ?? ''),
                  SizedBox(width: 10),
                  GestureDetector(
                      onTap: () => changeWorkoutName(context, user),
                      child: Icon(Icons.edit)),
                ],
              ),
            ),
            Divider(thickness: 2),
            programDay!.workoutList.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: programDay!.workoutList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return WorkoutSlideableElement(
                            removeWorkoutCallback: removeWorkoutCallback,
                            changeWorkoutCallback: changeWorkoutCallback,
                            workout: programDay!.workoutList[index],
                            showKg: false,
                          );
                        }))
                : Container(),
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
                      'Add New Exercise',
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
            // RaisedButton(
            //   padding: EdgeInsets.symmetric(horizontal: 20),
            //   onPressed: () {},
            //   color: Color.fromRGBO(8, 112, 138, 1),
            //   child: Text(
            //     'Start Workout',
            //     style: TextStyle(
            //       fontWeight: FontWeight.bold,
            //       color: Colors.white,
            //     ),
            //   ),
            // )
          ],
        ),
      )),
    );
  }
}

// ignore: must_be_immutable
class PopupMenu extends PopupMenuEntry<int> {
  Workout? workout;
  Function? deleteCallback;
  Function? substituteWorkoutCallback;
  ProgramDay? programDay;
  Function? addWorkoutCallback;
  bool isVisible = true;
  PopupMenu(
      {this.workout,
      this.deleteCallback,
      this.substituteWorkoutCallback,
      this.programDay,
      this.addWorkoutCallback});
  @override
  double height = 100;

  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  PopupMenuState createState() => PopupMenuState();
}

class PopupMenuState extends State<PopupMenu> {
  String message = '';
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Visibility(
            visible: widget.isVisible,
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      message = "You've Succesfully Delete the Exercise!";
                    });
                    // bulk edit //print('Remove exercise Tapped');
                    Provider.of<ProgramModel>(context, listen: false)
                        .deleteWorkoutFromNewProgram(widget.workout);
                    widget.deleteCallback!(widget.workout);
                    setState(() {
                      widget.isVisible = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Remove exercise'),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                        ),
                        Icon(Icons.add),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      message = "You've Succesfully Substituted the Exercise!";
                    });
                    // bulk edit //print('Substitute exercise Tapped');
                    widget.substituteWorkoutCallback!(widget.workout);
                    Navigator.pushNamed(context, '/exercise_list', arguments: {
                      'programDay': widget.programDay,
                      'addWorkoutCallback': widget.addWorkoutCallback
                    });
                    setState(() {
                      widget.isVisible = false;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Substitute exercise'),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                        ),
                        Icon(Icons.add),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // bulk edit //print('Analysis Tapped');
                    Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/exercise_stats',
                        (Route route) => route.settings.name == '/navigation',
                        arguments: {'exerciseId': widget.workout!.exerciseId});
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Analysis'),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                        ),
                        Icon(Icons.add),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(visible: !widget.isVisible, child: Text(message)),
        ],
      ),
    );
  }
}
