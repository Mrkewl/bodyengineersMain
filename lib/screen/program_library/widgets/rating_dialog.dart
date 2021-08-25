import 'package:flutter/material.dart';

// ignore: must_be_immutable
class RatingDialog extends StatefulWidget {
  int? userStars;
  RatingDialog({this.userStars});
  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  // int widget.userStars = 0;

  Widget _buildStar(int starCount) {
    return InkWell(
      child: Icon(
        Icons.star,
        color: widget.userStars! >= starCount ? Colors.orange : Colors.grey,
      ),
      onTap: () {
        setState(() {
          widget.userStars = starCount;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      title: Text('Rate It!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildStar(1),
              _buildStar(2),
              _buildStar(3),
              _buildStar(4),
              _buildStar(5),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Please Share How You Feel About This Program For The Creator And Users',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: Navigator.of(context).pop,
        ),
        TextButton(
          child: Text('Rate'),
          onPressed: () {
            Navigator.of(context).pop(widget.userStars);
          },
        )
      ],
    );
  }
}
