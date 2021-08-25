import 'package:bodyengineer/model/watch/watch_data.dart';

import '../../../../model/watch/garmin.dart';
import '../../../../screen/health_stats/widget/chart_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class StepDetailChart extends StatefulWidget {
  List<WatchDataObject>? watchDataList;
  DateTime? firstDate;
  DateTime? lastDate;
  StepDetailChart({this.firstDate, this.lastDate, this.watchDataList});
  @override
  _StepDetailChartState createState() => _StepDetailChartState();
}

class _StepDetailChartState extends State<StepDetailChart> {
  List<ColumnSeries<ChartData, DateTime>> _getDefaultAreaSeries() {
    widget.watchDataList!.sort((a, b) => a.date!.compareTo(b.date!));
    final List<ChartData> chartData = widget.watchDataList!
        .where((element) {
          return element.date!.isAfter(widget.firstDate ??
                  DateTime.now().subtract(Duration(days: 365))) &&
              element.date!.isBefore(
                  widget.lastDate ?? DateTime.now().add(Duration(days: 120)));
        })
        .map((e) => ChartData(
            x: DateTime(e.date!.year, e.date!.month, e.date!.day),
            y: e.stepsTaken! / 1000))
        .toList();
    // bulk edit //print(chartData);

    return <ColumnSeries<ChartData, DateTime>>[
      ColumnSeries<ChartData, DateTime>(
        dataSource: chartData,
        opacity: 0.7,
        name: 'Step',
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.y,
      )
    ];
  }

  /// Returns the default cartesian area chart.
  SfCartesianChart _getDefaultAreaChart() {
    return SfCartesianChart(
      axes: [],
      title: ChartTitle(text: 'Steps'),
      plotAreaBorderWidth: 0,
      primaryXAxis: DateTimeAxis(
          isVisible: true,
          dateFormat: DateFormat.MMMd(),
          interval: 1,
          labelFormat: '',
          crossesAt: 0,
          intervalType: DateTimeIntervalType.days,
          majorGridLines: MajorGridLines(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.none),
      primaryYAxis: NumericAxis(
          minimum: 0,
          labelFormat: '{value}k',
          interval: 1,
          crossesAt: 0,
          isVisible: true,
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
