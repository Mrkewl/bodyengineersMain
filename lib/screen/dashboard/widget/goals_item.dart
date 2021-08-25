import 'dart:async';

import 'package:bodyengineer/be_theme.dart';
import 'package:bodyengineer/helper/tools_helper.dart';
import 'package:bodyengineer/model/goal/body_goal.dart';
import 'package:bodyengineer/model/goal/exercise_goal.dart';
import 'package:bodyengineer/model/goal/goal_model.dart';
import 'package:bodyengineer/model/planner/exercise_history.dart';
import 'package:bodyengineer/model/planner/measurement.dart';
import 'package:bodyengineer/model/planner/planner_model.dart';
import 'package:bodyengineer/model/program/exercise.dart';
import 'package:bodyengineer/model/user/user.dart';
import 'package:bodyengineer/model/user/user_model.dart';
import 'package:bodyengineer/screen/dashboard/goals/widgets/goal_progress_bar.dart';
import 'package:bodyengineer/translations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalsItem extends StatefulWidget {
  BodyGoal bodyGoal;
  double value;
  bool hideDots;
  GoalsItem(this.bodyGoal, this.value, this.hideDots);
  @override
  _GoalsItemState createState() => _GoalsItemState();
}

class _GoalsItemState extends State<GoalsItem> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  TextEditingController textWeightController = TextEditingController();
  TextEditingController textFatController = TextEditingController();
  TextEditingController textExerciseKgController = TextEditingController();
  TextEditingController textExerciseRepsController = TextEditingController();
  List<BodyGoal>? bodyGoalList;
  late List<BodyGoal> unCompletedbodyGoalList;
  late List<BodyGoal> completedbodyGoalList;
  List<ExerciseHistoryElement> exerciseHistoryList = [];

  List<ExerciseGoal>? exerciseGoalList;
  late List<ExerciseGoal> unCompletedexerciseGoalList;
  late List<ExerciseGoal> completedexerciseGoalList;

  SharedPreferences? prefs;
  String measurementUnit = '';
  Exercise? selectedExercise;
  StreamController<Exercise?>? _events;
  UserObject? user;
  MyTheme theme = MyTheme();
  double? bodyWeight;
  double? bodyFat;
  List<Measurement> bodyfatMeasurements = [];
  List<Measurement> bodyWeightMeasurements = [];
  List<ExerciseHistoryElement> exerciseHistory = [];
  bool isCheckGoal = false;
  bool isCheckExerciseGoal = false;
  late var _tapPosition;
  var _count = 0;
  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
    });
    super.initState();
  }

  Future<void> checkExerciseGoals() async {
    isCheckExerciseGoal = true;
    await Provider.of<GoalModel>(context, listen: false)
        .checkExerciseGoals(exerciseHistory);
  }

  Future<void> checkGoals(UserObject? user) async {
    await setMeasurement();
    if (bodyfatMeasurements.isNotEmpty) {
      setState(() {
        bodyFat = bodyfatMeasurements.last.value ?? user!.bodyFatPercentage;
      });
    } else {
      setState(() {
        bodyFat = user!.bodyFatPercentage;
      });
    }
    if (bodyWeightMeasurements.isNotEmpty) {
      setState(() {
        bodyWeight = bodyWeightMeasurements.last.value != null
            ? bodyWeightMeasurements.last.value!.toDouble()
            : user!.bodyWeightInKilo;
      });
    } else {
      setState(() {
        bodyWeight = user!.bodyWeightInKilo;
      });
    }
    isCheckGoal = true;

    await Provider.of<GoalModel>(context, listen: false)
        .checkBodyGoals(bodyFat: bodyFat, bodyWeight: bodyWeight, user: user);
  }

  Future<void> setMeasurement() async {
    if (Provider.of<PlannerModel>(context, listen: true)
        .bodystatsDayList
        .isNotEmpty)
      bodyfatMeasurements = Tools.filterMeasurementFromBodystatDay(
          measurementName: 'Body Fat',
          bodystatsDayList: Provider.of<PlannerModel>(context, listen: true)
              .bodystatsDayList);
    if (Provider.of<PlannerModel>(context, listen: true)
        .bodystatsDayList
        .isNotEmpty)
      bodyWeightMeasurements = Tools.filterMeasurementFromBodystatDay(
          measurementName: 'Body Weight',
          bodystatsDayList: Provider.of<PlannerModel>(context, listen: true)
              .bodystatsDayList);
  }

  setBodyGoal(String name, String goal) {
    if (name == 'Body Fat' && bodyFat != null ||
        name == 'Body Weight' && bodyWeight != null)
      Provider.of<GoalModel>(context, listen: false).setBodyGoal(
          name: name,
          goal: double.parse(goal),
          initial: name == 'Body Weight' ? bodyWeight : bodyFat!.toDouble(),
          bodyWeight: bodyWeight,
          bodyFat: bodyFat);
  }

  setExerciseGoal(String? exerciseName, String kg, String rep) {
    Provider.of<GoalModel>(context, listen: false)
        .setExerciseGoal(exerciseName, int.parse(kg), int.parse(rep));
  }

  @override
  void dispose() {
    textWeightController.dispose();
    textFatController.dispose();
    textExerciseKgController.dispose();
    textExerciseRepsController.dispose();
    if (_events != null) _events!.close();
    super.dispose();
  }

  exerciseSelectCallback(Exercise exercise) {
    // bulk edit //print(exercise);
    setState(() {
      selectedExercise = exercise;
      _events!.add(selectedExercise);
    });
  }

  Widget myPopMenu() {
    return PopupMenuButton(
        child: Container(
          margin: EdgeInsets.only(right: 10),
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromRGBO(8, 112, 138, 1),
          ),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        onSelected: (dynamic value) {
          if (value == 1) {
            return addBodyWeight(context);
          } else if (value == 2) {
            return addBodyfat(context);
          } else {
            // _events = StreamController<Exercise?>();
            // Exercise test = Exercise();
            // _events!.add(test);
            // return addExercise(context);
          }
        },
        itemBuilder: (context) => [
              if (bodyWeight != null)
                PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromRGBO(8, 112, 138, 1),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(allTranslations.text('add_bodyweight_goal')!)
                      ],
                    )),
              if (bodyFat != null)
                PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromRGBO(8, 112, 138, 1),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(allTranslations.text('add_bodyfat_goal')!)
                      ],
                    )),
              PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 2, 8, 2),
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(8, 112, 138, 1),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(allTranslations.text('add_exercise_goal')!)
                    ],
                  )),
            ]);
  }

  addBodyWeight(BuildContext context) {
    String measurement = Provider.of<UserModel>(context, listen: false)
                .user!
                .unitOfMeasurementId ==
            1
        ? 'kg'
        : 'lbs';
    Widget okButton = FlatButton(
      child: Text(
        allTranslations.text('save')!,
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        // bulk edit //print('bodyweight pressed');
        setBodyGoal('Body Weight', textWeightController.text);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(allTranslations.text('bodyweight_goal')!),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(allTranslations.text('goal_weight')!),
          Container(
            width: 50,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: TextField(
              controller: textWeightController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0.0),
                isDense: true,
              ),
            ),
          ),
          Text(measurement),
        ],
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

  editBodyWeight(BuildContext context, BodyGoal bodyGoal) {
    String measurement = Provider.of<UserModel>(context, listen: false)
                .user!
                .unitOfMeasurementId ==
            1
        ? 'kg'
        : 'lbs';

    setState(() {
      textWeightController.text = bodyGoal.goal.toString();
    });
    Widget okButton = FlatButton(
      child: Text(
        allTranslations.text('save')!,
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        // bulk edit //print('bodyweight pressed');
        setBodyGoal('Body Weight', textWeightController.text);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(allTranslations.text('bodyweight_goal')!),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(allTranslations.text('goal_weight')!),
          Container(
            width: 50,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: TextField(
              controller: textWeightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0.0),
                isDense: true,
              ),
            ),
          ),
          Text(measurement),
        ],
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

  addBodyfat(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text(
        allTranslations.text('save')!,
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        // bulk edit //print('bodyfat pressed');
        setBodyGoal('Body Fat', textFatController.text);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(allTranslations.text('bodyfat_goal')!),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(allTranslations.text('goal_bodyfat')!),
          Container(
            width: 50,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: TextField(
              maxLength: 2,
              controller: textFatController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0.0),
                isDense: true,
                counterText: "",
              ),
            ),
          ),
          Text('%'),
        ],
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

  editBodyfat(BuildContext context, BodyGoal bodyGoal) {
    setState(() {
      textFatController.text = bodyGoal.goal.toString();
    });
    Widget okButton = FlatButton(
      child: Text(
        allTranslations.text('save')!,
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        // bulk edit //print('bodyfat pressed');
        setBodyGoal('Body Fat', textFatController.text);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(allTranslations.text('bodyfat_goal')!),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(allTranslations.text('goal_bodyfat')!),
          Container(
            width: 50,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: TextField(
              maxLength: 2,
              controller: textFatController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0.0),
                isDense: true,
                counterText: "",
              ),
            ),
          ),
          Text('%'),
        ],
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

  _getContent() {
    String measurement = Provider.of<UserModel>(context, listen: false)
                .user!
                .unitOfMeasurementId ==
            1
        ? 'kg'
        : 'lbs';

    return StreamBuilder<Exercise?>(
        stream: _events!.stream,
        builder: (BuildContext context, AsyncSnapshot<Exercise?> snapshot) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              snapshot.data != null
                  ? Text(snapshot.data!.exerciseName ??
                      allTranslations.text('select_exercise')!)
                  : Text(allTranslations.text('select_exercise')!),
              SizedBox(width: 20),
              Container(
                width: 50,
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: TextField(
                  controller: textExerciseKgController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(0.0),
                    isDense: true,
                  ),
                ),
              ),
              Text(measurement),
              Text(' X '),
              Container(
                width: 50,
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: TextField(
                  controller: textExerciseRepsController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(0.0),
                    isDense: true,
                  ),
                ),
              ),
              Text('Reps'),
            ],
          );
        });
  }

  removeCallback(dynamic deleteObject) {
    // bulk edit //print('Callback remove');
    if (deleteObject is BodyGoal) {
      // bulk edit //print('Delete Body Goal');
      Provider.of<GoalModel>(context, listen: false)
          .removeBodyGoal(bodyGoal: deleteObject);
      // bulk edit //print(deleteObject);
    } else if (deleteObject is ExerciseGoal) {
      // bulk edit //print('Delete Exercise Goal');
      // bulk edit //print(deleteObject);
      Provider.of<GoalModel>(context, listen: false)
          .removeExerciseGoal(exerciseGoal: deleteObject);
    }
  }

  editCallback(dynamic editObject) {
    // bulk edit //print('Callback edit');
    if (editObject is BodyGoal) {
      // bulk edit //print('Edit Body Goal');
      // bulk edit //print(editObject);
      switch (editObject.name) {
        case 'Body Weight':
          editBodyWeight(context, editObject);
          break;
        case 'Body Fat':
          editBodyfat(context, editObject);
          break;
      }
    } else if (editObject is ExerciseGoal) {
      // bulk edit //print('Edit Exercise Goal');
      // bulk edit //print(editObject);
    }
  }

  void _showThreeDotsMenu(
      {BodyGoal? bodyGoal,
      ExerciseGoal? exerciseGoal,
      bool showOnlyRemove = false}) {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    showMenu(
            context: context,
            items: <PopupMenuEntry<int>>[
              ThreeDotsMenu(
                bodyGoal: bodyGoal,
                exerciseGoal: exerciseGoal,
                editCallback: editCallback,
                showOnlyRemove: showOnlyRemove,
                removeCallback: removeCallback,
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

  @override
  Widget build(BuildContext context) {
    measurementUnit = Provider.of<UserModel>(context, listen: false)
                .user!
                .unitOfMeasurementId ==
            1
        ? 'kg'
        : 'lbs';
    return Container(
      margin: widget.hideDots
          ? EdgeInsets.symmetric(vertical: 0)
          : EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(7),
      decoration: widget.hideDots
          ? BoxDecoration()
          : BoxDecoration(
              color: theme.currentTheme() == ThemeMode.dark
                  ? Colors.grey[700]
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  spreadRadius: 3,
                )
              ],
            ),
      child: widget.hideDots
          ? Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Text(widget.value.toString()),
                              Text('/'),
                              Text(widget.bodyGoal.name ==
                                      allTranslations.text('bodyfat')
                                  ? widget.bodyGoal.goal.toString() + '%'
                                  : widget.bodyGoal.goal.toString() +
                                      ' ' +
                                      measurementUnit),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.bodyGoal.name!,
                          style: TextStyle(fontSize: 15),
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: widget.hideDots
                                ? MediaQuery.of(context).size.width * 0.5
                                : MediaQuery.of(context).size.width * 0.75,
                            child: GoalProgressBarWidget(
                                data1: widget.bodyGoal.name ==
                                        allTranslations.text('bodyfat')
                                    ? (widget.bodyGoal.initial! -
                                                    widget.value.toDouble())
                                                .abs() ==
                                            0
                                        ? 1
                                        : (widget.bodyGoal.initial! -
                                                widget.value.toDouble())
                                            .abs()
                                    : (widget.bodyGoal.initial! -
                                                    widget.value.toDouble())
                                                .abs() ==
                                            0
                                        ? 1
                                        : (widget.bodyGoal.initial! -
                                                widget.value.toDouble())
                                            .abs(),
                                data2: widget.bodyGoal.name ==
                                        allTranslations.text('bodyfat')
                                    ? (widget.bodyGoal.goal! -
                                            widget.bodyGoal.initial!)
                                        .abs()
                                    : (widget.bodyGoal.goal! -
                                            widget.bodyGoal.initial!)
                                        .abs())),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.bodyGoal.name!,
                          style: TextStyle(fontSize: 15),
                        ),
                        Container(
                          child: Row(
                            children: [
                              Text(widget.value.toString()),
                              Text('/'),
                              Text(widget.bodyGoal.name ==
                                      allTranslations.text('bodyfat')
                                  ? widget.bodyGoal.goal.toString() + '%'
                                  : widget.bodyGoal.goal.toString() +
                                      ' ' +
                                      measurementUnit),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: GestureDetector(
                                  onTap: () => _showThreeDotsMenu(
                                      bodyGoal: widget.bodyGoal,
                                      showOnlyRemove: true),
                                  onTapDown: _storePosition,
                                  child: Icon(Icons.more_vert),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Container(
                        width: widget.hideDots
                            ? MediaQuery.of(context).size.width * 0.5
                            : MediaQuery.of(context).size.width * 0.75,
                        child: GoalProgressBarWidget(
                            data1: widget.bodyGoal.name ==
                                    allTranslations.text('bodyfat')
                                ? (widget.bodyGoal.initial! -
                                                widget.value.toDouble())
                                            .abs() ==
                                        0
                                    ? 1
                                    : (widget.bodyGoal.initial! -
                                            widget.value.toDouble())
                                        .abs()
                                : (widget.bodyGoal.initial! -
                                                widget.value.toDouble())
                                            .abs() ==
                                        0
                                    ? 1
                                    : (widget.bodyGoal.initial! -
                                            widget.value.toDouble())
                                        .abs(),
                            data2: widget.bodyGoal.name ==
                                    allTranslations.text('bodyfat')
                                ? (widget.bodyGoal.goal! -
                                        widget.bodyGoal.initial!)
                                    .abs()
                                : (widget.bodyGoal.goal! -
                                        widget.bodyGoal.initial!)
                                    .abs())),
                  ],
                ),
              ),
            ),
    );
  }
}

class ThreeDotsMenu extends PopupMenuEntry<int> {
  @override
  double height = 100;
  ExerciseGoal? exerciseGoal;
  BodyGoal? bodyGoal;
  Function? removeCallback;
  Function? editCallback;
  bool? showOnlyRemove;
  ThreeDotsMenu(
      {this.bodyGoal,
      this.exerciseGoal,
      this.removeCallback,
      this.editCallback,
      this.showOnlyRemove});
  @override
  bool represents(int? n) => n == 1 || n == -1;

  @override
  PopupMenuState createState() => PopupMenuState();
}

class PopupMenuState extends State<ThreeDotsMenu> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (!widget.showOnlyRemove!)
          GestureDetector(
            onTap: () {
              // bulk edit //print('Edit Tapped');
              // bulk edit //print(widget.exerciseGoal);
              // bulk edit //print(widget.bodyGoal);
              Navigator.pop(context);

              widget.editCallback!(widget.bodyGoal ?? widget.exerciseGoal);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(allTranslations.text('edit')!),
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
            // bulk edit //print('Remove Tapped');
            // bulk edit //print(widget.exerciseGoal);
            // bulk edit //print(widget.bodyGoal);
            Navigator.pop(context);

            widget.removeCallback!(widget.bodyGoal ?? widget.exerciseGoal);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(allTranslations.text('remove')!),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                ),
                Icon(Icons.add),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
