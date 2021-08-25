import 'package:flutter/material.dart';

import '../../../translations.dart';
import './workout_detail_item.dart';
import '../../../model/program/programDay.dart';
import './m_group_cards.dart';

// ignore: must_be_immutable
class WorkoutDayDetailItem extends StatefulWidget {
  ProgramDay? programDay;

  WorkoutDayDetailItem({this.programDay});

  @override
  _WorkoutDayDetailItemState createState() => _WorkoutDayDetailItemState();
}

class _WorkoutDayDetailItemState extends State<WorkoutDayDetailItem> {
  Map<String?, int?> lastMovement = {};
  Map<String?, int?> lastMuscle = {};
  List<String?> lastMovementTitles = [];
  List<String?> lastMuscleTitles = [];
  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          content: SingleChildScrollView(
            child: Container(
              width: 200,
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close),
                    ),
                  ),
                  Text(
                    'Muscle Group Sets:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: lastMuscle.length,
                    itemBuilder: (context, index) => MuscleGroupCard(
                      title: lastMuscleTitles[index],
                      value: lastMuscle[lastMuscleTitles[index]],
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Movement Group Sets:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: lastMovement.length,
                    itemBuilder: (context, index) => MovementGroupCard(
                      title: lastMovementTitles[index],
                      value: lastMovement[lastMovementTitles[index]],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String?, int?>> muscleList = widget.programDay!.workoutList
        .map((wrk) =>
            wrk.exercise!.muscleGroup.map((e) => {e.muscleName: wrk.sets}))
        .expand((e) => e)
        .toList();
    List<Map<String?, int?>> movementList = widget.programDay!.workoutList
        .map((wrk) =>
            wrk.exercise!.movementGroup.map((e) => {e.movementName: wrk.sets}))
        .expand((e) => e)
        .toList();

    lastMuscle = {};
    muscleList.forEach((mscl) {
      if (lastMuscle[mscl.keys.first] != null) {
        lastMuscle[mscl.keys.first] =
            lastMuscle[mscl.keys.first]! + mscl.values.first!;
      } else {
        lastMuscle[mscl.keys.first] = mscl.values.first;
      }
    });
    lastMovement = {};
    movementList.forEach((movemnt) {
      if (lastMovement[movemnt.keys.first] != null) {
        lastMovement[movemnt.keys.first] =
            lastMovement[movemnt.keys.first]! + movemnt.values.first!;
      } else {
        lastMovement[movemnt.keys.first] = movemnt.values.first;
      }
    });

    lastMuscleTitles = lastMuscle.keys.map((e) => e).toList();
    lastMovementTitles = lastMovement.keys.map((e) => e).toList();

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  spreadRadius: 3,
                )
              ]),
          margin: EdgeInsets.all(5),
          child: ExpansionTile(
            backgroundColor: Colors.white,
            trailing: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black54,
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.12,
                top: MediaQuery.of(context).size.width * 0.02,
                bottom: MediaQuery.of(context).size.width * 0.015,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.programDay!.name!,
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    allTranslations.text('number_of_exercise')! +
                        ': ' +
                        widget.programDay!.workoutList.length.toString(),
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    allTranslations.text('estimated_time')! +
                        ': ' +
                        ((widget.programDay!.workoutList.length) * 10)
                            .toString() +
                        ' ' +
                        allTranslations.text('minutes')!,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            title: Row(
              children: [
                Text(
                  allTranslations.text('day')! +
                      ' ' +
                      (widget.programDay!.countDay).toString(),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                GestureDetector(
                    onTap: () => showAlertDialog(context),
                    child: Icon(Icons.info_outline)),
              ],
            ),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.programDay!.workoutList.length,
                    itemBuilder: (BuildContext ctxt, int index) {
                      return WorkoutDetailItem(
                        workout: widget.programDay!.workoutList[index],
                      );
                    }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
