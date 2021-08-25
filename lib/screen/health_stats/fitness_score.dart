import '../../helper/tools_helper.dart';
import '../../model/planner/bodystatsDay.dart';
import '../../model/planner/fitness_score.dart';
import '../../model/planner/measurement.dart';
import '../../model/planner/planner_model.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class FitnessScore extends StatefulWidget {
  @override
  _FitnessScoreState createState() => _FitnessScoreState();
}

class _FitnessScoreState extends State<FitnessScore> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  List<Measurement> bodyfatMeasurements = [];
  List<Measurement> bodyWeightMeasurements = [];
  List<FitnessScoreElement>? listFitnessScore;
  List<BodystatsDay?>? bodyStatDayList;
  late List<DateTime?> dateTimeList;
  FitnessScoreElement? fitnessScoreElement;
  DateTime? selectedDateTime;
  int _getPointForBoyfat(double bodyFat) {
    int result;
    if (bodyFat <= 12) {
      result = 30;
    } else if (bodyFat <= 15 && bodyFat > 12) {
      result = 40;
    } else if (bodyFat <= 30 && bodyFat > 15) {
      result = 30;
    } else if (bodyFat <= 36 && bodyFat > 30) {
      result = 40;
    } else {
      result = 8;
    }
    return result;
  }

  calculateFitnessScore(UserObject? user) {
    listFitnessScore = [];
    if (bodyStatDayList!.isNotEmpty)
      bodyfatMeasurements = Tools.filterMeasurementFromBodystatDay(
          measurementName: 'Body Fat', bodystatsDayList: bodyStatDayList!);

    if (bodyStatDayList!.isNotEmpty)
      bodyWeightMeasurements = Tools.filterMeasurementFromBodystatDay(
          measurementName: 'Body Weight', bodystatsDayList: bodyStatDayList!);

    print(bodyfatMeasurements);
    print(bodyWeightMeasurements);
    listFitnessScore = dateTimeList.map((dateTime) {
      double bodyFat = bodyfatMeasurements
          .firstWhere((element) => element.dateTime == dateTime)
          .value!;
      double leanMuscleMass = Tools.calculateLeanMuscleMass(
          bodyFat: bodyFat,
          bodyWeight: bodyWeightMeasurements
              .firstWhere((element) => element.dateTime == dateTime)
              .value!
              .round()
              .toInt());
      int totalScore = _getPointForBoyfat(bodyFat) +
          Tools.leanMuscleMassPoint(
              leanMuscleMass: leanMuscleMass, gender: user!.gender);

      FitnessScoreElement fitnessScoreElement = FitnessScoreElement()
        ..bodyFat = bodyFat
        ..dateTime = dateTime
        ..leanMuscleMass = leanMuscleMass
        ..totalScore = totalScore;
      return fitnessScoreElement;
    }).toList();

    if (listFitnessScore!.isNotEmpty) {
      listFitnessScore!.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
      setState(() {
        selectedDateTime = listFitnessScore!.first.dateTime;
      });
    }
    setState(() {
      listFitnessScore = listFitnessScore;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    bodyStatDayList =
        Provider.of<PlannerModel>(context, listen: true).bodystatsDayList;
    dateTimeList = bodyStatDayList!
        .where((bday) =>
            bday!.measurements
                .where((measeure) => measeure.name == 'Body Fat')
                .isNotEmpty &&
            bday.measurements
                .where((measeure) => measeure.name == 'Body Weight')
                .isNotEmpty)
        .map((e) => e!.dateTime)
        .toList();
    if (bodyStatDayList != null &&
        bodyStatDayList!.isNotEmpty &&
        listFitnessScore == null) calculateFitnessScore(user);

    if (selectedDateTime != null &&
        listFitnessScore != null &&
        listFitnessScore!
            .where((element) => element.dateTime == selectedDateTime)
            .isNotEmpty)
      fitnessScoreElement = listFitnessScore!
          .firstWhere((element) => element.dateTime == selectedDateTime);

    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 3,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    height: 60,
                                    child: DropdownButtonFormField(
                                      validator: (dynamic value) =>
                                          value == null
                                              ? 'This field is required'
                                              : null,
                                      onChanged: (DateTime? value) {
                                        setState(() {
                                          selectedDateTime = value;
                                        });
                                      },
                                      items: listFitnessScore!
                                          .map((e) => e.dateTime)
                                          .toList()
                                          .map((value) => DropdownMenuItem(
                                                child: Text(
                                                    intl.DateFormat('d/M/y')
                                                        .format(value!)),
                                                value: value,
                                              ))
                                          .toList(),
                                      icon: Icon(Icons.keyboard_arrow_down),
                                      value: selectedDateTime,
                                    ),
                                  ),
                                ),
                                Text(
                                  allTranslations.text('fitness_score')!,
                                  style: TextStyle(fontSize: 16),
                                ),
                                if (fitnessScoreElement != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Text(
                                      fitnessScoreElement!.totalScore
                                              .toString() +
                                          '/80',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ),
                              ],
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
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.07,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (fitnessScoreElement != null)
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.7,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(allTranslations
                                              .text('lean_muscle_mass')! +
                                          ' :'),
                                      Text(fitnessScoreElement!.leanMuscleMass
                                          .toString()),
                                    ],
                                  ),
                                ),
                              if (fitnessScoreElement != null)
                                Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(allTranslations.text('bodyfat')! +
                                          '% :'),
                                      Text(fitnessScoreElement!.bodyFat
                                          .toString()),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    allTranslations.text('lean_muscle_mass_score')! + ':',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est eopksio laborum. Sed ut perspiciatis unde omnis istpoe natus error sit voluptatem accusantium doloremque eopsloi laudantium, totam rem aperiam,',
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                  SizedBox(height: 20),
                  Text(
                    allTranslations.text('bodyfat')! +
                        '% ' +
                        allTranslations.text('score')! +
                        ':',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est eopksio laborum. Sed ut perspiciatis unde omnis istpoe natus error sit voluptatem accusantium doloremque eopsloi laudantium, totam rem aperiam,',
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
