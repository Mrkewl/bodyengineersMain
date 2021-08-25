import '../../../../model/achievement/achievement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui' as ui;

class AchievementElement extends StatefulWidget {
  Achievement? achievement;
  bool? isCompleted;
  AchievementElement({this.achievement, this.isCompleted});

  @override
  _AchievementElementState createState() => _AchievementElementState();
}

class _AchievementElementState extends State<AchievementElement> {
  showDetailsDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Text(
              widget.isCompleted! ? 'Unlocked' : 'Locked',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            decoration: BoxDecoration(
              color: Color.fromRGBO(86, 177, 191, 1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          GestureDetector(
              onTap: () => Navigator.pop(context), child: Icon(Icons.close)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 15),
            width: 100,
            height: 100,
            child: SvgPicture.asset(
              widget.achievement!.image!,
              fit: BoxFit.cover,
            ),
          ),
          Text(widget.achievement!.name!),
          Divider(),
          Text(widget.achievement!.description!),
        ],
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDetailsDialog(context),
      child: Container(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(86, 177, 191, 1),
                ),
              ),
              Container(
                child: SvgPicture.asset(
                  widget.achievement!.image!,
                  width: 65,
                ),
              ),
              Visibility(
                visible: !widget.isCompleted!,
                child: Positioned.fill(
                    child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                  child: Container(
                      decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  )),
                )),
              ),
            ],
          ),
          Text(
            widget.achievement!.name!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
          )
        ],
      )),
    );
  }
}
