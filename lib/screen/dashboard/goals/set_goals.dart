import 'dart:async';

import 'package:bodyengineer/screen/dashboard/widget/goals_item.dart';

import '../../../helper/tools_helper.dart';
import '../../../model/goal/body_goal.dart';
import '../../../model/goal/exercise_goal.dart';
import '../../../model/goal/goal_model.dart';
import '../../../model/planner/exercise_history.dart';
import '../../../model/planner/measurement.dart';
import '../../../model/planner/planner_model.dart';
import '../../../model/program/exercise.dart';
import '../../../model/user/user.dart';
import '../../../model/user/user_model.dart';
import '../../../screen/dashboard/goals/widgets/goal_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../be_theme.dart';
import '../../../translations.dart';
import '../../common_appbar.dart';
import '../../common_drawer.dart';

class SetGoals extends StatefulWidget {
  @override
  _SetGoalsState createState() => _SetGoalsState();
}

class _SetGoalsState extends State<SetGoals> {
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

  late List<Exercise> exerciseList;
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
          initial:
              name == 'Body Weight' ? bodyWeight : bodyFat!.toDouble(),
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
            _events = StreamController<Exercise?>();
            Exercise test = Exercise();
            _events!.add(test);
            return addExercise(context);
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

  editExercise(BuildContext context, ExerciseGoal exerciseGoal) {
    setState(() {
      selectedExercise = exerciseList
          .where((element) => element.exerciseId == exerciseGoal.exerciseId)
          .first;
      textExerciseKgController.text = exerciseGoal.kg.toString();
      textExerciseRepsController.text = exerciseGoal.rep.toString();
    });

    if (_events == null || _events!.isClosed)
      _events = StreamController<Exercise?>();

    _events!.add(selectedExercise);

    Widget okButton = FlatButton(
      child: Text(
        allTranslations.text('save')!,
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        // bulk edit //print('exercise pressed');
        // bulk edit //print('SET GOAL EXERCİSE');
        Provider.of<GoalModel>(context, listen: false)
            .removeExerciseGoal(exerciseGoal: exerciseGoal);
        setExerciseGoal(selectedExercise!.exerciseId,
            textExerciseKgController.text, textExerciseRepsController.text);
        setState(() {
          selectedExercise = null;
          textExerciseKgController.text = '';
          textExerciseRepsController.text = '';
          if (_events != null) _events!.close();
        });
        Navigator.pop(context);
      },
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String measurement = Provider.of<UserModel>(context, listen: false)
                    .user!
                    .unitOfMeasurementId ==
                1
            ? 'kg'
            : 'lbs';

        return StreamBuilder<Exercise?>(
            stream: _events!.stream,
            builder: (BuildContext context, AsyncSnapshot<Exercise?> snapshot) {
              return AlertDialog(
                title: Text(allTranslations.text('exercise_goal')!),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    snapshot.data != null
                        ? Text(snapshot.data!.exerciseName ??
                            allTranslations.text('please_select_exercise')!)
                        : Text(allTranslations.text('please_select_exercise')!),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: TextField(
                            controller: textExerciseKgController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0.0),
                              isDense: true,
                            ),
                          ),
                        ),
                        Text(measurement),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('X'),
                        ),
                        Container(
                          width: 50,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: TextField(
                            controller: textExerciseRepsController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0.0),
                              isDense: true,
                            ),
                          ),
                        ),
                        Text('Reps'),
                      ],
                    ),
                  ],
                ),
                actions: [
                  if (snapshot.data != null &&
                      snapshot.data!.exerciseName != null)
                    okButton,
                ],
              );
            });
      },
    );
  }

  addExercise(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text(
        allTranslations.text('save')!,
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        // bulk edit //print('exercise pressed');
        // bulk edit //print('SET GOAL EXERCİSE');
        setExerciseGoal(selectedExercise!.exerciseId,
            textExerciseKgController.text, textExerciseRepsController.text);
        setState(() {
          selectedExercise = null;
          textExerciseKgController.text = '';
          textExerciseRepsController.text = '';
          _events!.close();
        });
        Navigator.pop(context);
      },
    );

    Widget searchButton = GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/goal_exercise_list',
          arguments: {'callback': exerciseSelectCallback}),
      child: Container(
        child: Icon(
          Icons.search,
          color: Colors.grey,
        ),
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String measurement = Provider.of<UserModel>(context, listen: false)
                    .user!
                    .unitOfMeasurementId ==
                1
            ? 'kg'
            : 'lbs';

        return StreamBuilder<Exercise?>(
            stream: _events!.stream,
            builder: (BuildContext context, AsyncSnapshot<Exercise?> snapshot) {
              return AlertDialog(
                title: Text(allTranslations.text('exercise_goal')!),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    snapshot.data != null
                        ? Text(snapshot.data!.exerciseName ??
                            allTranslations.text('please_select_exercise')!)
                        : Text(allTranslations.text('please_select_exercise')!),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: TextField(
                            controller: textExerciseKgController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0.0),
                              isDense: true,
                            ),
                          ),
                        ),
                        Text(measurement),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('X'),
                        ),
                        Container(
                          width: 50,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: TextField(
                            controller: textExerciseRepsController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(0.0),
                              isDense: true,
                            ),
                          ),
                        ),
                        Text('Reps'),
                      ],
                    ),
                  ],
                ),
                actions: [
                  searchButton,
                  if (snapshot.data != null &&
                      snapshot.data!.exerciseName != null)
                    okButton,
                ],
              );
            });
      },
    );
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
      editExercise(context, editObject);
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
    user = Provider.of<UserModel>(context, listen: true).user;
    String measurement = Provider.of<UserModel>(context, listen: true)
                .user!
                .unitOfMeasurementId ==
            1
        ? 'kg'
        : 'lbs';

    unCompletedbodyGoalList = Provider.of<GoalModel>(context, listen: true)
        .bodyGoalList
        .where((element) => !element.isCompleted!)
        .toList();
    completedbodyGoalList = Provider.of<GoalModel>(context, listen: true)
        .bodyGoalList
        .where((element) => element.isCompleted!)
        .toList();
    unCompletedexerciseGoalList = Provider.of<GoalModel>(context, listen: true)
        .exerciseGoalList
        .where((element) => !element.isCompleted!)
        .toList();
    completedexerciseGoalList = Provider.of<GoalModel>(context, listen: true)
        .exerciseGoalList
        .where((element) => element.isCompleted!)
        .toList();
    exerciseList =
        Provider.of<PlannerModel>(context, listen: true).allExerciseList;
    exerciseHistory = Provider.of<PlannerModel>(context).exerciseHistory;
    exerciseHistoryList =
        Provider.of<PlannerModel>(context, listen: true).exerciseHistory;
    if (!isCheckGoal && user != null) checkGoals(user);
    if (!isCheckExerciseGoal && exerciseHistory.isNotEmpty)
      checkExerciseGoals();
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.all(15),
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: Offset(1, 2),
                  color: Color(0xffd6d6d6),
                )
              ],
              color: theme.currentTheme() == ThemeMode.dark
                  ? Colors.grey[700]
                  : Colors.white,
              borderRadius: BorderRadius.circular(5)),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      allTranslations.text('goals')!,
                      style: TextStyle(fontSize: 16),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        allTranslations.text('back')!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      myPopMenu(),
                      Text(allTranslations.text('add_goals')!),
                    ],
                  ),
                ),
                Text(
                  allTranslations.text('current_goals')!,
                  style: TextStyle(fontSize: 16),
                ),
                MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  removeTop: true,
                  child: ListView.builder(
                      itemCount: unCompletedbodyGoalList.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (unCompletedbodyGoalList[index].name == 'Body Fat' &&
                                bodyFat != null ||
                            unCompletedbodyGoalList[index].name ==
                                    'Body Weight' &&
                                bodyWeight != null) {
                          double val =
                              unCompletedbodyGoalList[index].name == 'Body Fat'
                                  ? bodyFat!.toDouble()
                                  : bodyWeight!.toDouble();
                          return GoalsItem(
                              unCompletedbodyGoalList[index], val, false);
                        }
                        return Container();
                      }),
                ),
                ListView.builder(
                  itemCount: unCompletedexerciseGoalList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    Exercise exercise = exerciseList
                        .where((element) =>
                            element.exerciseId ==
                            unCompletedexerciseGoalList[index].exerciseId)
                        .first;
                    List<ExerciseHistoryElement> exerciseHistoryListFiltered =
                        exerciseHistoryList
                            .where((element) =>
                                element.exerciseId.toString() ==
                                unCompletedexerciseGoalList[index].exerciseId)
                            .toList();

                    ExerciseHistoryElement? exerciseHistoryElement =
                        exerciseHistoryListFiltered.isNotEmpty
                            ? exerciseHistoryListFiltered.reduce((a, b) =>
                                a.weight! > b.weight! || a.rep! > b.rep!
                                    ? a
                                    : b)
                            : null;
                    return
                        // unCompletedexerciseGoalList[index].exerciseId == '17'
                        // ? Container(
                        //     margin: EdgeInsets.symmetric(vertical: 10),
                        //     padding: EdgeInsets.all(5),
                        //     decoration: BoxDecoration(
                        //       color: theme.currentTheme() == ThemeMode.dark
                        //           ? Colors.grey[700]
                        //           : Colors.white,
                        //       boxShadow: [
                        //         BoxShadow(
                        //           color: Colors.black12,
                        //           blurRadius: 3,
                        //           spreadRadius: 3,
                        //         )
                        //       ],
                        //     ),
                        //     child: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Row(
                        //           mainAxisAlignment:
                        //               MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             Text('Romanian Deadlift'),
                        //             Text(unCompletedexerciseGoalList[index]
                        //                     .kg
                        //                     .toString() +
                        //                 ' kg' +
                        //                 ' / ' +
                        //                 unCompletedexerciseGoalList[index]
                        //                     .rep
                        //                     .toString() +
                        //                 ' Reps'),
                        //             Padding(
                        //               padding: const EdgeInsets.only(left: 10),
                        //               child: GestureDetector(
                        //                 onTap: () => _showThreeDotsMenu(
                        //                     exerciseGoal:
                        //                         unCompletedexerciseGoalList[
                        //                             index]),
                        //                 onTapDown: _storePosition,
                        //                 child: Icon(Icons.more_vert),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //         Row(
                        //           mainAxisAlignment:
                        //               MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             Text('Highest Progress: '),
                        //             Text(exerciseHistoryList
                        //                     .where((element) =>
                        //                         element.exerciseId.toString() ==
                        //                         unCompletedexerciseGoalList[
                        //                                 index]
                        //                             .exerciseId)
                        //                     .isNotEmpty
                        //                 ? exerciseHistoryElement.weight
                        //                         .toString() +
                        //                     ' kg'
                        //                         '/' +
                        //                     exerciseHistoryElement.rep
                        //                         .toString() +
                        //                     ' Reps'
                        //                 : ''),
                        //             Container(
                        //               width: MediaQuery.of(context).size.width *
                        //                   0.1,
                        //             ),
                        //           ],
                        //         ),
                        //       ],
                        //     ))
                        // : unCompletedexerciseGoalList[index].exerciseId == '19'
                        //     ? Container(
                        //         margin: EdgeInsets.symmetric(vertical: 10),
                        //         padding: EdgeInsets.all(5),
                        //         decoration: BoxDecoration(
                        //           color: theme.currentTheme() == ThemeMode.dark
                        //               ? Colors.grey[700]
                        //               : Colors.white,
                        //           boxShadow: [
                        //             BoxShadow(
                        //               color: Colors.black12,
                        //               blurRadius: 3,
                        //               spreadRadius: 3,
                        //             )
                        //           ],
                        //         ),
                        //         child: Column(
                        //           children: [
                        //             Row(
                        //               mainAxisAlignment:
                        //                   MainAxisAlignment.spaceBetween,
                        //               children: [
                        //                 Text(exercise.exerciseName),
                        //                 Container(
                        //                   child: Row(
                        //                     children: [
                        //                       Text(exerciseHistoryList
                        //                               .where((element) =>
                        //                                   element.exerciseId
                        //                                       .toString() ==
                        //                                   unCompletedexerciseGoalList[
                        //                                           index]
                        //                                       .exerciseId)
                        //                               .isNotEmpty
                        //                           ? exerciseHistoryElement
                        //                               .weight
                        //                               .toString()
                        //                           : '1'),
                        //                       Text(' / ' +
                        //                           unCompletedexerciseGoalList[
                        //                                   index]
                        //                               .kg
                        //                               .toString()),
                        //                       Padding(
                        //                         padding: const EdgeInsets.only(
                        //                             left: 10),
                        //                         child: GestureDetector(
                        //                           onTap: () => _showThreeDotsMenu(
                        //                               exerciseGoal:
                        //                                   unCompletedexerciseGoalList[
                        //                                       index]),
                        //                           onTapDown: _storePosition,
                        //                           child: Icon(Icons.more_vert),
                        //                         ),
                        //                       ),
                        //                     ],
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //             SizedBox(height: 20),
                        //             Padding(
                        //               padding: const EdgeInsets.symmetric(
                        //                   horizontal: 20),
                        //               child: GoalProgressBarWidget(
                        //                   data1: exerciseHistoryList
                        //                           .where((element) =>
                        //                               element.exerciseId
                        //                                   .toString() ==
                        //                               unCompletedexerciseGoalList[
                        //                                       index]
                        //                                   .exerciseId)
                        //                           .isNotEmpty
                        //                       ? exerciseHistoryElement.rep
                        //                       : 1,
                        //                   data2:
                        //                       unCompletedexerciseGoalList[index]
                        //                           .rep),
                        //             ),
                        //           ],
                        //         ),
                        //       )
                        //     :
                        Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
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
                            color: Color(0xffd6d6d6),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                exercise.exerciseName!.length < 25
                                    ? exercise.exerciseName!
                                    : exercise.exerciseName!.substring(0, 25) +
                                        '...',
                              ),
                              Text(unCompletedexerciseGoalList[index]
                                      .kg
                                      .toString() +
                                  ' ' +
                                  measurement +
                                  ' / ' +
                                  unCompletedexerciseGoalList[index]
                                      .rep
                                      .toString() +
                                  ' Reps'),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: GestureDetector(
                                  onTap: () => _showThreeDotsMenu(
                                      exerciseGoal:
                                          unCompletedexerciseGoalList[index]),
                                  onTapDown: _storePosition,
                                  child: Icon(Icons.more_vert),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(allTranslations.text('highest_progress')!),
                              Text(exerciseHistoryList
                                      .where((element) =>
                                          element.exerciseId.toString() ==
                                          unCompletedexerciseGoalList[index]
                                              .exerciseId)
                                      .isNotEmpty
                                  ? exerciseHistoryElement!.weight.toString() +
                                      ' $measurement'
                                          '/' +
                                      exerciseHistoryElement.rep.toString() +
                                      ' Reps'
                                  : '-'),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.1,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  allTranslations.text('completed_goals')!,
                  style: TextStyle(fontSize: 16),
                ),
                ListView.builder(
                  itemCount: completedbodyGoalList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
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
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                completedbodyGoalList[index].name!.length < 25
                                    ? completedbodyGoalList[index].name!
                                    : completedbodyGoalList[index]
                                            .name!
                                            .substring(0, 25) +
                                        '...',
                                style: TextStyle(fontSize: 15),
                              ),
                              Container(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(completedbodyGoalList[index]
                                            .goal
                                            .toString()),
                                        Text('/' +
                                            completedbodyGoalList[index]
                                                .goal
                                                .toString()),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: GestureDetector(
                                            onTap: () => _showThreeDotsMenu(
                                                bodyGoal: completedbodyGoalList[
                                                    index],
                                                showOnlyRemove: true),
                                            onTapDown: _storePosition,
                                            child: Icon(Icons.more_vert),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: GoalProgressBarWidget(
                              data1: completedbodyGoalList[index].goal,
                              data2: completedbodyGoalList[index].goal,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListView.builder(
                  itemCount: completedexerciseGoalList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    Exercise exercise = exerciseList
                        .where((element) =>
                            element.exerciseId ==
                            completedexerciseGoalList[index].exerciseId)
                        .first;
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(exercise.exerciseName!),
                              Text(completedexerciseGoalList[index]
                                      .kg
                                      .toString() +
                                  ' $measurement' +
                                  ' / ' +
                                  completedexerciseGoalList[index]
                                      .rep
                                      .toString() +
                                  ' Reps'),
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: GestureDetector(
                                  onTap: () => _showThreeDotsMenu(
                                      exerciseGoal:
                                          completedexerciseGoalList[index],
                                      showOnlyRemove: true),
                                  onTapDown: _storePosition,
                                  child: Icon(Icons.more_vert),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(allTranslations.text('highest_progress')!),
                              Text(completedexerciseGoalList[index]
                                      .kg
                                      .toString() +
                                  ' $measurement'
                                      '/' +
                                  completedexerciseGoalList[index]
                                      .rep
                                      .toString() +
                                  ' Reps'),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.1,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 5,
                )
              ],
            ),
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
