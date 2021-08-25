import '../../../model/achievement/achievement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AchievementModalContent extends StatelessWidget {
  Achievement? achievement;
  AchievementModalContent({this.achievement});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(achievement!.name!),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 100,
              height: 100,
              child: SvgPicture.asset(achievement!.image!)),
          SizedBox(height: 20),
          Text(
            achievement!.description!,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [],
    );
  }
}
