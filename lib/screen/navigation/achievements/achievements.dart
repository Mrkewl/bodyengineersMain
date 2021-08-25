import '../../../model/achievement/achievement.dart';
import '../../../model/achievement/achievement_model.dart';
import '../../../model/user/user.dart';
import '../../../model/user/user_model.dart';
import '../../../screen/common_appbar.dart';
import '../../../screen/common_drawer.dart';
import '../../../screen/navigation/achievements/widget/achievement_element.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AchievementsScreen extends StatelessWidget {
  GlobalKey<ScaffoldState> _key = GlobalKey();

  UserObject? user;
  List<Achievement>? achievementList = [];
  List<Achievement> completedAchievementList = [];
  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context, listen: true).user;
    completedAchievementList =
        Provider.of<AchievementModel>(context, listen: true)
            .achievementList!
            .where((element) => element.isCompleted)
            .toList();
    achievementList =
        Provider.of<AchievementModel>(context, listen: true).achievementList;
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Unlocked Achievements',
                style: TextStyle(fontSize: 18),
              ),
            ),
            if (completedAchievementList.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: GridView.builder(
                    itemCount: completedAchievementList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) {
                      return AchievementElement(
                        achievement: completedAchievementList[index],
                        isCompleted: true,
                      );
                    }),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                'Locked Achievements',
                style: TextStyle(fontSize: 18),
              ),
            ),
            if (achievementList!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: GridView.builder(
                    itemCount: achievementList!.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) {
                      return AchievementElement(
                        achievement: achievementList![index],
                        isCompleted: false,
                      );
                    }),
              ),
          ],
        ),
      ),
    );
  }
}
