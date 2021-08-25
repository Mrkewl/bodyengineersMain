import 'package:bodyengineer/translations.dart';

import '../../model/planner/planner_model.dart';
import 'package:flutter/material.dart';
import '../../model/planner/bodystatsDay.dart';
import 'package:provider/provider.dart';

import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user.dart';
import 'package:intl/intl.dart' as intl;

class BodyMeasurementHistory extends StatefulWidget {
  @override
  _BodyMeasurementHistoryState createState() => _BodyMeasurementHistoryState();
}

class _BodyMeasurementHistoryState extends State<BodyMeasurementHistory> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  UserObject? user;
  BodystatsDay? bodystatsDay = BodystatsDay();
  DateTime? selectedDate;
  Map<DateTime, List<BodystatsDay>>? groupedBodystats;
  bodystatsDayCallback(BodystatsDay bodystatsDayCallbackElement) {
    setState(() {
      bodystatsDay = bodystatsDayCallbackElement;
      Provider.of<PlannerModel>(context, listen: false)
          .addBodyStatsDay(bodystatsDay: bodystatsDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<BodystatsDay?> bodystatsDayList =
        Provider.of<PlannerModel>(context, listen: true)
            .bodystatsDayList
            .where((bDay) => bDay!.measurements
                .where((measure) =>
                    measure.name == 'Neck' ||
                    measure.name == 'Shoulders' ||
                    measure.name == 'Chest' ||
                    measure.name == 'L Biceps' ||
                    measure.name == 'R Biceps' ||
                    measure.name == 'L Forearm' ||
                    measure.name == 'R Forearm' ||
                    measure.name == 'Waist' ||
                    measure.name == 'Hips' ||
                    measure.name == 'L Thigs' ||
                    measure.name == 'R Thighs' ||
                    measure.name == 'L Calf' ||
                    measure.name == 'R Calf')
                .isNotEmpty)
            .toList()
              ..sort((a, b) => a!.dateTime!.compareTo(b!.dateTime!));

    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (selectedDate == null) {
      setState(() {
        selectedDate = args != null && args['selectedDate'] != null
            ? args['selectedDate']
            : DateTime.now();
        if (bodystatsDayList
            .where((element) =>
                element!.dateTime ==
                DateTime(
                    selectedDate!.year, selectedDate!.month, selectedDate!.day))
            .isEmpty) {
          bodystatsDay!.dateTime = DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day);
        } else {
          bodystatsDay = bodystatsDayList
              .where((element) =>
                  element!.dateTime ==
                  DateTime(selectedDate!.year, selectedDate!.month,
                      selectedDate!.day))
              .first;
        }
      });
    }

    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.chevron_left,
                          size: 30,
                        ),
                      ),
                    ),
                    Text(
                      allTranslations.text('body_measurement_history')!,
                      style: TextStyle(fontSize: 20),
                    ),
                    GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.info_outline,
                          size: 25,
                        )),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: bodystatsDayList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/body_measurement',
                          arguments: {
                            'bodystatsDayCallback': bodystatsDayCallback,
                            'bodystatsDay': bodystatsDayList[index]
                          });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 7),
                      padding: EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            intl.DateFormat('EEEE')
                                .format(bodystatsDayList[index]!.dateTime!)
                                .toString(),
                          ),
                          Spacer(),
                          Text(
                            intl.DateFormat('dd/MM/yyyy')
                                .format(bodystatsDayList[index]!.dateTime!)
                                .toString(),
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
