import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../model/program/program.dart';
import '../../model/program/program_model.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class ProgramDetails extends StatefulWidget {
  @override
  _ProgramDetailsState createState() => _ProgramDetailsState();
}

class _ProgramDetailsState extends State<ProgramDetails> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  String equipmentList = '';
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    Program program = Provider.of<ProgramModel>(context)
        .programList
        .where((element) => element.programId == args!['programId'])
        .first;
    // bulk edit //print(program);
    if (program != null) // bulk edit //print(program.equipmentList);
      program.equipmentList.forEach((element) {
        equipmentList += element.equipmentName! + ',';
      });
    // if (equipmentList.length > 0)
    //   equipmentList = equipmentList.replaceRange(
    //       equipmentList.length - 2, equipmentList.length - 1, '');
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            shadowColor: Color(0xffd6d6d6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.chevron_left,
                            size: 30,
                            color: Colors.black87,
                          ),
                        ),
                        Spacer(),
                        Text(
                          allTranslations.text('details')!,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                allTranslations.text('days_week')! + ':',
                                style: TextStyle(fontSize: 17),
                              ),
                              Text(
                                program.programDaysPerWeek.toString() +
                                    ' ' +
                                    allTranslations.text('days_week')!,
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                allTranslations.text('commitment')! + ':',
                                style: TextStyle(fontSize: 17),
                              ),
                              Text(
                                program.programHoursPerDay.toString() +
                                    ' ' +
                                    allTranslations.text('hour_day')!,
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                allTranslations.text('equipment')! + ':',
                                style: TextStyle(fontSize: 17),
                              ),
                              Container(
                                width: 175,
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: program.equipmentList.length,
                                  itemBuilder: (context, index) => Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Text(
                                      program
                                          .equipmentList[index].equipmentName!,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                allTranslations.text('fitness_level')! + ':',
                                style: TextStyle(fontSize: 17),
                              ),
                              Text(
                                program.programLevelName!,
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              program.programDescription!,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: program.dietDescription!.length > 1 ? true : false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                        child: Column(
                          children: [
                            Text(
                              allTranslations.text('diet_recommendation')!,
                              style: TextStyle(fontSize: 17),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                program.dietDescription!,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: program.phaseList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/phase_detail',
                                    arguments: {
                                      'programId': program.programId,
                                      'phaseNumber':
                                          program.phaseList[index].phaseNumber
                                    });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 15),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(8, 112, 138, 1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    allTranslations.text('phase')! +
                                        ' ' +
                                        (index + 1).toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
