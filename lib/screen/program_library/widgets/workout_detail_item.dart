import 'package:flutter/material.dart';

import '../../../model/program/workout.dart';

// ignore: must_be_immutable
class WorkoutDetailItem extends StatelessWidget {
  Workout? workout;
  WorkoutDetailItem({this.workout});
  @override
  Widget build(BuildContext context) {
    return workout!.exercise == null
        ? Container(
            child: Text('Null Exercise'),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/exercise_detail',
                    arguments: {'exercise': workout!.exercise});
              },
              child: Container(
                padding: EdgeInsets.only(top: 10,bottom: 10,left: 4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                        boxShadow: [
                      BoxShadow(
                          blurRadius: 3,
                          spreadRadius: 1,
                          offset: Offset(1, 2),
                          color: Color(0xffd6d6d6))
                    ],),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.1,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: (workout!.exercise!.muscleGroup.isNotEmpty
                              ? NetworkImage(
                                  workout!.exercise!.muscleGroup.first.muscleImg!)
                              : AssetImage('assets/images/workout/muscle.png')) as ImageProvider<Object>,
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  child: Text(
                                    workout!.exercise!.exerciseName ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  // width: MediaQuery.of(context).size.width * 0.12,
                                  child: Text(
                                    workout!.exercise!.muscleGroup.isNotEmpty
                                        ? workout!.exercise!.muscleGroup.first
                                                .muscleName ??
                                            '-'
                                        : '-',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  // width: MediaQuery.of(context).size.width * 0.12,
                                  child: Text(
                                    workout!.exercise!.equipmentGroup.isNotEmpty
                                        ? workout!.exercise!.equipmentGroup.first
                                                .equipmentName ??
                                            '-'
                                        : '-',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  // width: MediaQuery.of(context).size.width * 0.18,
                                  child: Text(
                                    workout!.exercise!.movementGroup.isNotEmpty
                                        ? workout!.exercise!.movementGroup.first
                                                .movementName ??
                                            '-'
                                        : '-',
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text('${workout!.sets} Sets'),
                              Text('X'),
                              Text('${workout!.reps} Reps'),
                            ],
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
