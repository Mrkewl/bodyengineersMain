import 'package:bodyengineer/translations.dart';

import '../../model/planner/planner_model.dart';
import '../../model/program/program.dart';
import '../../model/program/programDay.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../program_library/widgets/program_phase_detail_item.dart';

class AddWorkout extends StatefulWidget {
  @override
  _AddWorkoutState createState() => _AddWorkoutState();
}

class _AddWorkoutState extends State<AddWorkout> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  DateTime? dateTime;
  bool openPhases = false;

  bool isSelected = false;
  Program? program;
  DateTime? weekStart;
  DateTime? weekEnd;
  int seenPhase = 0;
  int seenWeek = 0;
  void clickCallBack(phaseIndex, weekIndex) {
    setState(() {
      seenPhase = phaseIndex;
      seenWeek = weekIndex;
      openPhases = !openPhases;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    if (program == null)
      program = Provider.of<PlannerModel>(context, listen: false)
          .getPlannerAsProgram(isAddon: false);
    if (program != null) {
      weekStart = program!.phaseList[seenPhase].programWeek[seenWeek].startDate;
      weekEnd = program!.phaseList[seenPhase].programWeek[seenWeek].endDate;
    }
    Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    dateTime = args['dateTime'];

    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: program == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.chevron_left,
                              size: 35,
                            ),
                          ),
                          Spacer(),
                          Text(
                            allTranslations.text('training_program')!,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  allTranslations.text('phase')! +
                                      ' ' +
                                      (int.parse(program!.phaseList[seenPhase]
                                                  .phaseNumber!) +
                                              1)
                                          .toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  allTranslations.text('week')! +
                                      ' ' +
                                      (int.parse(program!
                                                  .phaseList[seenPhase]
                                                  .programWeek[seenWeek]
                                                  .weekNumber!) +
                                              1)
                                          .toString() +
                                      ' (${dateTime!.day} / ${dateTime!.month} / ${dateTime!.year})',
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        openPhases = !openPhases;
                                      });
                                    },
                                    child: Icon(Icons.logout)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: program!.phaseList[seenPhase]
                              .programWeek[seenWeek].weekDays.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return AddWorkoutListItem(
                                programDay: program!.phaseList[seenPhase]
                                    .programWeek[seenWeek].weekDays[index]);
                          }),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                          backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                          padding: const EdgeInsets.symmetric(horizontal: 25),),
                          onPressed: () async {
                            List<ProgramDay> listProgramday = [];
                            program!.phaseList[seenPhase].programWeek[seenWeek]
                                .weekDays
                                .where((element) => element.isSelected)
                                .forEach((programDay) {
                              listProgramday.add(programDay);
                              programDay.isSelected = false;
                            });

                            await Provider.of<PlannerModel>(context,
                                    listen: false)
                                .addProgramDay(
                                    dateTime: dateTime,
                                    listProgramday: listProgramday);

                            Navigator.pop(context);
                          },
                          child: Text(
                            allTranslations.text('save')!,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: openPhases,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.5,
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height,
                      ),
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 4,
                        )
                      ]),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        openPhases = !openPhases;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.close,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text('Lean Fit'),
                                  Text(
                                    'Program Duration',
                                    style: TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    '(5 May 2020 - 5 July 2020)',
                                    style: TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 25),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  // itemCount: 0,
                                  itemCount: program!.phaseList.length,
                                  itemBuilder: (BuildContext ctxt, int index) {
                                    return ProgramPhaseDetailItem(
                                      clickCallBack: clickCallBack,
                                      phaseNo: (index + 1).toString(),
                                      programPhase: program!.phaseList[index],
                                    );
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ]),
      ),
    );
  }
}

// ignore: must_be_immutable
class AddWorkoutListItem extends StatefulWidget {
  ProgramDay? programDay;
  AddWorkoutListItem({this.programDay});

  @override
  _AddWorkoutListItemState createState() => _AddWorkoutListItemState();
}

class _AddWorkoutListItemState extends State<AddWorkoutListItem> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.programDay!.name!,
                  style: TextStyle(
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  widget.programDay!.workoutList.length.toString() +
                      ' ' +
                      allTranslations.text('exercises')!,
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  widget.programDay!.isSelected =
                      !widget.programDay!.isSelected;
                });
              },
              child: Icon(
                widget.programDay!.isSelected
                    ? Icons.check_circle
                    : Icons.add_circle,
                size: 35,
                color: widget.programDay!.isSelected
                    ? Color.fromRGBO(8, 112, 138, 1)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
