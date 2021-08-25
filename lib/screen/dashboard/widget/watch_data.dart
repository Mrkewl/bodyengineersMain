import 'package:bodyengineer/model/watch/watch_data.dart';


import '../../../../screen/dashboard/goals/widgets/goal_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../translations.dart';

class WatchData extends StatelessWidget {
  List<WatchDataObject>? watchDataList;

  DateTime? dateTime;
  WatchData({this.watchDataList, this.dateTime});
  DateTime today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateTime == today
              ? allTranslations.text('today')!
              : intl.DateFormat.EEEE().format(dateTime!),
          style: TextStyle(fontSize: 17),
        ),
        if (watchDataList != null &&
            watchDataList!
                .where((element) => element.date == dateTime)
                .isNotEmpty)
          if (watchDataList!
                  .where((element) => element.date == dateTime)
                  .first
                  .stepsTaken !=
              null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  allTranslations.text('steps')!,
                  style: TextStyle(fontSize: 15),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(watchDataList!
                            .where((element) => element.date == dateTime)
                            .first
                            .stepsTaken
                            .toString() +
                        '/10000 ' +
                        allTranslations.text('steps')!),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 25,
                      child: GoalProgressBarWidget(
                        data1: watchDataList!
                                    .where(
                                        (element) => element.date == dateTime)
                                    .first
                                    .stepsTaken! >
                                10000
                            ? 10000
                            : watchDataList!
                                .where((element) => element.date == dateTime)
                                .first
                                .stepsTaken?.toDouble(),
                        data2: 10000,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        if (watchDataList != null &&
            watchDataList!
                .where((element) => element.date == dateTime)
                .isNotEmpty &&
            watchDataList!
                    .where((element) => element.date == dateTime)
                    .first
                    .sleep !=
                null &&
            watchDataList!
                    .where((element) => element.date == dateTime)
                    .first
                    .sleep!
                    .totalSleepTime !=
                null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                allTranslations.text('sleep')!,
                style: TextStyle(fontSize: 15),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    watchDataList!
                            .where((element) => element.date == dateTime)
                            .first
                            .sleep!
                            .totalSleepTime!
                            .inHours
                            .toString() +
                        '/8 ' +
                        allTranslations.text('hours')!,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 25,
                    child: GoalProgressBarWidget(
                      data1: watchDataList!
                                  .where((element) => element.date == dateTime)
                                  .first
                                  .sleep!
                                  .totalSleepTime!
                                  .inHours >
                              8
                          ? 8
                          : watchDataList!
                              .where((element) => element.date == dateTime)
                              .first
                              .sleep!
                              .totalSleepTime!
                              .inHours.toDouble(),
                      data2: 8,
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
