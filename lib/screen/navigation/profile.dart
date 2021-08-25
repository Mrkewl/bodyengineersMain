import 'dart:ui';
import '../../model/achievement/achievement.dart';
import '../../model/achievement/achievement_model.dart';
import '../../model/program/program.dart';
import '../../model/program/program_model.dart';
import '../../screen/social_media/widgets/find_friends_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui' as ui;

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../be_theme.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';
import 'achievements/widget/achievement_element.dart';

class Profile extends StatefulWidget {
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  List<Achievement> completedAchievementList = [];
  UserObject? user;
  String measurementUnit = '';
  @override
  void initState() {
    Provider.of<UserModel>(context, listen: false).generateStatistics();

    Future.delayed(Duration.zero, () async {
      // await Provider.of<UserModel>(context, listen: false)
      //     .getCurrentUserStats();
      await Provider.of<ProgramModel>(context, listen: false).getProgramList();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        measurementUnit = prefs.getInt('unit') == 1 ? 'kg' : 'lbs';
      });
    });
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
  List<UserObject> searchUser = [];
  List<UserObject> allUsers = [];
  List<Program>? programList;

  bool isAll = true;

  String searchFriend = '';

  void feedMenu({String? value, BuildContext? context}) {
    switch (value) {
      case 'Find Friends':
        _findFriendsModalBottomSheet(context);
        break;
      case 'Invite Friends':
        // bulk edit //print('Invite Friends');
        break;
    }
  }

  void _findFriendsModalBottomSheet(context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext ctx) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.65,
                    maxHeight: MediaQuery.of(context).size.height * 0.65),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Container(
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    MediaQuery.of(context).viewInsets.bottom > 1
                                        ? EdgeInsets.only(top: 30)
                                        : EdgeInsets.all(0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      allTranslations.text('find_friends')!,
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Icon(Icons.close),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 5),
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  child: TextField(
                                    onChanged: (String value) {
                                      // bulk edit //print(value);
                                      setState(() {
                                        searchFriend = value;
                                        searchUser = allUsers
                                            .where((element) => element
                                                .fullname!
                                                .toLowerCase()
                                                .contains(
                                                    searchFriend.toLowerCase()))
                                            .toList();
                                      });
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.search),
                                      hintText: allTranslations.text('search'),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                          width: 2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10.0)),
                                        borderSide: BorderSide(
                                          color:
                                              Color.fromRGBO(86, 177, 191, 1),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                spreadRadius: 1,
                                offset: Offset(0, 5))
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isAll = true;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: isAll
                                      ? Color.fromRGBO(86, 177, 191, 1)
                                      : Colors.grey[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  allTranslations.text('all')!,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isAll = false;
                                  });
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: isAll
                                      ? Colors.grey[400]
                                      : Color.fromRGBO(86, 177, 191, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  allTranslations.text('mutual')!,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (searchFriend != '')
                        Visibility(
                          visible: isAll,
                          child: ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: searchUser.length,
                              itemBuilder: (BuildContext ctxt, int index) {
                                return FindFriendsItem(
                                  user: searchUser[index],
                                );
                              }),
                        ),
                      if (searchFriend != '')
                        Visibility(
                            visible: !isAll,
                            child: ListView.builder(
                                physics: ClampingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: searchUser.length,
                                itemBuilder: (BuildContext ctxt, int index) {
                                  return FindFriendsItem(
                                      user: searchUser[index]);
                                })),
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  ////////////////////////Functions about Find/Invite Friends End/////////////////////////////////////////

  void _showFriendsModalBottomSheet(context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext ctx) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.65,
                        maxHeight: MediaQuery.of(context).size.height * 0.65),
                    child: SingleChildScrollView(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Container(
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    MediaQuery.of(context).viewInsets.bottom > 1
                                        ? EdgeInsets.only(top: 30)
                                        : EdgeInsets.all(0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      allTranslations.text('friends')!,
                                      style: TextStyle(fontSize: 17),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Icon(Icons.close),
                                    ),
                                  ],
                                ),
                              ),
                              user!.friendList.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 25),
                                        child: Text(
                                          "You don't have any friend now. You can add friends via 3 dots button.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      physics: ClampingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: user!.friendList.length,
                                      itemBuilder:
                                          (BuildContext ctxt, int index) {
                                        return FindFriendsItem(
                                          user: user!.friendList[index],
                                        );
                                      }),
                            ],
                          ),
                        ),
                      )
                    ]))));
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    // bulk edit //print('*******************************' + exampleList.length.toString());
    user = Provider.of<UserModel>(context, listen: true).user;
    measurementUnit = user!.unitOfMeasurementId == 1 ? 'kg' : 'lbs';

    programList = Provider.of<ProgramModel>(context, listen: true).programList;

    allUsers = Provider.of<UserModel>(context, listen: true).allUserList;
    completedAchievementList =
        Provider.of<AchievementModel>(context, listen: true)
            .achievementList!
            .where((element) => element.isCompleted)
            .toList();

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
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
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
                        allTranslations.text('profile')!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz,
                          size: 30,
                          color: Colors.white,
                        ),
                        onSelected: (value) =>
                            feedMenu(value: value, context: context),
                        itemBuilder: (BuildContext context) {
                          return {
                            allTranslations.text('find_friends')!,
                          }.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.35,
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
                          if (completedAchievementList.isNotEmpty)
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
                                Container(
                                  child: SvgPicture.asset(
                                    completedAchievementList.last.image!,
                                    width: 50,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                if (completedAchievementList.length > 1)
                                  Container(
                                    margin: EdgeInsets.only(top: 15),
                                    child: SvgPicture.asset(
                                      completedAchievementList[
                                              completedAchievementList.length -
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
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (user != null) {
                              if (!user!.isGeneralInfoFilled!) {
                                await Navigator.pushNamed(
                                    context, '/signupform');
                              } else {
                                await Navigator.pushNamed(
                                    context, '/edit_profile');
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                          ),
                          child: Text(
                            allTranslations.text('edit')!,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: ElevatedButton(
                          onPressed: () {
                            _showFriendsModalBottomSheet(context);
                          },
                          child: Text(
                            allTranslations.text('friends')!,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                            textStyle: TextStyle(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Color.fromRGBO(86, 177, 191, 1),
                              width: 2,
                            ),
                          ),

                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: SizedBox(
                    height: 50,
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
                Expanded(
                  child: TabBarView(
                    children: [
                      user!.userStats == null
                          ? Container()
                          : StatsContent(
                              totalWorkouts:
                                  user!.userStats!.totalWorkouts.toString(),
                              totalWeightLifted:
                                  user!.userStats!.totalWeight.toString(),
                              deadlift:
                                  user!.userStats!.maxDeadlift.toString() +
                                      ' ' +
                                      measurementUnit,
                              squat: user!.userStats!.maxSquat.toString() +
                                  ' ' +
                                  measurementUnit,
                              bench: user!.userStats!.maxBench.toString() +
                                  ' ' +
                                  measurementUnit,
                              bodyfat:
                                  user!.userStats!.bodyFat.toString() + '%',
                            ),
                      AchievementsContent(
                        completedAchievementList: completedAchievementList,
                      ),
                      TabContent(user!.userPrograms, programList),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class TabContent extends StatelessWidget {
  late List<Program> userPrograms;
  List<Program>? programList;
  List<String?>? userProgramIdLit;
  TabContent(this.userProgramIdLit, this.programList);
  Program? currentProgram;
  List<Program>? pastPrograms;
  @override
  Widget build(BuildContext context) {
    // if (programList.isNotEmpty && userPrograms == null ) {
    userPrograms = userProgramIdLit == null
        ? []
        : programList!
            .where((element) => userProgramIdLit!
                .map((e) => e)
                .toList()
                .contains(element.programId))
            .toList();
    // }
    if (currentProgram == null && userPrograms.isNotEmpty)
      currentProgram = userPrograms.last;
    if (currentProgram != null)
      pastPrograms =
          userPrograms.where((element) => element != currentProgram).toList();

    // bulk edit //print(userPrograms);
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 15),
          Text(
            allTranslations.text('current_program')!,
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
                                    allTranslations.text('duration')! + ':',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    currentProgram!.programDuration.toString() +
                                        ' ' +
                                        allTranslations.text('duration')!,
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
              : Center(
                  child: Text(allTranslations.text('no_current_program')!)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(allTranslations.text('past_programs')!,
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
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15),
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
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                placeholder: (context, url) => Container(
                                    alignment: Alignment.center,
                                    height: MediaQuery.of(context).size.height *
                                        0.25,
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              Positioned.fill(
                                  child: BackdropFilter(
                                filter:
                                    ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
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
                                      allTranslations.text('duration')! + ':',
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
                                          ' ' +
                                          allTranslations.text('weeks')!,
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
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
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: pastPrograms![index].avgRate > 1
                                            ? Color.fromRGBO(86, 177, 191, 1)
                                            : Colors.grey,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: pastPrograms![index].avgRate > 2
                                            ? Color.fromRGBO(86, 177, 191, 1)
                                            : Colors.grey,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: pastPrograms![index].avgRate > 3
                                            ? Color.fromRGBO(86, 177, 191, 1)
                                            : Colors.grey,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: pastPrograms![index].avgRate > 4
                                            ? Color.fromRGBO(86, 177, 191, 1)
                                            : Colors.grey,
                                        size:
                                            MediaQuery.of(context).size.width *
                                                0.04,
                                      ),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Center(
                  child: Text(
                  allTranslations.text('no_past_program')!,
                )),
        ],
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: GridView.builder(
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
class StatsContent extends StatelessWidget {
  String? totalWorkouts;
  String? totalDistanceRan;
  String? totalWeightLifted;
  String? deadlift;
  String? squat;
  String? bench;
  String? sprintSpeed;
  String? bodyfat;
  MyTheme theme = MyTheme();

  StatsContent({
    this.totalWorkouts,
    this.totalDistanceRan,
    this.totalWeightLifted,
    this.deadlift,
    this.squat,
    this.bench,
    this.sprintSpeed,
    this.bodyfat,
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
                            totalWorkouts!,
                            style: TextStyle(fontSize: 17),
                          ),
                          SizedBox(height: 3),
                        ],
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          Text(
                            allTranslations.text('total_weight_lifted')!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            totalWeightLifted!,
                            style: TextStyle(fontSize: 17),
                          ),
                          SizedBox(height: 3),
                        ],
                      ),
                    ),
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
                            squat!,
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
                            bodyfat!,
                            style: TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
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
                            deadlift!,
                            style: TextStyle(fontSize: 17),
                          ),
                          SizedBox(height: 3),
                        ],
                      ),
                    ),
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
                            bench!,
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
