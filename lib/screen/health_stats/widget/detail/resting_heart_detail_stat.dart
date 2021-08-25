import 'package:bodyengineer/model/watch/watch_data.dart';

import '../../../../model/watch/garmin.dart';
import '../../../../model/watch/watch_model.dart';
import '../../../../screen/health_stats/widget/chart_data.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../../../translations.dart';

class RestingHearthDetailChart extends StatefulWidget {
  DateTime? firstDate;
  DateTime? lastDate;
  RestingHearthDetailChart({this.firstDate, this.lastDate});
  @override
  _RestingHearthDetailChartState createState() =>
      _RestingHearthDetailChartState();
}

class _RestingHearthDetailChartState extends State<RestingHearthDetailChart> {
  List<ColumnSeries<ChartData, DateTime>> _getDefaultAreaSeries() {
    List<WatchDataObject> watchDataList =
        Provider.of<WatchModel>(context, listen: true).watchDataList!;
    // bulk edit //print(garminList);
    watchDataList.sort((a, b) => a.date!.compareTo(b.date!));
    final List<ChartData> chartData = watchDataList
        .where((element) {
          return element.date!.isAfter(widget.firstDate ??
                  DateTime.now().subtract(Duration(days: 365))) &&
              element.date!.isBefore(
                  widget.lastDate ?? DateTime.now().add(Duration(days: 120)));
        })
        .map((e) => ChartData(
            x: DateTime(e.date!.year, e.date!.month, e.date!.day),
            y: e.restingHeartRate))
        .toList();
    // bulk edit //print(chartData);

    return <ColumnSeries<ChartData, DateTime>>[
      ColumnSeries<ChartData, DateTime>(
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
    return SfCartesianChart(
      axes: [],
      title: ChartTitle(text: allTranslations.text('resting_heart_rate')!),
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
          labelFormat: '',
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
