import 'package:flutter/material.dart';

class GoalProgressBarWidget extends StatefulWidget {
  double? data1;
  double? data2;
  GoalProgressBarWidget({this.data1, this.data2});
  @override
  _GoalProgressBarWidgetState createState() => _GoalProgressBarWidgetState();
}

class _GoalProgressBarWidgetState extends State<GoalProgressBarWidget> {
  @override
  Widget build(BuildContext context) {
    return ChartLine(
        title: widget.data1.toString() + '/' + widget.data2.toString() + ' pts',
        rate: widget.data1! / widget.data2!);
  }
}

class ChartLine extends StatelessWidget {
  const ChartLine({
    Key? key,
    required this.rate,
    required this.title,
    this.number,
  })  : assert(title != null),
        assert(rate != null),
        // assert(rate > 0),
        // assert(rate <= 1),
        super(key: key);

  final double rate;
  final String title;
  final int? number;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final lineWidget = constraints.maxWidth * rate;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color.fromRGBO(86, 177, 191, 1),
              ),
              width: constraints.maxWidth,
              height: 12,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color.fromRGBO(8, 112, 138, 1),
              ),
              height: 12,
              width: lineWidget,
            ),
          ],
        ),
      );
    });
  }
}
