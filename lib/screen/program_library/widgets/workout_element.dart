import '../../../model/planner/exercise_history.dart';
import '../../../model/planner/planner_model.dart';
import '../../../model/program/exercise.dart';
import '../../../model/program/workout.dart';
import '../../../model/program/workoutSet.dart';
import '../../../model/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

import '../../../be_theme.dart';
import '../../../model/planner/exercise_history.dart';
import '../../../model/program/programDay.dart';
import '../../../translations.dart';

// ignore: must_be_immutable
class WorkoutElement extends StatefulWidget {
  Function? changeWorkoutCallback;
  Function? removeWorkoutCallback;
  Workout? workout;
  bool? isEdit;
  ProgramDay? programDay;
  bool? bodyweight;

  WorkoutElement({
    this.workout,
    this.changeWorkoutCallback,
    this.removeWorkoutCallback,
    this.isEdit,
    this.programDay,
  });
  @override
  _WorkoutElementState createState() => _WorkoutElementState();
}

class _WorkoutElementState extends State<WorkoutElement> {
  late var _tapPosition;
  var _count = 0;
  MyTheme theme = MyTheme();

  @override
  void initState() {
    super.initState();
  }

  void _showCustomMenu(context) {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;
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
                tappedCallback: tappedCallback,
              )
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

  var sets = [
    SetLine(
      setNo: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    String measurement = Provider.of<UserModel>(context, listen: false)
                .user!
                .unitOfMeasurementId ==
            1
        ? 'kg'
        : 'lbs';
    return widget.workout!.sets == 0 && widget.workout!.reps == 0
        ? Container()
        : widget.workout!.exercise!.isCardio!
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
                    ],
                  ),
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
                      ]),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: GestureDetector(
                              onTap: () {
                                if (!widget.workout!.exercise!.isCardio!) {
                                  Navigator.pushNamed(
                                      context, '/exercise_detail', arguments: {
                                    'exercise': widget.workout!.exercise
                                  });
                                } else {
                                  Navigator.pushNamed(context, '/running',
                                      arguments: {
                                        'runningWorkout':
                                            widget.workout!.runningWorkout,
                                        'programDay': widget.programDay
                                      });
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                margin:
                                    EdgeInsets.only(left: 10, top: 5, right: 5),
                                height:
                                    MediaQuery.of(context).size.height * 0.07,
                                width: MediaQuery.of(context).size.width * 0.14,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: widget.workout!.exercise!.isCardio!
                                          ? AssetImage(
                                              widget.workout!.exercise!
                                                  .exerciseIcon!,
                                            )
                                          : (widget.workout!.exercise!
                                                  .muscleGroup.isNotEmpty
                                              ? NetworkImage(
                                                  widget
                                                      .workout!
                                                      .exercise!
                                                      .muscleGroup
                                                      .first
                                                      .muscleImg!,
                                                )
                                              : AssetImage(
                                                  'assets/images/workout/muscle.png',
                                                )) as ImageProvider<Object>),
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
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.005,
                                  ),
                                  ////TODO change
                                  widget.workout!.exercise!.equipmentGroup.any(
                                          (equipment) =>
                                              equipment.equipmentName ==
                                              'Bodyweight')
                                      ?
                                      ////TODO remember that there is 3 states of workout log, starting workout, static end view workout, edit workout
                                      Text(
                                          ////TODO here i removed the weight and just made reps instead
                                          // widget.workout!.sets.toString() +
                                          //     ' sets' +
                                          //     ' x ' +
                                          widget.workout!.reps.toString() +
                                              ' reps',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                          ),
                                        )
                                      : Text(
                                          widget.workout!.sets.toString() +
                                              ' sets' +
                                              ' x ' +
                                              widget.workout!.reps.toString() +
                                              ' reps',
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
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
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: widget.workout!.userWorkoutSet.length,
                            itemBuilder: (BuildContext context, int index) {
                              return SetLine(
                                workout: widget.workout,
                                setNo: index + 1,
                                setObject:
                                    widget.workout!.userWorkoutSet[index],
                                measurementUnit: measurement,
                                exercise: widget.workout!.exercise,
                                isEdit: widget.isEdit,
                              );
                            }),
                      ),
                      Visibility(
                        visible: !widget.isEdit!,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.workout!.userWorkoutSet.add(
                                  WorkoutSet.fromLocalJson(
                                      {'rep': 0, 'kg': 0.0}));
                            });
                          },
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: 10,
                                left:
                                    MediaQuery.of(context).size.width * 0.025),
                            child: Row(
                              children: [
                                Icon(Icons.add),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.05),
                                Text(
                                  allTranslations.text('add_new_set')!,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
  }
}

// ignore: must_be_immutable
class SetLine extends StatelessWidget {
  Workout? workout;
  int? setNo;
  Exercise? exercise;
  WorkoutSet? setObject;
  Function? callBack;
  String? measurementUnit = '';
  bool? isEdit;
  SetLine({
    this.workout,
    this.setNo,
    this.setObject,
    this.callBack,
    this.measurementUnit,
    this.exercise,
    this.isEdit,
  });
  List<ExerciseHistoryElement> exerciseHistory = [];
  Map<int?, List<ExerciseHistoryElement>>? groupedExerciseHistory;
  List<ExerciseHistoryElement> lastHistoryList = [];
  late ProgramDay programDay;
  late int index;
  @override
  Widget build(BuildContext context) {
    programDay = Provider.of<PlannerModel>(context, listen: false)
        .programDayList
        .firstWhere((element) => element.workoutList.contains(workout));
    index = setNo! - 1;
    exerciseHistory = Provider.of<PlannerModel>(context, listen: true)
        .exerciseHistory
        .where(
            (element) => element.exerciseId.toString() == exercise!.exerciseId)
        .toList()
          ..sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
    if (exerciseHistory.isNotEmpty &&
        exerciseHistory
            .where(
                (element) => element.dateTime!.isBefore(programDay.dateTime!))
            .isNotEmpty) {
      groupedExerciseHistory = groupBy(
          exerciseHistory, (ExerciseHistoryElement hist) => hist.workoutId);
      print(groupedExerciseHistory);
      ExerciseHistoryElement exHistoryElement = exerciseHistory
          .where((element) => element.dateTime!.isBefore(programDay.dateTime!))
          .toList()
          .reduce((a, b) => a.dateTime!.difference(programDay.dateTime!).abs() <
                  b.dateTime!.difference(programDay.dateTime!).abs()
              ? a
              : b); // Find closest exercise history
      print(exHistoryElement);
      lastHistoryList = groupedExerciseHistory!.values
          .firstWhere((element) => element.contains(exHistoryElement));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Set ' + setNo.toString()),
          Container(
            child: Row(
              children: [
                SizedBox(width: 7),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.height * 0.04,
                  child: TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(4),
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    ],
                    readOnly: isEdit!,
                    keyboardType: TextInputType.number,
                    initialValue: setObject!.rep.toString(),
                    onChanged: (value) {
                      if (value != '' && value != null) {
                        setObject!.rep = int.parse(value);
                      } else {
                        setObject!.rep = 0;
                      }
                    },
                    textAlign: TextAlign.center,
                    decoration: isEdit!
                        ? InputDecoration(border: InputBorder.none)
                        : InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(8, 112, 138, 1),
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                          ),
                  ),
                ),
                //TODO bodyweight stuff Double check code
                workout!.exercise!.equipmentGroup.any(
                        (equipment) => equipment.equipmentName == 'Bodyweight')
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Reps',
                          style: TextStyle(color: Colors.black),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'X',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                //TODO Double check code
                workout!.exercise!.equipmentGroup.any(
                        (equipment) => equipment.equipmentName == 'Bodyweight')
                    ? Container()
                    : SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                        height: MediaQuery.of(context).size.height * 0.04,
                        child: TextFormField(
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(5),
                            FilteringTextInputFormatter.allow(
                                RegExp(r'(^\d*\.?\d{0,1})')),
                          ],
                          keyboardType: TextInputType.number,
                          readOnly: isEdit!,
                          onChanged: (value) {
                            if (value != '' && value != null) {
                              setObject!.kg = double.tryParse(value) ?? 0;
                            } else {
                              setObject!.kg = 0;
                            }
                          },
                          textAlign: TextAlign.center,
                          initialValue: setObject!.kg.toString(),
                          decoration: isEdit!
                              ? InputDecoration(border: InputBorder.none)
                              : InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(8, 112, 138, 1),
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black54,
                                      width: 1,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                SizedBox(width: 7),
                workout!.exercise!.equipmentGroup.any(
                        (equipment) => equipment.equipmentName == 'Bodyweight')
                    ? Container()
                    : Text(
                        measurementUnit ?? '',
                      ),
                SizedBox(width: 7),
              ],
            ),
          ),
          Spacer(),
          if (lastHistoryList.isNotEmpty &&
              lastHistoryList.length >= setNo! &&
              workout!.exercise!.equipmentGroup
                  .any((equipment) => equipment.equipmentName != 'Bodyweight'))
            Text(
              lastHistoryList[index].rep.toString() +
                  'x' +
                  lastHistoryList[index].weight.toString() +
                  ' ' +
                  measurementUnit!,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 11,
              ),
            ),
          if (lastHistoryList.isEmpty || lastHistoryList.length < setNo!)
            Container(
              width: 35,
              height: 30,
            ),
          if (lastHistoryList.isNotEmpty &&
              lastHistoryList.length >= setNo! &&
              workout!.exercise!.equipmentGroup
                  .any((equipment) => equipment.equipmentName == 'Bodyweight'))
            Text(
              lastHistoryList[index].rep.toString() + ' Reps',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 11,
              ),
            ),
        ],
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
                  setState(() {
                    message = "You've Succesfully Delete the Exercise!";
                  });
                  // bulk edit //print('Remove exercise Tapped');
                  widget.removeWorkoutCallback!(
                      widget.workout!.workoutId, false);
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

                  widget.removeWorkoutCallback!(
                      widget.workout!.workoutId, true);
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
        Visibility(visible: !widget.isVisible, child: Text(message))
      ],
    );
  }
}
