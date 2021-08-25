import '../../../model/program/programDay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../be_theme.dart';
import '../../../model/program/workout.dart';

// ignore: must_be_immutable
class WorkoutSlideableElement extends StatefulWidget {
  ProgramDay? programDay;
  Workout? workout;
  Function? changeWorkoutCallback;
  Function? removeWorkoutCallback;
  bool? showKg;
  WorkoutSlideableElement(
      {this.workout,
      this.programDay,
      this.changeWorkoutCallback,
      this.removeWorkoutCallback,
      this.showKg});
  @override
  _WorkoutSlideableElementState createState() =>
      _WorkoutSlideableElementState();
}

class _WorkoutSlideableElementState extends State<WorkoutSlideableElement> {
  late var _tapPosition;
  // double _duration = 0;
  TextEditingController _repsController = TextEditingController();
  TextEditingController _kgController = TextEditingController();
  var _count = 0;
  MyTheme theme = MyTheme();

  changeSets(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () => Navigator.pop(context),
    );
    Widget saveButton = TextButton(
      child: Text("Save"),
      onPressed: () {
        widget.changeWorkoutCallback!(widget.workout!.workoutId, widget.workout);
        Navigator.pop(context);
      },
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Change Sets"),
              contentPadding: EdgeInsets.all(15),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    min: 0,
                    max: 12,
                    value: widget.workout!.sets!.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        widget.workout!.sets = value.round();
                      });
                      widget.workout!.equalizeSets();
                    },
                  ),
                  Text(
                    widget.workout!.sets.toString() + ' Sets',
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

  changeReps(BuildContext context) {
    Widget okButton = TextButton(
      child: Text(
        "Save",
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        widget.changeWorkoutCallback!(widget.workout!.workoutId, widget.workout);

        Navigator.pop(context);
      },
    );
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Change Reps"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              width: 50,
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: TextFormField(
                onChanged: (String value) {
                  widget.workout!.reps = value;
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(4),
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                keyboardType: TextInputType.number,
                controller: _repsController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0.0),
                  isDense: true,
                ),
              ),
            ),
          ),
          Text(' Reps'),
        ],
      ),
      actions: [
        cancelButton,
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

  changeKg(BuildContext context) {
    Widget okButton = TextButton(
      child: Text(
        "Save",
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget cancelButton = TextButton(
      child: Text(
        "Cancel",
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Change Kg"),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              width: 50,
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: TextField(
                controller: _kgController,
                onChanged: (String value) {
                  // TODO : workout kg set here
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0.0),
                  isDense: true,
                ),
              ),
            ),
          ),
          Text(' Kg'),
        ],
      ),
      actions: [
        cancelButton,
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

  void _showCustomMenu(context) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    Size _size = Size(40, 40);
    void tappedCallback(context) {
      Navigator.pop(context);
    }

    showMenu(
            context: context,
            items: <PopupMenuEntry<int>>[
              PopupMenu(
                  removeWorkoutCallback: widget.removeWorkoutCallback,
                  workout: widget.workout,
                  tappedCallback: tappedCallback)
            ],
            position: RelativeRect.fromRect(
                _tapPosition & _size, Offset.zero & overlay.size))
        .then<void>((int? delta) {
      if (delta == null) return;
      setState(() {
        _count = _count + delta;
      });
    });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    return widget.workout!.exercise!.isCardio!
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: theme.currentTheme() == ThemeMode.dark
                      ? Colors.grey[700]
                      : Colors.white,
                                boxShadow: [
                      BoxShadow(
                          blurRadius: 3,
                          spreadRadius: 1,
                          offset: Offset(1, 2),
                          color: Color(0xffd6d6d6))
                    ],),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/running', arguments: {
                    'runningWorkout': widget.workout!.runningWorkout,
                    'programDay': widget.programDay
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5, left: 5),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.05,
                        width: MediaQuery.of(context).size.width * 0.12,
                        child: Container(
                          width: 20,
                          child: Image.asset(
                            widget.workout!.exercise!.exerciseIcon!,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.workout!.exercise!.exerciseName!),
                        ],
                      ),
                    )),
                    GestureDetector(
                      onTap: () => _showCustomMenu(context),
                      onTapDown: _storePosition,
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.more_vert),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.currentTheme() == ThemeMode.dark
                      ? Colors.grey[700]
                      : Colors.white,
                                    boxShadow: [
                      BoxShadow(
                          blurRadius: 3,
                          spreadRadius: 1,
                          offset: Offset(1, 2),
                          color: Color(0xffd6d6d6))
                    ],),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/exercise_detail',
                      arguments: {'exercise': widget.workout!.exercise});
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 5, left: 10,top: 5,bottom: 5),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.13,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                                (widget.workout!.exercise!.muscleGroup.isNotEmpty
                                    ? NetworkImage(widget.workout!.exercise!
                                        .muscleGroup.first.muscleImg!)
                                    : AssetImage(
                                        'assets/images/workout/muscle.png')) as ImageProvider<Object>,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.workout!.exercise != null)
                              Padding(
                                padding: const EdgeInsets.only(left:15.0),
                                child: Text(widget.workout!.exercise!.exerciseName!),
                              ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: () => changeSets(context),
                                    child: Text(
                                      widget.workout!.sets.toString() + ' Sets',
                                      style: TextStyle(
                                        color: Color.fromRGBO(86, 177, 191, 1),
                                      ),
                                    ),
                                  ),
                                  Text('X'),
                                  GestureDetector(
                                    onTap: () => changeReps(context),
                                    child: Text(
                                      widget.workout!.reps.toString(),
                                      style: TextStyle(
                                        color: Color.fromRGBO(86, 177, 191, 1),
                                      ),
                                    ),
                                  ),
                                  if (widget.showKg!) Text('X'),
                                  if (widget.showKg!)
                                    GestureDetector(
                                      onTap: () => changeKg(context),
                                      child: Text(
                                        '15 kg',
                                        style: TextStyle(
                                          color:
                                              Color.fromRGBO(86, 177, 191, 1),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showCustomMenu(context),
                      onTapDown: _storePosition,
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Icon(Icons.more_vert),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}

// ignore: must_be_immutable
class PopupMenu extends PopupMenuEntry<int> {
  Workout? workout;
  Function? removeWorkoutCallback;
  Function? tappedCallback;
  bool isVisible = true;
  PopupMenu({this.removeWorkoutCallback, this.workout, this.tappedCallback});
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
    return Column(
      children: [
        Visibility(
          visible: widget.isVisible,
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  // bulk edit //print('Remove exercise Tapped');
                  setState(() {
                    message = "You've Succesfully Delete the Exercise!";
                  });
                  widget.removeWorkoutCallback!(widget.workout!.workoutId, false);
                  setState(() {
                    widget.isVisible = false;
                  });
                  widget.tappedCallback!(context);
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
                  widget.tappedCallback!(context);

                  widget.removeWorkoutCallback!(widget.workout!.workoutId, true);
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
                  Navigator.pushNamedAndRemoveUntil(context, '/exercise_stats',
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
    );
  }
}
