import '../../model/program/runningWorkout.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:provider/provider.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../model/planner/planner_model.dart';
import '../../model/program/exercise.dart';
import '../../model/program/programDay.dart';
import '../../model/program/workout.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';
import './widgets/exercise_list_item.dart';

class ExerciseList extends StatefulWidget {
  @override
  _ExerciseListState createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  ProgramDay? programDay;
  Function? addWorkoutCallback;
  late List<Exercise> allExerciseList;
  String searchTerm = '';
  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    if (searchTerm != '') {
      allExerciseList = Provider.of<PlannerModel>(context, listen: true)
          .allExerciseList
          .where((element) => element.exerciseName!
              .toLowerCase()
              .contains(searchTerm.toLowerCase()))
          .toList();
    } else {
      allExerciseList =
          Provider.of<PlannerModel>(context, listen: true).allExerciseList;
    }

    Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    programDay = args['programDay'];
    addWorkoutCallback = args['addWorkoutCallback'];
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Stack(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.chevron_left,
                                      size: 30,
                                      color: Colors.black87,
                                    ),
                                    Text(
                                      'Exercise Details',
                                      style: TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                                onTap: () async {
                                  // bulk edit //print(allExerciseList);
                                  // Random random = new Random();
                                  Random rnd = new Random();
                                  // List<Workout> workoutList = [];
                                  int randomInt = rnd.nextInt(23091995 - 1);
                                  allExerciseList
                                      .where((element) => element.isSelected)
                                      .forEach((element) {
                                    RunningWorkout? runningWorkout;
                                    if (element.isCardio!) {
                                      runningWorkout = RunningWorkout();
                                      randomInt = randomInt * 2;
                                      runningWorkout.workoutId =
                                          randomInt.toString();
                                    }
                                    Workout workout = Workout();
                                    int dateInt =
                                        DateTime.now().microsecondsSinceEpoch;
                                    randomInt = dateInt + randomInt * 2;
                                    workout.exercise = element;
                                    workout.exerciseId =
                                        int.parse(element.exerciseId!);

                                    workout.reps = '0';
                                    workout.rpe = '0';
                                    workout.sets = 1;
                                    workout.workoutId = randomInt.toString();
                                    workout.runningWorkout = runningWorkout;
                                    workout.equalizeSets();
                                    programDay!.workoutList.add(workout);
                                  });
                                  addWorkoutCallback!();
                                  allExerciseList
                                      .where((element) => element.isSelected)
                                      .forEach((element) {
                                    element.isSelected = false;
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width * 0.7,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                  )
                                ]),
                            child: TextField(
                              onChanged: (String value) {
                                setState(() {
                                  searchTerm = value;
                                });
                              },
                              decoration: InputDecoration(
                                icon: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Icon(Icons.search),
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, '/custom_exercise'),
                            child: Container(
                              margin: const EdgeInsets.only(right: 15),
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                image: AssetImage(
                                  'assets/images/workout/dumbbell.png',
                                ),
                                fit: BoxFit.fill,
                              )),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: allExerciseList.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return ExerciseListItem(
                                exercise: allExerciseList[index],
                              );
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
