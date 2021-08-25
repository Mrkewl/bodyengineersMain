import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TestStatChart extends StatefulWidget {
  @override
  _TestStatChartState createState() => _TestStatChartState();
}

class _TestStatChartState extends State<TestStatChart> {
  /// Returns the range pointer gauge
  SfRadialGauge _getRangePointerExampleGauge() {
    return SfRadialGauge(
      title: GaugeTitle(text: 'Calories', textStyle: TextStyle(fontSize: 17)),
      axes: <RadialAxis>[
        RadialAxis(
            showLabels: false,
            showTicks: false,
            startAngle: 270,
            endAngle: 270,
            minimum: 0,
            maximum: 100,
            radiusFactor: 0.8,
            axisLineStyle: AxisLineStyle(
                thicknessUnit: GaugeSizeUnit.factor, thickness: 0.15),
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                  angle: 180,
                  widget: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        child: Text(
                          '50',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          ' / 100',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                    ],
                  )),
            ],
            pointers: <GaugePointer>[
              RangePointer(
                  value: 50,
                  enableAnimation: true,
                  animationDuration: 1200,
                  animationType: AnimationType.ease,
                  sizeUnit: GaugeSizeUnit.factor,
                  // Sweep gradient not supported in web
                  gradient: const SweepGradient(
                      colors: <Color>[Color(0xFF6A6EF6), Color(0xFFDB82F5)],
                      stops: <double>[0.25, 0.75]),
                  color: const Color(0xFF00A8B5),
                  width: 0.15),
            ]),
      ],
    );
  }

  SfCartesianChart _getAxisCrossingBaseValueSample() {
    return SfCartesianChart(
      margin: EdgeInsets.fromLTRB(10, 10, 15, 10),
      plotAreaBorderWidth: 0,
      title: ChartTitle(text: 'Population growth rate of countries'),
      primaryXAxis: CategoryAxis(
          labelPlacement: LabelPlacement.onTicks,
          majorGridLines: MajorGridLines(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.none,
          labelIntersectAction: AxisLabelIntersectAction.rotate45,
          crossesAt: 0,
          placeLabelsNearAxisLine: false),
      primaryYAxis: NumericAxis(
          axisLine: AxisLine(width: 0),
          minimum: -2,
          maximum: 3,
          majorTickLines: MajorTickLines(size: 0)),
      series: _getSeries(),
      tooltipBehavior:
          TooltipBehavior(enable: true, header: '', canShowMarker: false),
    );
  }

  /// Returns the list of chart series which need to render on
  /// the bar or column chart with axis crossing.

  List<ChartSeries<ChartSampleData, String>> _getSeries() {
    List<ChartSeries<ChartSampleData, String>>? chart = null;
    final List<ChartSampleData> chartData = <ChartSampleData>[
      ChartSampleData(x: 'Iceland', y: 1.13),
      ChartSampleData(x: 'Algeria', y: 1.7),
      ChartSampleData(x: 'Singapore', y: 1.82),
      ChartSampleData(x: 'Malaysia', y: 1.37),
      ChartSampleData(x: 'Moldova', y: -1.05),
      ChartSampleData(x: 'American Samoa', y: -1.3),
      ChartSampleData(x: 'Latvia', y: -1.1)
    ];
    chart = <ChartSeries<ChartSampleData, String>>[
      AreaSeries<ChartSampleData, String>(
          color: const Color.fromRGBO(75, 135, 185, 0.6),
          borderColor: const Color.fromRGBO(75, 135, 185, 1),
          borderWidth: 2,
          dataSource: chartData,
          xValueMapper: (ChartSampleData sales, _) => sales.x,
          yValueMapper: (ChartSampleData sales, _) => sales.y,
          markerSettings: MarkerSettings(isVisible: true)),
    ];
    return chart;
  }

  // /// Returns the default cartesian area chart.
  // SfCartesianChart _getDefaultAreaChart() {
  //   return SfCartesianChart(
  //     axes: [],
  //     title: ChartTitle(text: 'Steps'),
  //     plotAreaBorderWidth: 0,
  //     primaryXAxis: DateTimeAxis(
  //         isVisible: false,
  //         dateFormat: DateFormat.yMMMd(),
  //         interval: 1,
  //         labelFormat: '',
  //         intervalType: DateTimeIntervalType.years,
  //         majorGridLines: MajorGridLines(width: 0),
  //         edgeLabelPlacement: EdgeLabelPlacement.none),
  //     primaryYAxis: NumericAxis(
  //         minimum: 0,
  //         labelFormat: '',
  //         interval: 1,
  //         isVisible: false,
  //         axisLine: AxisLine(width: 0),
  //         majorTickLines: MajorTickLines(size: 0)),
  //     series: _getDefaultAreaSeries(),
  //     tooltipBehavior: TooltipBehavior(enable: true),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return _getRangePointerExampleGauge();
  }
}

///Chart sample data
class ChartSampleData {
  /// Holds the datapoint values like x, y, etc.,
  ChartSampleData(
      {this.x,
      this.y,
      this.xValue,
      this.yValue,
      this.secondSeriesYValue,
      this.thirdSeriesYValue,
      this.pointColor,
      this.size,
      this.text,
      this.open,
      this.close,
      this.low,
      this.high,
      this.volume});

  /// Holds x value of the datapoint
  final dynamic x;

  /// Holds y value of the datapoint
  final num? y;

  /// Holds x value of the datapoint
  final dynamic xValue;

  /// Holds y value of the datapoint
  final num? yValue;

  /// Holds y value of the datapoint(for 2nd series)
  final num? secondSeriesYValue;

  /// Holds y value of the datapoint(for 3nd series)
  final num? thirdSeriesYValue;

  /// Holds point color of the datapoint
  final Color? pointColor;

  /// Holds size of the datapoint
  final num? size;

  /// Holds datalabel/text value mapper of the datapoint
  final String? text;

  /// Holds open value of the datapoint
  final num? open;

  /// Holds close value of the datapoint
  final num? close;

  /// Holds low value of the datapoint
  final num? low;

  /// Holds high value of the datapoint
  final num? high;

  /// Holds open value of the datapoint
  final num? volume;
}
