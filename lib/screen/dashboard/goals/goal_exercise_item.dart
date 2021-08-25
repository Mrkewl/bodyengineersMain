import 'package:flutter/material.dart';

import '../../../model/program/exercise.dart';

// ignore: must_be_immutable
class GoalExerciseListItem extends StatefulWidget {
  Exercise? exercise;
  Function? callback;
  GoalExerciseListItem({this.exercise, this.callback});
  @override
  _GoalExerciseListItemState createState() => _GoalExerciseListItemState();
}

class _GoalExerciseListItemState extends State<GoalExerciseListItem> {
  @override
  Widget build(BuildContext context) {
    return widget.exercise!.isCardio!
        ? CardioExercise(exercise: widget.exercise, callback: widget.callback)
        : NormalExercise(
            exercise: widget.exercise,
            callback: widget.callback,
          );
  }
}

class CardioExercise extends StatefulWidget {
  Exercise? exercise;
  Function? callback;
  CardioExercise({this.exercise, this.callback});

  @override
  _CardioExerciseState createState() => _CardioExerciseState();
}

class _CardioExerciseState extends State<CardioExercise> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  spreadRadius: 3,
                )
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.045,
                width: MediaQuery.of(context).size.width * 0.105,
                child: Container(
                  width: 20,
                  child: Image.asset(
                    widget.exercise!.exerciseIcon!,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.76,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.145,
                            child: Text(
                              widget.exercise!.exerciseName!,
                              style: TextStyle(
                                fontSize: 11,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              widget.callback!(widget.exercise!.exerciseId);
                            },
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.add_circle,
                              size: 30,
                              color: isSelected
                                  ? Color.fromRGBO(8, 112, 138, 1)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
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

class NormalExercise extends StatefulWidget {
  Exercise? exercise;
  Function? callback;
  NormalExercise({this.exercise, this.callback});

  @override
  _NormalExerciseState createState() => _NormalExerciseState();
}

class _NormalExerciseState extends State<NormalExercise> {
  bool isSelected = false;
  List<String?> muscleAndMovement = [];

  @override
  Widget build(BuildContext context) {
    muscleAndMovement = widget.exercise!.getListofMuscleMovement();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/exercise_detail',
              arguments: {'exercise': widget.exercise});
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  spreadRadius: 3,
                )
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.045,
                width: MediaQuery.of(context).size.width * 0.105,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: (widget.exercise!.muscleGroup.isNotEmpty
                        ? NetworkImage(
                            widget.exercise!.muscleGroup.first.muscleImg!)
                        : AssetImage('assets/images/workout/muscle.png')) as ImageProvider<Object>,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.76,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.145,
                            child: Text(
                              widget.exercise!.exerciseName!,
                              style: TextStyle(
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: muscleAndMovement.length,
                                itemBuilder: (context, index) => Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Text(
                                          muscleAndMovement[index]!,
                                          style: TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    )),
                          ),
                          GestureDetector(
                            onTap: () {
                              widget.callback!(widget.exercise);
                              Navigator.pop(context);
                            },
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.add_circle,
                              size: 30,
                              color: isSelected
                                  ? Color.fromRGBO(8, 112, 138, 1)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
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
