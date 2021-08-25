import 'package:bodyengineer/model/planner/bodystatsDay.dart';

import '../../../../model/planner/measurement.dart';
import '../../../../model/planner/planner_model.dart';
import '../../../../screen/health_stats/widget/chart_data.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../../../translations.dart';

class BodyWeightDetailChart extends StatefulWidget {
  DateTime? firstDate;
  DateTime? lastDate;
  BodyWeightDetailChart({this.firstDate, this.lastDate});
  @override
  _BodyWeightDetailChartState createState() => _BodyWeightDetailChartState();
}

class _BodyWeightDetailChartState extends State<BodyWeightDetailChart> {
  List<ColumnSeries<ChartData, DateTime>> _getDefaultAreaSeries() {
    List<Measurement> bodyfatMeasurements = [];
    List<BodystatsDay?> bodystatsDayList =
        Provider.of<PlannerModel>(context, listen: true).bodystatsDayList;
    List<List<Measurement>> tempBodyfatMeasurements = bodystatsDayList
        .where((element) {
          return element!.dateTime!.isAfter(widget.firstDate ??
                  DateTime.now().subtract(Duration(days: 365))) &&
              element.dateTime!.isBefore(
                  widget.lastDate ?? DateTime.now().add(Duration(days: 120)));
        })
        .map((e) => e!.measurements
                .where((element) => element.name == 'Body Weight')
                .map((e2) {
              e2.dateTime = e.dateTime;
              return e2;
            }).toList())
        .toList();
    if (tempBodyfatMeasurements.isNotEmpty)
      bodyfatMeasurements = tempBodyfatMeasurements.reduce((a, b) {
        a.addAll(b);
        return a;
      });

    List<ChartData> chartData = [];
    if (bodyfatMeasurements.isNotEmpty) {
      bodyfatMeasurements.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
      chartData = bodyfatMeasurements
          .map((e) => ChartData(
              x: DateTime(e.dateTime!.year, e.dateTime!.month, e.dateTime!.day),
              y: e.value))
          .toList();
    }

    // bulk edit //print(chartData);

    return <ColumnSeries<ChartData, DateTime>>[
      ColumnSeries<ChartData, DateTime>(
        dataSource: chartData,
        opacity: 0.7,
        name: allTranslations.text('bodyweight')!,
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
        text: allTranslations.text('bodyweight')!,
      ),
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
