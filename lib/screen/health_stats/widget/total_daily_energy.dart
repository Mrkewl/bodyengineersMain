import '../../../model/planner/measurement.dart';
import '../../../model/planner/planner_model.dart';
import '../../../model/program/programDay.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../../screen/health_stats/widget/chart_data.dart';
import '../../../translations.dart';

class TotalDailyEnergyTable extends StatefulWidget {
  @override
  _TotalDailyEnergyTableState createState() => _TotalDailyEnergyTableState();
}

class _TotalDailyEnergyTableState extends State<TotalDailyEnergyTable> {
  List<Measurement>? bodyWeightMeasurements;
  List<Measurement>? bodyfatMeasurements;
  List<ProgramDay>? programDayList;
  List<Map<DateTime?, double>> dailyResult = [];

  List<AreaSeries<ChartData, DateTime>> _getDefaultAreaSeries() {
    final List<ChartData> chartData = dailyResult
        .map((e) => ChartData(
            x: DateTime(
                e.keys.first!.year, e.keys.first!.month, e.keys.first!.day),
            y: e.values.first))
        .toList();
    // bulk edit //print(chartData);

    return <AreaSeries<ChartData, DateTime>>[
      AreaSeries<ChartData, DateTime>(
        dataSource: chartData,
        opacity: 0.7,
        name: 'Total Daily Energy Expenditure',
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.y,
      )
    ];
  }

  /// Returns the default cartesian area chart.
  SfCartesianChart _getDefaultAreaChart() {
    ChartTitle chartTitle;
    if (dailyResult.isNotEmpty) {
      chartTitle = ChartTitle(
        text: allTranslations.text('total_daily_expenditure')! +
            '\n' +
            dailyResult.last.values.last.toInt().toString(),
        textStyle: TextStyle(fontFamily: 'Lato', fontSize: 16),
      );
    } else {
      chartTitle = ChartTitle(
        text: allTranslations.text('total_daily_expenditure')! + ' ',
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
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  String? calculateTotalDaily() {
    dailyResult = [];
    if (bodyWeightMeasurements!.isNotEmpty) {
      bodyWeightMeasurements!.forEach((bodyWeight) {
        double result = 0.0;
        double bmr;
        double activityFactor;
        double? lastBodyWeight;
        double? lastBodyFat;
        List<ProgramDay> functionDays = [];
        if (programDayList!.isNotEmpty) {
          functionDays = programDayList!
              .where((element) => element.dateTime!
                  .isAfter(bodyWeight.dateTime!.subtract(Duration(days: 7))))
              .toList();
        }
        lastBodyWeight = bodyWeight.value;

        if (functionDays.length == 0) {
          activityFactor = 1;
        } else if (functionDays.length > 0 && functionDays.length <= 2) {
          activityFactor = 1.1;
        } else if (functionDays.length > 2 && functionDays.length <= 4) {
          activityFactor = 1.3;
        } else {
          activityFactor = 1.5;
        }

        if (bodyfatMeasurements!.isNotEmpty) {
          if (bodyfatMeasurements!
              .where((el) =>
                  el.dateTime!.difference(bodyWeight.dateTime!).inHours < 25)
              .isNotEmpty) {
            lastBodyFat = bodyfatMeasurements!
                .where((el) =>
                    el.dateTime!.difference(bodyWeight.dateTime!).inHours < 25)
                .last
                .value;
            bmr = 500 + (lastBodyWeight! * ((100 - lastBodyFat!) / 100) * 22);
          } else {
            bmr = lastBodyWeight! * 24;
          }
        } else {
          bmr = lastBodyWeight! * 24;
        }

        if (activityFactor != null && bmr != null) {
          result = (activityFactor * bmr);
          setState(() {
            dailyResult.add({bodyWeight.dateTime: result});
          });
        }
      });
      if (dailyResult.isNotEmpty) {
        dailyResult.sort((a, b) => a.keys.first!.compareTo(b.keys.first!));
      }
      // bulk edit //print(dailyResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    programDayList = Provider.of<PlannerModel>(context, listen: true)
        .programDayList
        .where((element) => element.isDayCompleted)
        .toList();
    bodyWeightMeasurements = Provider.of<PlannerModel>(context, listen: true)
        .bodystatsDayList
        .map((e) => e!.measurements
                .where((element) => element.name == 'Body Weight')
                .map((e2) {
              e2.dateTime = e.dateTime;
              return e2;
            }).toList())
        .toList()
        .reduce((a, b) {
      a.addAll(b);
      return a;
    });
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
    if (programDayList != null &&
        bodyWeightMeasurements != null &&
        bodyfatMeasurements != null) {
      calculateTotalDaily();
    }

    return Container(
      child: dailyResult.isNotEmpty
          ? _getDefaultAreaChart()
          : Center(
              child: Text('No Data'),
            ),
    );
  }
}
