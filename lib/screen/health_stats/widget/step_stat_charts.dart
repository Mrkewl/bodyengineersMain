import 'package:bodyengineer/model/watch/watch_data.dart';

import '../../../model/watch/garmin.dart';
import '../../../model/watch/watch_model.dart';
import '../../../screen/health_stats/widget/chart_data.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class StepStatCharts extends StatefulWidget {
  @override
  _StepStatChartsState createState() => _StepStatChartsState();
}

class _StepStatChartsState extends State<StepStatCharts> {
  List<Map<DateTime?, int?>> stepsTaken = [];
  List<WatchDataObject>? watchDataList = [];
  List<AreaSeries<ChartData, DateTime>> _getDefaultAreaSeries() {
    // bulk edit //print(garminList);
    watchDataList!.sort((a, b) => a.date!.compareTo(b.date!));
    final List<ChartData> chartData = watchDataList!
        .map((e) => ChartData(
            x: DateTime(e.date!.year, e.date!.month, e.date!.day),
            y: e.stepsTaken))
        .toList();
    // bulk edit //print(chartData);

    return <AreaSeries<ChartData, DateTime>>[
      AreaSeries<ChartData, DateTime>(
        dataSource: chartData,
        opacity: 0.7,
        name: 'Steps',
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.y,
      )
    ];
  }

  /// Returns the default cartesian area chart.
  SfCartesianChart _getDefaultAreaChart(List<WatchDataObject>? garminList) {
    ChartTitle chartTitle;
    if (stepsTaken.isNotEmpty &&
        stepsTaken.last.values.last != null &&
        stepsTaken.last.values.last != 0) {
      chartTitle = ChartTitle(
        text: 'Steps \n' + stepsTaken.last.values.last.toString(),
        textStyle: TextStyle(fontFamily: 'Lato', fontSize: 16),
      );
    } else {
      chartTitle = ChartTitle(
        text: 'Steps',
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
      onPointTapped: (args) {
        Navigator.pushNamed(context, '/step_stats',
            arguments: {'garmin_list': garminList});
      },
      tooltipBehavior: TooltipBehavior(enable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    watchDataList =
        Provider.of<WatchModel>(context, listen: true).watchDataList;
    stepsTaken = Provider.of<WatchModel>(context, listen: true)
        .watchDataList!
        .map((element) => {element.date: element.stepsTaken})
        .toList();
    return _getDefaultAreaChart(watchDataList);
  }
}
