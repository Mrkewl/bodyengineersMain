import 'package:bodyengineer/model/watch/watch_data.dart';

import '../../../model/watch/watch_model.dart';
import '../../../screen/health_stats/widget/chart_data.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../../translations.dart';

class RestingHeartStatCharts extends StatefulWidget {
  @override
  _RestingHeartStatChartsState createState() => _RestingHeartStatChartsState();
}

class _RestingHeartStatChartsState extends State<RestingHeartStatCharts> {
  List<Map<DateTime?, int?>> hearthrate = [];
  List<AreaSeries<ChartData, DateTime>> _getDefaultAreaSeries() {
    List<WatchDataObject> watchDataList =
        Provider.of<WatchModel>(context, listen: true).watchDataList!;
    // bulk edit //print(garminList);
    watchDataList.sort((a, b) => a.date!.compareTo(b.date!));
    final List<ChartData> chartData = watchDataList
        .map((e) => ChartData(
            x: DateTime(e.date!.year, e.date!.month, e.date!.day),
            y: e.restingHeartRate))
        .toList();
    // bulk edit //print(chartData);

    return <AreaSeries<ChartData, DateTime>>[
      AreaSeries<ChartData, DateTime>(
        dataSource: chartData,
        opacity: 0.7,
        name: 'Resting Hearth Rate',
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.y,
      )
    ];
  }

  /// Returns the default cartesian area chart.
  SfCartesianChart _getDefaultAreaChart() {
    ChartTitle chartTitle;
    if (hearthrate.isNotEmpty &&
        hearthrate.last.values.last != null &&
        hearthrate.last.values.last != 0) {
      chartTitle = ChartTitle(
        text: allTranslations.text('resting_heart_rate')! +
            ' \n' +
            hearthrate.last.values.last.toString(),
        textStyle: TextStyle(fontFamily: 'Lato', fontSize: 16),
      );
    } else {
      chartTitle = ChartTitle(
        text: allTranslations.text('resting_heart_rate')!,
        textStyle: TextStyle(fontFamily: 'Lato', fontSize: 16),
      );
    }

    return SfCartesianChart(
      axes: [],
      title: chartTitle,
      plotAreaBorderWidth: 0,
      primaryXAxis: DateTimeAxis(
          isVisible: false,
          dateFormat: DateFormat.yMMMd(),
          interval: 1,
          labelFormat: '',
          crossesAt: 0,
          intervalType: DateTimeIntervalType.years,
          majorGridLines: MajorGridLines(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.none),
      primaryYAxis: NumericAxis(
          minimum: 0,
          labelFormat: '',
          interval: 1,
          crossesAt: 0,
          isVisible: false,
          axisLine: AxisLine(width: 0),
          majorTickLines: MajorTickLines(size: 0)),
      series: _getDefaultAreaSeries(),
      onAxisLabelTapped: (args) {
        Navigator.pushNamed(context, '/resting_hr');
      },
      tooltipBehavior: TooltipBehavior(enable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    hearthrate = Provider.of<WatchModel>(context, listen: true)
        .watchDataList!
        .map((element) => {element.date: element.restingHeartRate})
        .toList();
    return GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/resting_hr'),
        child: _getDefaultAreaChart());
  }
}
