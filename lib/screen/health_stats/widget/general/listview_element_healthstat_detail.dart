import 'package:bodyengineer/model/watch/watch_data.dart';

import '../../../../screen/health_stats/widget/general/listview_element_healtstat_element.dart';
import 'package:flutter/material.dart';

class ListViewElementHealthStatDetail extends StatefulWidget {
  List<WatchDataObject>? watchDataList;
  DateTime? firstDay;
  DateTime? lastDay;
  String? filterBy;
  ListViewElementHealthStatDetail(
      {this.watchDataList, this.firstDay, this.lastDay, this.filterBy});

  @override
  _ListViewElementHealthStatDetailState createState() =>
      _ListViewElementHealthStatDetailState();
}

class _ListViewElementHealthStatDetailState
    extends State<ListViewElementHealthStatDetail> {
  List<WatchDataObject>? listviewWatchDataObjectList = [];

  @override
  Widget build(BuildContext context) {
    if (widget.firstDay != null &&
        widget.lastDay != null &&
        widget.watchDataList!.isNotEmpty) {
      listviewWatchDataObjectList = widget.watchDataList!
          .where((element) =>
              element.date!.isAfter(widget.firstDay!) &&
              element.date!.isBefore(widget.lastDay!))
          .toList();
    } else if (widget.watchDataList!.isNotEmpty) {
      listviewWatchDataObjectList = widget.watchDataList;
    }
    if (listviewWatchDataObjectList!.isNotEmpty)
      listviewWatchDataObjectList!.sort((a, b) => b.date!.compareTo(a.date!));
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: listviewWatchDataObjectList!.length,
      itemBuilder: (context, index) {
        switch (widget.filterBy) {
          case 'bpm':
            return ListViewElementHealtStatElement(
              garminDate: listviewWatchDataObjectList![index].date,
              garminValueString:
                  listviewWatchDataObjectList![index].restingHeartRate != null
                      ? listviewWatchDataObjectList![index]
                              .restingHeartRate
                              .toString() +
                          ' ' +
                          widget.filterBy!
                      : 'No Data',
            );
            break;
          case 'Steps':
            return ListViewElementHealtStatElement(
              garminDate: listviewWatchDataObjectList![index].date,
              garminValueString:
                  listviewWatchDataObjectList![index].stepsTaken.toString() +
                      ' ' +
                      widget.filterBy!,
            );
            break;
          case 'hrs':
            return ListViewElementHealtStatElement(
              garminDate: listviewWatchDataObjectList![index].date,
              garminValueString: listviewWatchDataObjectList![index]
                      .sleep!
                      .totalSleepTime!
                      .inHours
                      .toString() +
                  ' ' +
                  widget.filterBy!,
            );
            break;
          default:
            return Container();
        }
      },
    );
  }
}
