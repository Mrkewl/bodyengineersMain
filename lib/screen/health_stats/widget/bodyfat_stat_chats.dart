import '../../../model/planner/measurement.dart';
import '../../../model/planner/planner_model.dart';
import '../../../screen/health_stats/widget/chart_data.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../../translations.dart';

class BodyFatCharts extends StatefulWidget {
  @override
  _BodyFatChartsState createState() => _BodyFatChartsState();
}

class _BodyFatChartsState extends State<BodyFatCharts> {
  List<Measurement> bodyfatMeasurements = [];

  List<AreaSeries<ChartData, DateTime>> _getDefaultAreaSeries() {
    final List<ChartData> chartData = bodyfatMeasurements
        .map((e) => ChartData(
            x: DateTime(e.dateTime!.year, e.dateTime!.month, e.dateTime!.day),
            y: e.value))
        .toList();
    // bulk edit //print(chartData);

    return <AreaSeries<ChartData, DateTime>>[
      AreaSeries<ChartData, DateTime>(
        dataSource: chartData,
        opacity: 0.7,
        name: 'Bodyfat',
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.y,
      )
    ];
  }

  /// Returns the default cartesian area chart.
  SfCartesianChart _getDefaultAreaChart() {
    ChartTitle chartTitle;
    if (bodyfatMeasurements.isNotEmpty &&
        bodyfatMeasurements.last.value != null &&
        bodyfatMeasurements.last.value != 0) {
      chartTitle = ChartTitle(
        text: allTranslations.text('bodyfat')! +
            '\n' +
            bodyfatMeasurements.last.value.toString() +
            '%',
        textStyle: TextStyle(fontFamily: 'Lato', fontSize: 15),
      );
    } else {
      chartTitle = ChartTitle(
        text: allTranslations.text('bodyfat')!,
        textStyle: TextStyle(fontFamily: 'Lato', fontSize: 15),
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
      onPointTapped: (arg) {
        Navigator.pushNamed(context, '/bodyfat');
      },
      tooltipBehavior: TooltipBehavior(enable: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    bodyfatMeasurements = Provider.of<PlannerModel>(context, listen: true)
        .bodystatsDayList
        .map((e) => e!.measurements
                .where((element) => element.name == 'Body Fat')
                .map((e2) {
              e2.dateTime = e.dateTime;
              return e2;
            }).toList())
        .toList()
        .reduce((a, b) {
      a.addAll(b);
      return a;
    });

    bodyfatMeasurements.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
    return _getDefaultAreaChart();
  }
}
