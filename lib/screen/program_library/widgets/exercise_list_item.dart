import 'package:flutter/material.dart';

import '../../../be_theme.dart';
import '../../../model/program/exercise.dart';

// ignore: must_be_immutable
class ExerciseListItem extends StatefulWidget {
  Exercise? exercise;
  ExerciseListItem({this.exercise});
  @override
  _ExerciseListItemState createState() => _ExerciseListItemState();
}

class _ExerciseListItemState extends State<ExerciseListItem> {
  @override
  Widget build(BuildContext context) {
    return widget.exercise!.isCardio!
        ? CardioExercise(
            exercise: widget.exercise,
          )
        : NormalExercise(exercise: widget.exercise);
  }
}

class CardioExercise extends StatefulWidget {
  Exercise? exercise;
  CardioExercise({this.exercise});

  @override
  _CardioExerciseState createState() => _CardioExerciseState();
}

class _CardioExerciseState extends State<CardioExercise> {
  bool isSelected = false;
  MyTheme theme = MyTheme();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
      child: GestureDetector(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
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
                width: MediaQuery.of(context).size.width * 0.77,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 3),
                            width: MediaQuery.of(context).size.width * 0.14,
                            child: Text(
                              widget.exercise!.exerciseName!,
                              style: TextStyle(
                                fontSize: 11,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isSelected = !isSelected;
                                widget.exercise!.isSelected = isSelected;
                              });
                            },
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.add_circle,
                              size: 35,
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
  NormalExercise({this.exercise});

  @override
  _NormalExerciseState createState() => _NormalExerciseState();
}

class _NormalExerciseState extends State<NormalExercise> {
  bool isSelected = false;
  MyTheme theme = MyTheme();
  List<String?> muscleAndMovement = [];
  @override
  Widget build(BuildContext context) {
    muscleAndMovement = widget.exercise!.getListofMuscleMovement();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/exercise_detail', arguments: {
            'exercise': widget.exercise,
            'isComingExerciseList': true
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: theme.currentTheme() == ThemeMode.dark
                  ? Colors.grey[700]
                  : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  spreadRadius: 3,
                )
              ]),
          child: Row(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.045,
                width: MediaQuery.of(context).size.width * 0.105,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: (widget.exercise!.muscleGroup.isNotEmpty
                            ? NetworkImage(
                                widget.exercise!.muscleGroup.first.muscleImg!)
                            : AssetImage('assets/images/workout/muscle.png'))
                        as ImageProvider<Object>,
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.77,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 3),
                            width: MediaQuery.of(context).size.width * 0.14,
                            child: Text(
                              widget.exercise!.exerciseName!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
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
                              setState(() {
                                isSelected = !isSelected;
                                widget.exercise!.isSelected = isSelected;
                              });
                            },
                            child: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.add_circle,
                              size: 35,
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
