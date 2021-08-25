import 'dart:ui' as ui;
import 'dart:ui';
import '../../be_theme.dart';
import '../../model/achievement/achievement.dart';
import '../../model/program/program.dart';
import '../../model/program/program_model.dart';
import '../../screen/navigation/achievements/widget/achievement_element.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:provider/provider.dart';

import '../../model/user/user.dart';
import '../../model/user/user_stats.dart';
import '../../model/user/user_model.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class FriendProfile extends StatefulWidget {
  @override
  FriendProfileState createState() => FriendProfileState();
}

class FriendProfileState extends State<FriendProfile> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  List<Program> programList = [];
  List<UserObject> searchUser = [];
  List<UserObject> allUsers = [];
  List<Achievement>? completedAchievementList = [];

  @override
  void initState() {
    Provider.of<ProgramModel>(context, listen: false).getProgramList();

    // Provider.of<UserModel>(context, listen: false).getUserInfo();

    super.initState();
  }

  List exampleList = [
    'A',
    'A',
    'A',
    'A',
    'A',
    'A',
  ];

  ////////////////////////Functions about Find/Invite Friends Start////////////////////////////////////////

  bool isAll = true;
  UserObject? user;

  String searchFriend = '';

  ////////////////////////Functions about Find/Invite Friends End/////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    // bulk edit //print('*******************************' + exampleList.length.toString());
    allUsers = Provider.of<UserModel>(context, listen: true).allUserList;
    Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    Provider.of<UserModel>(context, listen: false)
        .getFriendUserStats(args['uid']);

    Provider.of<UserModel>(context, listen: false)
        .getFriendAchievement(args['uid']);

    Provider.of<UserModel>(context, listen: false)
        .getFriendPrograms(args['uid']);

    user = allUsers.where((element) => element.uid == args['uid']).first;
    completedAchievementList = user!.userAchievement;
    programList = Provider.of<ProgramModel>(context, listen: true).programList;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _key,
        drawer: buildProfileDrawer(context, user),
        appBar: setAppBar(_key) as PreferredSizeWidget?,
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Container(
            height: exampleList.length % 3 == 0
                ? MediaQuery.of(context).size.height * 0.6 +
                    (exampleList.length / 3) * 125 +
                    exampleList.length * 5
                : (exampleList.length + 1) % 3 == 0
                    ? MediaQuery.of(context).size.height * 0.6 +
                        ((exampleList.length + 1) / 3) * 125 +
                        exampleList.length * 5
                    : MediaQuery.of(context).size.height * 0.6 +
                        ((exampleList.length + 2) / 3) * 125 +
                        exampleList.length * 5,
            child: Column(
              children: <Widget>[
                Container(
                  color: Color.fromRGBO(86, 177, 191, 1),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.chevron_left,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        user!.fullname!,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 10,
                      )
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: (user!.avatar != '' && user!.avatar != null
                                  ? NetworkImage(user!.avatar!)
                                  : AssetImage(
                                      'assets/images/profile/profile_background.jpg'))
                              as ImageProvider<Object>,
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                          child: Container(
                            alignment: Alignment.center,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.25,
                                height:
                                    MediaQuery.of(context).size.height * 0.15,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Color.fromRGBO(8, 112, 138, 1),
                                    width: 3,
                                  ),
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.fromRGBO(255, 255, 255, 0)),
                                  child: user == null
                                      ? Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                        )
                                      : Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.2,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: (user!.avatar != '' &&
                                                          user!.avatar != null
                                                      ? NetworkImage(user!.avatar!)
                                                      : AssetImage(
                                                          'assets/images/onboarding/opening1.png'))
                                                  as ImageProvider<Object>,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                ),
                              ),
                              if (user != null)
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: Text(
                                          user!.fullname!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        user!.bio != '' && user!.bio != null
                                            ? user!.bio!
                                            : '',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                allTranslations
                                    .text('top_achievements')!
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Staatliches',
                                  fontSize: 18,
                                ),
                              ),
                              SizedBox(height: 10),
                              if (completedAchievementList != null &&
                                  completedAchievementList!.isNotEmpty)
                                Container(
                                  child: SvgPicture.asset(
                                    completedAchievementList!.last.image!,
                                    width: 50,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              if (completedAchievementList != null &&
                                  completedAchievementList!.length > 1)
                                Container(
                                  margin: EdgeInsets.only(top: 15),
                                  child: SvgPicture.asset(
                                    completedAchievementList![
                                            completedAchievementList!.length -
                                                2]
                                        .image!,
                                    width: 50,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              SizedBox(height: 15),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: SizedBox(
                    height: 60,
                    child: AppBar(
                      backgroundColor: Colors.white10,
                      elevation: 0,
                      bottom: TabBar(
                        indicatorColor: Color.fromRGBO(8, 112, 138, 1),
                        indicatorWeight: 4,
                        indicatorSize: TabBarIndicatorSize.tab,
                        tabs: [
                          Tab(
                            text: allTranslations.text('stats'),
                          ),
                          Tab(
                            text: allTranslations.text('achievements'),
                          ),
                          Tab(
                            text: allTranslations.text('program'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: TabBarView(
                    children: [
                      user!.userStats == null
                          ? Container()
                          : StatsContent(
                              userStat: user!.userStats,
                            ),
                      AchievementsContent(
                          completedAchievementList: user!.userAchievement),
                      TabContent(user!.userPrograms, programList),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class AchievementsContent extends StatelessWidget {
  List<Achievement>? completedAchievementList = [];
  AchievementsContent({this.completedAchievementList});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        elevation: 5,
        child: completedAchievementList == null
            ? Container()
            : GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(top: 10),
                itemCount: completedAchievementList!.length,
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  return AchievementElement(
                    achievement: completedAchievementList![index],
                    isCompleted: true,
                  );
                }),
      ),
    );
  }
}

// ignore: must_be_immutable
class TabContent extends StatelessWidget {
  late List<Program> userPrograms;
  List<Program> programList;
  List<String?>? userProgramIdLit;
  TabContent(this.userProgramIdLit, this.programList);
  Program? currentProgram;
  List<Program>? pastPrograms;
  @override
  Widget build(BuildContext context) {
    userPrograms = userProgramIdLit == null
        ? []
        : programList
            .where((element) => userProgramIdLit!
                .map((e) => e)
                .toList()
                .contains(element.programId))
            .toList();

    if (currentProgram == null && userPrograms.isNotEmpty)
      currentProgram = userPrograms.last;
    if (currentProgram != null)
      pastPrograms =
          userPrograms.where((element) => element != currentProgram).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 15),
          Text(
            'Current Program',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          currentProgram != null
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 1,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/program_overview',
                              arguments: {
                                'programId': currentProgram!.programId
                              });
                        },
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: currentProgram!.programImage!,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              placeholder: (context, url) => Container(
                                  alignment: Alignment.center,
                                  height:
                                      MediaQuery.of(context).size.height * 0.25,
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Positioned.fill(
                                child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                              child: Container(
                                  decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(15),
                              )),
                            )),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Duration:',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    currentProgram!.programDuration.toString() +
                                        ' Weeks',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  Provider.of<ProgramModel>(context,
                                          listen: false)
                                      .bookmarkProgram(
                                          currentProgram!.programId);
                                },
                                child: Icon(
                                  currentProgram!.isBookMarked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: currentProgram!.isBookMarked
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 30,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                child: Text(
                                  currentProgram!.programName!,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                                bottom: 10,
                                right: 10,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: currentProgram!.avgRate > 0
                                          ? Color.fromRGBO(86, 177, 191, 1)
                                          : Colors.grey,
                                      size: MediaQuery.of(context).size.width *
                                          0.04,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: currentProgram!.avgRate > 1
                                          ? Color.fromRGBO(86, 177, 191, 1)
                                          : Colors.grey,
                                      size: MediaQuery.of(context).size.width *
                                          0.04,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: currentProgram!.avgRate > 2
                                          ? Color.fromRGBO(86, 177, 191, 1)
                                          : Colors.grey,
                                      size: MediaQuery.of(context).size.width *
                                          0.04,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: currentProgram!.avgRate > 3
                                          ? Color.fromRGBO(86, 177, 191, 1)
                                          : Colors.grey,
                                      size: MediaQuery.of(context).size.width *
                                          0.04,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: currentProgram!.avgRate > 4
                                          ? Color.fromRGBO(86, 177, 191, 1)
                                          : Colors.grey,
                                      size: MediaQuery.of(context).size.width *
                                          0.04,
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : Center(child: Text('There is no current program.')),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text('Past Programs',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                )),
          ),
          pastPrograms != null
              ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: pastPrograms!.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/program_overview',
                              arguments: {
                                'programId': pastPrograms![index].programId
                              });
                        },
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: pastPrograms![index].programImage!,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                              placeholder: (context, url) => Container(
                                  alignment: Alignment.center,
                                  height:
                                      MediaQuery.of(context).size.height * 0.25,
                                  child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                            Positioned.fill(
                                child: BackdropFilter(
                              filter: ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                              child: Container(
                                  decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(15),
                              )),
                            )),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Duration:',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    pastPrograms![index]
                                            .programDuration
                                            .toString() +
                                        ' Weeks',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 17,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () {
                                  Provider.of<ProgramModel>(context,
                                          listen: false)
                                      .bookmarkProgram(
                                          pastPrograms![index].programId);
                                },
                                child: Icon(
                                  pastPrograms![index].isBookMarked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: pastPrograms![index].isBookMarked
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 30,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                child: Text(
                                  pastPrograms![index].programName!,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                                bottom: 10,
                                right: 10,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: pastPrograms![index].avgRate > 0
                                          ? Color.fromRGBO(86, 177, 191, 1)
                                          : Colors.grey,
                                      size: MediaQuery.of(context).size.width *
                                          0.04,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: pastPrograms![index].avgRate > 1
                                          ? Color.fromRGBO(86, 177, 191, 1)
                                          : Colors.grey,
                                      size: MediaQuery.of(context).size.width *
                                          0.04,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: pastPrograms![index].avgRate > 2
                                          ? Color.fromRGBO(86, 177, 191, 1)
                                          : Colors.grey,
                                      size: MediaQuery.of(context).size.width *
                                          0.04,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: pastPrograms![index].avgRate > 3
                                          ? Color.fromRGBO(86, 177, 191, 1)
                                          : Colors.grey,
                                      size: MediaQuery.of(context).size.width *
                                          0.04,
                                    ),
                                    Icon(
                                      Icons.star,
                                      color: pastPrograms![index].avgRate > 4
                                          ? Color.fromRGBO(86, 177, 191, 1)
                                          : Colors.grey,
                                      size: MediaQuery.of(context).size.width *
                                          0.04,
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : Center(child: Text('There is no past program.')),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class StatsContent extends StatelessWidget {
  UserStats? userStat;
  MyTheme theme = MyTheme();

  StatsContent({
    this.userStat,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: theme.currentTheme() == ThemeMode.dark
                ? Colors.grey[800]
                : Colors.white,
            boxShadow: [
              BoxShadow(
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: Offset(1, 2),
                  color: Color(0xffd6d6d6))
            ],
            borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!userStat!.userPrivacy.totalWorkoutsPrivate)
                      Container(
                        child: Column(
                          children: [
                            Text(
                              allTranslations.text('total_workouts')!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              userStat!.totalWorkouts.toString(),
                              style: TextStyle(fontSize: 17),
                            ),
                            SizedBox(height: 3),
                          ],
                        ),
                      ),
                    if (!userStat!.userPrivacy.totalWeightPrivate)
                      Container(
                        child: Column(
                          children: [
                            Text(
                              allTranslations.text('total_weight_lifted')!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              userStat!.totalWeight.toString(),
                              style: TextStyle(fontSize: 17),
                            ),
                            SizedBox(height: 3),
                          ],
                        ),
                      ),
                    if (!userStat!.userPrivacy.maxSquatPrivate)
                      Container(
                        child: Column(
                          children: [
                            Text(
                              'Squat',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              userStat!.maxSquat.toString(),
                              style: TextStyle(fontSize: 17),
                            ),
                            SizedBox(height: 3),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!userStat!.userPrivacy.bodyFatPrivate)
                      Container(
                        child: Column(
                          children: [
                            Text(
                              allTranslations.text('bodyfat')!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              userStat!.bodyFat.toString(),
                              style: TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                    if (!userStat!.userPrivacy.maxDeadliftPrivate)
                      Container(
                        child: Column(
                          children: [
                            Text(
                              'Deadlift',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              userStat!.maxDeadlift.toString(),
                              style: TextStyle(fontSize: 17),
                            ),
                            SizedBox(height: 3),
                          ],
                        ),
                      ),
                    if (!userStat!.userPrivacy.maxBenchPrivate)
                      Container(
                        child: Column(
                          children: [
                            Text(
                              'Bench',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              userStat!.maxBench.toString(),
                              style: TextStyle(fontSize: 17),
                            ),
                            SizedBox(height: 3),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
