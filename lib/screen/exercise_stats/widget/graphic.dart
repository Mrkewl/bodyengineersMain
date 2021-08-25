import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExerciseGraphic extends StatefulWidget {
  List<Map<DateTime?, dynamic>> result;
  ExerciseGraphic(this.result);
  @override
  _ExerciseGraphicState createState() => _ExerciseGraphicState();
}

class _ExerciseGraphicState extends State<ExerciseGraphic> {
  List<ChartData> dataList = [];
  @override
  void initState() {
    // bulk edit //print('__________BUİLD EXERCISE GRAPH ===>' +DateTime.now().second.toString() +':' +DateTime.now().minute.toString());
    super.initState();
  }

  void refreshChart() {
    setState(() {});
  }

  List<LineSeries<ChartData, String>> _buildSeries() {
    setState(() {
      dataList = widget.result.map((e) => ChartData.fromMap(e)).toList();
    });
    return <LineSeries<ChartData, String>>[
      LineSeries<ChartData, String>(
          dataSource: dataList,
          name: 'Exercise Stats',
          xValueMapper: (ChartData sales, _) => sales.year,
          yValueMapper: (ChartData sales, _) => sales.sales,
          // Enable data label
          dataLabelSettings: DataLabelSettings(isVisible: true))
    ];
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
  String? year;
  dynamic sales;
  ChartData({this.sales, this.year});

  ChartData.fromMap(Map<DateTime?, dynamic> map) {
    // bulk edit //print(map);
    year =
        map.keys.first!.day.toString() + '/' + map.keys.first!.month.toString();
    sales = map.values.first;
  }
}
