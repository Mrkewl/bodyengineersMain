import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExerciseMultilineGraphic extends StatefulWidget {
  List<Map<int?, List<Map<DateTime?, dynamic>>>> result;
  ExerciseMultilineGraphic(this.result);
  @override
  _ExerciseMultilineGraphicState createState() =>
      _ExerciseMultilineGraphicState();
}

class _ExerciseMultilineGraphicState extends State<ExerciseMultilineGraphic> {
  List<List<ChartData>> dataList = [];
  @override
  void initState() {
    // bulk edit //print('__________BUİLD EXERCISE GRAPH ===>' +DateTime.now().second.toString() +':' +DateTime.now().minute.toString());
    super.initState();
  }

  void refreshChart() {
    setState(() {});
  }

  List<LineSeries<ChartData, DateTime>> _buildSeries() {
    setState(() {
      widget.result.forEach((element) {
        element.forEach((key, value) {
          List<ChartData> chartList = [];
          value.forEach((e) {
            if ([1, 3, 5, 10].contains(key)) {
              if (chartList
                  .where((chr) => chr.dateTime == e.keys.first)
                  .isEmpty) {
                chartList.add(ChartData.fromMap(key, e as Map<DateTime?, double?>));
              } else {
                if (chartList
                        .where((chr) => chr.dateTime == e.keys.first)
                        .first
                        .weight! <
                    e.values.first) {
                  chartList.removeWhere((chr) => chr.dateTime == e.keys.first);
                  chartList.add(ChartData.fromMap(key, e as Map<DateTime?, double?>));
                }
              }
            }
          });
          dataList.add(chartList);
        });
      });
    });

    List<LineSeries<ChartData, DateTime>> list = [];

    dataList.forEach((element) {
      LineSeries<ChartData, DateTime> line = LineSeries<ChartData, DateTime>(
        dataSource: element,
        markerSettings: MarkerSettings(isVisible: true),
        enableTooltip: true,
        name: 'Exercise Stats',
        pointColorMapper: (ChartData val, _) => val.color,
        xValueMapper: (ChartData val, _) => val.dateTime,
        yValueMapper: (ChartData val, _) => val.weight,
      );
      list.add(line);
    });

    return list;
  }

  Widget _buildChart() {
    return SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        // Chart title
        title: ChartTitle(text: ''),
        // Enable legend
        legend: Legend(isVisible: false),
        // Enable tooltip
        tooltipBehavior: TooltipBehavior(enable: true),
        series: _buildSeries());
  }

  @override
  Widget build(BuildContext context) {
    return _buildChart();
  }
}

class ChartData {
  DateTime? dateTime;
  double? weight;
  int? rep;
  Color? color;
  ChartData({this.weight, this.dateTime, this.rep});

  ChartData.fromMap(int? key, Map<DateTime?, double?> map) {
    // bulk edit //print(map);
    dateTime = map.keys.first;
    weight = map.values.first;
    rep = key;
    switch (rep) {
      case 1:
        color = Colors.red;
        break;
      case 3:
        color = Colors.blue;
        break;
      case 5:
        color = Colors.yellow;
        break;
      case 10:
        color = Colors.green;
        break;
      default:
        color = Colors.blue;
    }
  }
}
