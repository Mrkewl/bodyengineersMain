import 'package:bodyengineer/model/watch/watch_data.dart';
import 'package:bodyengineer/translations.dart';

import '../../../model/watch/garmin.dart';
import '../../../model/watch/watch_model.dart';
import '../../../screen/health_stats/widget/chart_data.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SleepStatCharts extends StatefulWidget {
  @override
  _SleepStatChartsState createState() => _SleepStatChartsState();
}

class _SleepStatChartsState extends State<SleepStatCharts> {
  List<WatchDataObject> watchDataList = [];

  List<AreaSeries<ChartData, DateTime>> _getDefaultAreaSeries() {
    // bulk edit //print(garminList);
    watchDataList.sort((a, b) => a.date!.compareTo(b.date!));
    final List<ChartData> chartData = watchDataList
        .map((e) => ChartData(
            x: DateTime(e.date!.year, e.date!.month, e.date!.day),
            y: e.sleep!.totalSleepTime!.inHours))
        .toList();
    // bulk edit //print(chartData);

    return <AreaSeries<ChartData, DateTime>>[
      AreaSeries<ChartData, DateTime>(
        dataSource: chartData,
        opacity: 0.7,
        name: 'Sleep',
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.y,
      )
    ];
  }

  SfRadialGauge _getRangePointerExampleGauge() {
    watchDataList = Provider.of<WatchModel>(context, listen: true)
        .watchDataList!
        .where((element) =>
            element.sleep != null && element.sleep!.totalSleepTime != null)
        .toList();
    List<Duration?> sleepDurationList = [];
    sleepDurationList =
        watchDataList.map((e) => e.sleep!.totalSleepTime).toList();

    return SfRadialGauge(
      title: GaugeTitle(
        text: allTranslations.text('sleep')!,
        textStyle: TextStyle(fontFamily: 'Lato', fontSize: 18),
      ),
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
                      if (sleepDurationList.isNotEmpty)
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Text(
                              (sleepDurationList
                                              .reduce((a, b) => a! + b!)!
                                              .inHours /
                                          sleepDurationList.length)
                                      .toStringAsFixed(1) +
                                  '\nHours',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        )
                    ],
                  )),
            ],
            pointers: <GaugePointer>[
              if (sleepDurationList.isNotEmpty)
                RangePointer(
                    value: 100 *
                        ((sleepDurationList.reduce((a, b) => a! + b!)!.inHours /
                                sleepDurationList.length) /
                            24),
                    enableAnimation: true,
                    animationDuration: 1200,
                    animationType: AnimationType.ease,
                    sizeUnit: GaugeSizeUnit.factor,
                    // Sweep gradient not supported in web
                    gradient: const SweepGradient(
                        colors: <Color>[Color(0xFF56b1bf), Color(0xFF08708a)],
                        stops: <double>[0.25, 0.75]),
                    color: const Color(0xFF08708a),
                    width: 0.15),
            ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getRangePointerExampleGauge();
  }
}
