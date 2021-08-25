import 'package:bodyengineer/model/watch/watch_data.dart';

import '../../helper/tools_helper.dart';
import '../../model/planner/bodystatsDay.dart';
import '../../model/planner/measurement.dart';
import '../../model/planner/planner_model.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../model/watch/watch_model.dart';
import '../../screen/health_stats/widget/bar_widget.dart';
import '../../screen/health_stats/widget/bodyfat_stat_chats.dart';
import '../../screen/health_stats/widget/bodyweight_stat_charts.dart';
import '../../screen/health_stats/widget/resting_heart_stat_charts.dart';
import '../../screen/health_stats/widget/sleep_stat_charts.dart';
import '../../screen/health_stats/widget/step_stat_charts.dart';
import '../../screen/health_stats/widget/total_daily_energy.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../be_theme.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class HealthStats extends StatefulWidget {
  @override
  _HealthStatsState createState() => _HealthStatsState();
}

class _HealthStatsState extends State<HealthStats> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  MyTheme theme = MyTheme();
  List<Measurement> bodyfatMeasurements = [];
  List<Measurement> bodyWeightMeasurements = [];
  double leanMuscleMass = 0;
  int totalScore = 0;

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

  @override
  Widget build(BuildContext context) {
    UserObject user = Provider.of<UserModel>(context, listen: true).user!;
    List<WatchDataObject>? watchDataList =
        Provider.of<WatchModel>(context, listen: true).watchDataList;
    List<BodystatsDay?> bodyStatDayList =
        Provider.of<PlannerModel>(context, listen: true).bodystatsDayList;

    if (Provider.of<PlannerModel>(context, listen: true)
        .bodystatsDayList
        .isNotEmpty)
      bodyfatMeasurements = Tools.filterMeasurementFromBodystatDay(
          measurementName: 'Body Fat', bodystatsDayList: bodyStatDayList);

    if (Provider.of<PlannerModel>(context, listen: true)
        .bodystatsDayList
        .isNotEmpty)
      bodyWeightMeasurements = Tools.filterMeasurementFromBodystatDay(
          measurementName: 'Body Weight', bodystatsDayList: bodyStatDayList);

    if (bodyfatMeasurements.isNotEmpty && bodyWeightMeasurements.isNotEmpty)
      leanMuscleMass = Tools.calculateLeanMuscleMass(
          bodyFat: bodyfatMeasurements.last.value,
          bodyWeight: bodyWeightMeasurements.last.value!.round().toInt());
    if (bodyfatMeasurements.isNotEmpty)
      totalScore = _getPointForBoyfat(bodyfatMeasurements.last.value!) +
          Tools.leanMuscleMassPoint(
              leanMuscleMass: leanMuscleMass, gender: user.gender);
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(),
                      Text(
                        allTranslations.text('health_stats')!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(8, 112, 138, 1),
                        ),
                      ),
                      Spacer(),
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
                    margin: EdgeInsets.only(top: 20, bottom: 10),
                    padding: EdgeInsets.all(10),
                    width: MediaQuery.of(context).size.width,
                    height: 175,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.currentTheme() == ThemeMode.dark
                          ? Colors.grey[500]
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 3,
                            spreadRadius: 1,
                            offset: Offset(1, 2),
                            color: Color(0xffd6d6d6))
                      ],
                    ),
                    child: bodyWeightMeasurements.isNotEmpty
                        ? Container(child: TotalDailyEnergyTable())
                        : Container(),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/fitness_score',
                        arguments: {
                          'LMM': bodyWeightMeasurements.isNotEmpty
                              ? leanMuscleMass
                              : '-',
                          'bodyfat': bodyfatMeasurements.isNotEmpty
                              ? bodyfatMeasurements.last.value
                              : 0,
                          'totalScore': totalScore,
                        }),
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  allTranslations.text('fitness_score')!,
                                  style: TextStyle(fontSize: 17),
                                ),
                                Text(
                                  totalScore.toString() + '/80',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(),
                            width: MediaQuery.of(context).size.width,
                            height: 150,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(allTranslations
                                              .text('lean_muscle_mass')! +
                                          ' :'),
                                      if (bodyWeightMeasurements.isNotEmpty)
                                        Text(leanMuscleMass.toString()),
                                      Container(
                                        width: 100,
                                        child: BarStatWidget(
                                          data1: Tools.leanMuscleMassPoint(
                                              leanMuscleMass: leanMuscleMass,
                                              gender: user.gender),
                                          data2: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                VerticalDivider(color: Colors.black26),
                                Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text('BodyFat% :'),
                                      if (bodyfatMeasurements.isNotEmpty)
                                        Text(bodyfatMeasurements.last.value
                                                .toString() +
                                            '%'),
                                      if (bodyfatMeasurements.isEmpty)
                                        Text('No Data'),
                                      Container(
                                        width: 100,
                                        child: BarStatWidget(
                                          data1: bodyfatMeasurements.isNotEmpty
                                              ? _getPointForBoyfat(
                                                  bodyfatMeasurements
                                                      .last.value!)
                                              : 10,
                                          data2: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // VerticalDivider(color: Colors.black26),
                                // Container(
                                //   width:
                                //       MediaQuery.of(context).size.width / 3.75,
                                //   child: Column(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceBetween,
                                //     crossAxisAlignment:
                                //         CrossAxisAlignment.start,
                                //     children: [
                                //       Text('Resting Heart Rate :'),
                                //       Text(garminList != null
                                //           ? garminList.last.restingHeartRate !=
                                //                   null
                                //               ? garminList.last.restingHeartRate
                                //                   .toString()
                                //               : '-'
                                //           : '-'),
                                //       Container(
                                //         width: 100,
                                //         child: BarStatWidget(
                                //           data1: 10,
                                //           data2: 40,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/resting_hr'),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 175,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: theme.currentTheme() == ThemeMode.dark
                                  ? Colors.grey[500]
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                    offset: Offset(1, 2),
                                    color: Color(0xffd6d6d6))
                              ],
                            ),
                            child: watchDataList != null
                                ? RestingHeartStatCharts()
                                : Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          allTranslations
                                              .text('resting_heart_rate')!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 17),
                                        )
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, '/step_stats',
                              arguments: {'watchDataList': watchDataList}),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 175,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: theme.currentTheme() == ThemeMode.dark
                                  ? Colors.grey[500]
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                    offset: Offset(1, 2),
                                    color: Color(0xffd6d6d6))
                              ],
                            ),
                            child: watchDataList != null
                                ? StepStatCharts()
                                : Container(
                                    child: Column(
                                    children: [
                                      Text(
                                        allTranslations.text('steps')!,
                                        style: TextStyle(fontSize: 17),
                                      )
                                    ],
                                  )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/body_weight'),
                          child: Container(
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 175,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: theme.currentTheme() == ThemeMode.dark
                                    ? Colors.grey[500]
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 3,
                                      spreadRadius: 1,
                                      offset: Offset(1, 2),
                                      color: Color(0xffd6d6d6))
                                ],
                              ),
                              child: bodyWeightMeasurements.isNotEmpty
                                  ? BodyWeightCharts()
                                  : Container(
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Body Weight',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    )),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/bodyfat'),
                          child: Container(
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 175,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: theme.currentTheme() == ThemeMode.dark
                                    ? Colors.grey[500]
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 3,
                                      spreadRadius: 1,
                                      offset: Offset(1, 2),
                                      color: Color(0xffd6d6d6))
                                ],
                              ),
                              child: bodyfatMeasurements.isNotEmpty
                                  ? BodyFatCharts()
                                  : Container(
                                      alignment: Alignment.topCenter,
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Body Fat',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    )),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/sleep_stats'),
                          child: Container(
                              padding: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 175,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: theme.currentTheme() == ThemeMode.dark
                                    ? Colors.grey[500]
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 3,
                                      spreadRadius: 1,
                                      offset: Offset(1, 2),
                                      color: Color(0xffd6d6d6))
                                ],
                              ),
                              child: watchDataList != null
                                  ? SleepStatCharts()
                                  : Container(
                                      child: Column(
                                        children: [
                                          Text(
                                            allTranslations.text('sleep')!,
                                            style: TextStyle(
                                              fontFamily: 'Lato',
                                              fontSize: 17,
                                            ),
                                          )
                                        ],
                                      ),
                                    )),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, '/progress_photo_history'),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 175,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: theme.currentTheme() == ThemeMode.dark
                                  ? Colors.grey[500]
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 3,
                                    spreadRadius: 1,
                                    offset: Offset(1, 2),
                                    color: Color(0xffd6d6d6))
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  allTranslations.text('progress_photo')!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Lato', fontSize: 18),
                                ),
                                Spacer(),
                                Icon(
                                  Icons.photo_camera_front,
                                  size: 60,
                                  color: Color.fromRGBO(8, 112, 138, 1),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                        // GestureDetector(
                        //   onTap: () => Navigator.pushNamed(context, '/vo2_max'),
                        //   child: Container(
                        //       padding: EdgeInsets.all(10),
                        //       width: MediaQuery.of(context).size.width * 0.4,
                        //       height: 175,
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(5),
                        //         color: theme.currentTheme() == ThemeMode.dark
                        //             ? Colors.grey[500]
                        //             : Colors.white,
                        //         boxShadow: [
                        //           BoxShadow(
                        //             color: Colors.black12,
                        //             blurRadius: 3,
                        //             spreadRadius: 3,
                        //           ),
                        //         ],
                        //       ),
                        //       child: garminList != null
                        //           ? Vo2MaxStatCharts()
                        //           : Container(
                        //               alignment: Alignment.topCenter,
                        //               child: Text(
                        //                 'Vo2Max',
                        //                 style: TextStyle(fontSize: 17),
                        //               ),
                        //             )),
                        // ),
                      ],
                    ),
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
