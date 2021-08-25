import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';
import './widgets/workout_day_detail_item.dart';
import './widgets/m_group_cards.dart';
import '../../model/program/programWeek.dart';
import '../../model/program/program_model.dart';

class WeekDetail extends StatefulWidget {
  @override
  _WeekDetailState createState() => _WeekDetailState();
}

class _WeekDetailState extends State<WeekDetail> {
  GlobalKey<ScaffoldState> _key = GlobalKey();

  bool weekDetail = false;
  Map<String?, int?> lastMovement = {};
  Map<String?, int?> lastMuscle = {};
  List<String?> lastMovementTitles = [];
  List<String?> lastMuscleTitles = [];
  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    ProgramWeek programWeek = Provider.of<ProgramModel>(context)
        .programList
        .where((element) => element.programId == args!['programId'])
        .first
        .phaseList
        .where((element) => element.phaseNumber == args!['phaseNumber'])
        .first
        .programWeek
        .where((element) => element.weekNumber == args!['weekNumber'])
        .first;

    List<Map<String?, int?>> muscleList = programWeek.weekDays
        .map((days) => days.workoutList)
        .map((wrkL) => wrkL.map((wrk) =>
            wrk.exercise!.muscleGroup.map((e) => {e.muscleName: wrk.sets})))
        .expand((e) => e)
        .expand((e) => e)
        .toList();
    List<Map<String?, int?>> movementList = programWeek.weekDays
        .map((days) => days.workoutList)
        .map((wrkL) => wrkL.map((wrk) =>
            wrk.exercise!.movementGroup.map((e) => {e.movementName: wrk.sets})))
        .expand((e) => e)
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

    showAlertDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        spreadRadius: 3,
                      )
                    ]),
                child: Column(
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
                      itemCount: lastMovement.length,
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

    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Stack(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                Icons.chevron_left,
                                size: 30,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              allTranslations.text('details')!,
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            GestureDetector(
                                onTap: () => showAlertDialog(context),
                                child: Icon(Icons.info_outline)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(86, 177, 191, 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              allTranslations.text('week')! +
                                  ' ' +
                                  (int.parse(programWeek.weekNumber!) + 1)
                                      .toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Container(
                          child: Column(
                            children: [
                              Text(
                                allTranslations.text('description')!,
                                style: TextStyle(fontSize: 17),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  'A variety of 15 to 45 min workouts focused on endurance, with some strength mix in to keep  you balanced. Workouts range from low to high intensity.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: programWeek.weekDays.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return WorkoutDayDetailItem(
                                  programDay: programWeek.weekDays[index]);
                            }),
                      ),
                    ],
                  ),
                ),
              ),
              // Visibility(
              //   visible: weekDetail,
              //   child: Positioned(
              //     top: MediaQuery.of(context).size.height * 0.06,
              //     left: MediaQuery.of(context).size.height * 0.02,
              //     right: MediaQuery.of(context).size.height * 0.02,
              //     child: SingleChildScrollView(
              //       child: Container(
              //         padding: EdgeInsets.all(10),
              //         decoration: BoxDecoration(
              //             color: Colors.white,
              //             borderRadius: BorderRadius.circular(4),
              //             boxShadow: [
              //               BoxShadow(
              //                 color: Colors.black26,
              //                 blurRadius: 4,
              //                 spreadRadius: 3,
              //               )
              //             ]),
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Align(
              //               alignment: Alignment.topRight,
              //               child: GestureDetector(
              //                 onTap: () {
              //                   setState(() {
              //                     weekDetail = !weekDetail;
              //                   });
              //                 },
              //                 child: Icon(Icons.close),
              //               ),
              //             ),
              //             Text(
              //               'Muscle Group Sets:',
              //               style: TextStyle(
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //             ListView.builder(
              //               physics: NeverScrollableScrollPhysics(),
              //               shrinkWrap: true,
              //               itemCount: lastMovement.length,
              //               itemBuilder: (context, index) => MuscleGroupCard(
              //                 title: lastMuscleTitles[index],
              //                 value: lastMuscle[lastMuscleTitles[index]],
              //               ),
              //             ),
              //             SizedBox(height: 15),
              //             Text(
              //               'Movement Group Sets:',
              //               style: TextStyle(
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //             ListView.builder(
              //               physics: NeverScrollableScrollPhysics(),
              //               shrinkWrap: true,
              //               itemCount: lastMovement.length,
              //               itemBuilder: (context, index) => MovementGroupCard(
              //                 title: lastMovementTitles[index],
              //                 value: lastMovement[lastMovementTitles[index]],
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
