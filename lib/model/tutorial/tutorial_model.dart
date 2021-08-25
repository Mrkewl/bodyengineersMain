import 'package:flutter/material.dart';
import 'dart:async';

import '../../services/index.dart';
import './tutorial.dart';

class TutorialModel with ChangeNotifier {
  final Services _service = Services();
  List<Tutorial> tutorialList = [];

  Future<void> getTutorialList() async {
    if (tutorialList.isEmpty) {
      Map<String, dynamic> resultTutorial = await _service.phpGetTutorialList();
      // bulk edit //print(resultTutorial);
      // bulk edit //print('******Result Tutorial******');
      if (resultTutorial['result']) {
        for (var item in resultTutorial['data']) {
          tutorialList.add(Tutorial.fromMysqlDatabase(item));
          notifyListeners();
        }
      }
    }
  }
}
