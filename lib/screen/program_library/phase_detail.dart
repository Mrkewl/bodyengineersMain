import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../model/program/programPhase.dart';
import '../../model/program/program_model.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class PhaseDetail extends StatefulWidget {
  @override
  _PhaseDetailState createState() => _PhaseDetailState();
}

class _PhaseDetailState extends State<PhaseDetail> {
  GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    ProgramPhase programPhase = Provider.of<ProgramModel>(context)
        .programList
        .where((element) => element.programId == args!['programId'])
        .first
        .phaseList
        .where((element) => element.phaseNumber == args!['phaseNumber'])
        .first;

    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(8, 112, 138, 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          allTranslations.text('phase')! + ' 1',
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
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Text(allTranslations.text('phase_duration')! +
                                    ': '),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.05),
                                Text('4 ' + allTranslations.text('weeks')!),
                              ],
                            ),
                          ),
                          Text(
                            programPhase.phaseDescription!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: programPhase.programWeek.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/week_detail',
                                    arguments: {
                                      'programId': programPhase.programId,
                                      'phaseNumber': programPhase.phaseNumber,
                                      'weekNumber': programPhase
                                          .programWeek[index].weekNumber
                                    });
                              },
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
                                        (int.parse(programPhase
                                                    .programWeek[index]
                                                    .weekNumber!) +
                                                1)
                                            .toString(),
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
