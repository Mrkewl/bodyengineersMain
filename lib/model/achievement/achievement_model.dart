import '../../helper/json_helper.dart';
import '../../model/achievement/achievement.dart';
import '../../model/achievement/achievement_category.dart';
import '../../services/index.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AchievementModel with ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Services _service = Services();

  List<Achievement>? achievementList;
  List<AchievementCategory>? achievementCategoryList;
  List<Achievement> userAchievementList = [];

  AchievementModel() {
    appInit();
  }

   appInit() {
    if (achievementCategoryList == null) getAchievementCategoryList();
    if (achievementList == null) getAchievementList();
    getUserAchievements();
  }

  Future<void> logOut() async {
    userAchievementList = [];
    notifyListeners();
  }

  saveAchievementToDatabase(Achievement achievement) async {
    List<String?> userAchievementListId =
        await _service.phpAddAchievement(achievement);
    userAchievementList = achievementList!
        .where(
            (element) => userAchievementListId.contains(element.id.toString()))
        .toList();
    notifyListeners();
  }

  getUserAchievements() async {
    List<String?> userAchievementListId = await _service.phpGetAchievements();
    userAchievementList = achievementList!
        .where(
            (element) => userAchievementListId.contains(element.id.toString()))
        .toList();
    achievementList!.forEach((element) {
      if (userAchievementList.contains(element)) {
        element.isCompleted = true;
      }
    });
    notifyListeners();
  }

  Achievement checkAchievement(Map<String, dynamic> data) {
    Achievement achievement = Achievement();
    achievemenntCallback(Achievement achievementCalledBack) {
      // bulk edit //print(achievementCalledBack);
      achievement = achievementCalledBack;
      if (userAchievementList
          .where((element) => element.id == achievement.id)
          .isEmpty) {
        achievement.isCompleted = true;
        userAchievementList.add(achievement);
        saveAchievementToDatabase(achievement);
      }

      notifyListeners();
    }

    /** Example of Data */
    // Map<String, dynamic> data = {'km': 20, 'duration': 100};

    // Map<String, dynamic> data = {'km': 20};
    // Map<String, dynamic> data = {'old_bodyfat': 20, 'new_bodyfat': 19};
    // Map<String, dynamic> data = {'squat_weight': 125, 'current_weight': 125};
    // Map<String, dynamic> data = {'squat_weight': 125, 'current_weight': 125};
    // Map<String, dynamic> data = {'deadlift_weight': 125, 'current_weight': 125};
    // Map<String, dynamic> data = {'bench_press_weight': 125, 'current_weight': 125 };
    // Map<String, dynamic> data = {'total_workout_number': 125};
    /** Example of Data */

    achievementList!.where((e) => !e.isCompleted).forEach((element) {
      element.checkCompleted(data, achievemenntCallback);
    });
    return achievement;
  }

  getAchievementCategoryList() async {
    achievementCategoryList = [];
    List<Map<String, dynamic>> achievementCategory = [
      {'category_name': 'Workout Count', 'category_id': 1},
      {'category_name': 'Program Count', 'category_id': 2},
      {'category_name': 'Workout Count - For a week', 'category_id': 3},
      {'category_name': 'Bench Press', 'category_id': 4},
      {'category_name': 'Deadlift', 'category_id': 5},
      {'category_name': 'Squat', 'category_id': 6},
      {'category_name': 'Bodyweight Loose Weight', 'category_id': 7},
      {'category_name': 'Bodyweight Gain Weight', 'category_id': 8},
      {'category_name': 'BodyFat', 'category_id': 9},
      {'category_name': 'BodyFat Loss', 'category_id': 10},
      {'category_name': 'Run Time', 'category_id': 11},
      {'category_name': 'Run', 'category_id': 12},
    ];
    achievementCategory.forEach((element) {
      achievementCategoryList!.add(AchievementCategory.fromLocalJson(element));
    });
  }

  getAchievementList() async {
    achievementList = [];
    achievementList = await JsonHelper().getAchievements();
    achievementList!.forEach((element) {
      int? categoryId = achievementCategoryList!
          .where((e) => e.name == element.category)
          .first
          .id;
      element.setCategory(categoryId);
    });
    // bulk edit //print(achievementList);
  }

  setCompletedFunctions() {
    achievementList!.forEach((element) {});
  }
}
