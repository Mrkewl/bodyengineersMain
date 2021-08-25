import 'package:flutter/material.dart';

class BWFProgressBar extends StatefulWidget {
  int? data1;
  int? data2;
  bool? isLoose;
  BWFProgressBar({this.data1, this.data2, this.isLoose});
  @override
  _BWFProgressBarState createState() => _BWFProgressBarState();
}

class _BWFProgressBarState extends State<BWFProgressBar> {
  @override
  Widget build(BuildContext context) {
    return ChartLine(
        title: widget.data2.toString() + '/' + widget.data1.toString(),
        rate: widget.isLoose!
            ? widget.data1! / widget.data2!
            : widget.data2! / widget.data1!);
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
        assert(rate > 0),
        assert(rate <= 1),
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
              alignment: Alignment.centerRight,
              constraints: BoxConstraints(minWidth: lineWidget),
              child: Text(title),
            ),
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromRGBO(86, 177, 191, 1),
                  ),
                  width: constraints.maxWidth,
                  height: 15,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color.fromRGBO(8, 112, 138, 1),
                  ),
                  height: 15,
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
