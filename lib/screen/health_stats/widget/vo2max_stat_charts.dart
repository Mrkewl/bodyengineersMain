import '../../../model/watch/garmin.dart';
import '../../../model/watch/watch_model.dart';
import '../../../screen/health_stats/widget/chart_data.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Vo2MaxStatCharts extends StatefulWidget {
  @override
  _Vo2MaxStatChartsState createState() => _Vo2MaxStatChartsState();
}

class _Vo2MaxStatChartsState extends State<Vo2MaxStatCharts> {
  List<AreaSeries<ChartData, DateTime>> _getDefaultAreaSeries() {
    List<Garmin> garminList =
        Provider.of<WatchModel>(context, listen: true).garminDataList!;
    // bulk edit //print(garminList);
    garminList.sort((a, b) => a.date!.compareTo(b.date!));
    final List<ChartData> chartData = garminList
        .map((e) => ChartData(
            x: DateTime(e.date!.year, e.date!.month, e.date!.day), y: e.vo2Max))
        .toList();
    // bulk edit //print(chartData);

    return <AreaSeries<ChartData, DateTime>>[
      AreaSeries<ChartData, DateTime>(
        dataSource: chartData,
        opacity: 0.7,
        name: 'Vo2Max',
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.y,
      )
    ];
  }

  /// Returns the default cartesian area chart.
  SfCartesianChart _getDefaultAreaChart() {
    return SfCartesianChart(
      axes: [],
      title: ChartTitle(
        text: 'Vo2Max',
        textStyle: TextStyle(fontFamily: 'Lato', fontSize: 16),
      ),
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
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getDefaultAreaChart();
  }
}
