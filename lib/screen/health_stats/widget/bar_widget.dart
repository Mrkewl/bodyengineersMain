import 'package:flutter/material.dart';

class BarStatWidget extends StatefulWidget {
  int? data1;
  int? data2;
  BarStatWidget({this.data1, this.data2});
  @override
  _BarStatWidgetState createState() => _BarStatWidgetState();
}

class _BarStatWidgetState extends State<BarStatWidget> {
  @override
  Widget build(BuildContext context) {
    return ChartLine(
        title: widget.data1.toString() + '/' + widget.data2.toString() + ' pts',
        rate: widget.data1! / widget.data2!);
  }

  Widget _title(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 18),
      ),
    );
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              constraints: BoxConstraints(minWidth: lineWidget),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromRGBO(86, 177, 191, 1),
                  ),
                  width: constraints.maxWidth,
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromRGBO(8, 112, 138, 1),
                  ),
                  height: 20,
                  width: lineWidget,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
