import 'package:bodyengineer/screen/widget/youtube_video.dart';

import '../../helper/tools_helper.dart';
import '../../model/planner/planner_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:provider/provider.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';
import './widgets/rating_dialog.dart';
import '../../model/program/program.dart';
import '../../model/program/program_model.dart';

class ProgramOverview extends StatefulWidget {
  @override
  _ProgramOverviewState createState() => _ProgramOverviewState();
}

class _ProgramOverviewState extends State<ProgramOverview> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  PageController? _pageController;
  int currentIndex = 0;
  bool isFavorite = false;

  onChangedFunction(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  bool isFullScreen = false;
  void onFullScreen(Program program) {
    // bulk edit //print('***************==========================================');
    // bulk edit //print('ONFULLSCREEN');
    // bulk edit //print(program.programVideo);
    // bulk edit //print('***************==========================================');
    // bulk edit //print('***************==========================================');
    // bulk edit //print('******videoId******');
    // bulk edit //print(program);

    setState(() {
      isFullScreen = true;
    });

    // bulk edit //print('******videoId******');
  }

  void exitFullScreen(Program program) {
    // bulk edit //print('******videoId******');

    setState(() {
      isFullScreen = false;
    });

    // bulk edit //print('******videoId******');
  }

  overwritePopup(BuildContext context, UserObject? user, String? programId) {
    Widget okButton = TextButton(
      child: Text(
        allTranslations.text('yes_overwrite')!,
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1), fontSize: 16),
      ),
      onPressed: () async {
        // await Provider.of<ProgramModel>(context, listen: false)
        //     .cleanAllProgram();
        // await Provider.of<PlannerModel>(context, listen: false)
        //     .cleanAllProgram();
        Navigator.pop(context);
        Navigator.pushNamed(context, '/add_program',
            arguments: {'programId': programId});
      },
    );
    Widget cancelButton = TextButton(
      child: Text(
        allTranslations.text('cancel')!,
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1), fontSize: 16),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(allTranslations.text('create_new_program')!),
      content: Text(allTranslations.text('already_program')!),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    Program program = Provider.of<ProgramModel>(context)
        .programList
        .where((element) => element.programId == args!['programId'])
        .first;
    if (program.phaseList.isEmpty)
      Provider.of<ProgramModel>(context, listen: false)
          .getProgramCalender(programId: args!['programId']);

    // bulk edit //print(program);
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.black54,
                        size: 30,
                      ),
                    ),
                    Text(
                      allTranslations.text('overview')!,
                      style: TextStyle(fontSize: 22),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/program_details',
                            arguments: {'programId': program.programId});
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        allTranslations.text('details')!,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        int? stars = await showDialog(
                            context: context,
                            builder: (_) => RatingDialog(
                                  userStars: program.userRate,
                                ));

                        if (stars == null) return;

                        // bulk edit //print('Selected rate stars: $stars');
                        Provider.of<ProgramModel>(context, listen: false)
                            .rateProgram(
                                rate: stars.toDouble(),
                                programId: program.programId);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        allTranslations.text('rate_it')!,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              child: Stack(
                children: [
                  PageView(
                    controller: _pageController,
                    onPageChanged: onChangedFunction,
                    children: [
                      Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: program.programImage!,
                            imageBuilder: (context, imageProvider) => Container(
                              height: MediaQuery.of(context).size.height * 0.3,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) => Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                child: Center(
                                    child: Container(
                                        height: 50,
                                        child: CircularProgressIndicator()))),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                          Positioned(
                            left: 15,
                            bottom: 10,
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.3,
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.4,
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                      child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(
                                        sigmaX: 0, sigmaY: 0),
                                    child: Container(
                                        decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(7),
                                    )),
                                  )),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          program.programName!,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          (program.programDuration).toString() +
                                              ' ' +
                                              allTranslations.text('weeks')!,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                                  color: program.avgRate > 0
                                      ? Color.fromRGBO(86, 177, 191, 1)
                                      : Colors.grey,
                                  size:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                                Icon(
                                  Icons.star,
                                  color: program.avgRate > 1
                                      ? Color.fromRGBO(86, 177, 191, 1)
                                      : Colors.grey,
                                  size:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                                Icon(
                                  Icons.star,
                                  color: program.avgRate > 2
                                      ? Color.fromRGBO(86, 177, 191, 1)
                                      : Colors.grey,
                                  size:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                                Icon(
                                  Icons.star,
                                  color: program.avgRate > 3
                                      ? Color.fromRGBO(86, 177, 191, 1)
                                      : Colors.grey,
                                  size:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                                Icon(
                                  Icons.star,
                                  color: program.avgRate > 4
                                      ? Color.fromRGBO(86, 177, 191, 1)
                                      : Colors.grey,
                                  size:
                                      MediaQuery.of(context).size.width * 0.04,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 5,
                            child: IconButton(
                              icon: isFavorite
                                  ? Icon(Icons.bookmark)
                                  : Icon(Icons.bookmark_border),
                              color: isFavorite ? Colors.red : Colors.grey,
                              iconSize: 35,
                              onPressed: () {
                                setState(() {
                                  isFavorite = !isFavorite;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      if (program.programVideo != '')
                        Stack(
                          children: [
                            Container(
                              height: !isFullScreen
                                  ? MediaQuery.of(context).size.height * 0.3
                                  : MediaQuery.of(context).size.height,
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            YoutubeVideoWidget(
                                                program.programVideo!))),
                                child: Container(
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: (NetworkImage(
                                              Tools.getYoutubeThumb(
                                                  url: program.programVideo!))),
                                          fit: BoxFit.cover)),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 15,
                              child: IconButton(
                                icon: isFavorite
                                    ? Icon(Icons.bookmark)
                                    : Icon(Icons.bookmark_border),
                                color: isFavorite ? Colors.red : Colors.grey,
                                iconSize: 35,
                                onPressed: () {
                                  setState(() {
                                    isFavorite = !isFavorite;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Indicator(
                    positionIndex: 0,
                    currentIndex: currentIndex,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  if (program.programVideo != '')
                    Indicator(
                      positionIndex: 1,
                      currentIndex: currentIndex,
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        allTranslations.text('fitness_level')!,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        program.programLevelName!,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: 1,
                    color: Colors.black54,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        allTranslations.text('equipment')!,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Optional',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Text(
                    allTranslations.text('description')!,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      program.programDescription!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(15),
                      backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                    ),
                    onPressed: () {
                      if (Provider.of<PlannerModel>(context, listen: false)
                          .programDayList
                          .isNotEmpty) {
                        overwritePopup(context, user, program.programId);
                      } else {
                        Navigator.pushNamed(context, '/add_program',
                            arguments: {'programId': program.programId});
                      }
                    },
                    child: Text(
                      allTranslations.text('add_program')!.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final int? positionIndex, currentIndex;
  const Indicator({this.currentIndex, this.positionIndex});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(horizontal: 4.0),
        height: positionIndex == currentIndex ? 10 : 8.0,
        width: positionIndex == currentIndex ? 12 : 8.0,
        decoration: BoxDecoration(
          boxShadow: [
            positionIndex == currentIndex
                ? BoxShadow(
                    color: Color(0XFF2FB7B2).withOpacity(0.72),
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: Offset(
                      0.0,
                      0.0,
                    ),
                  )
                : BoxShadow(
                    color: Colors.transparent,
                  )
          ],
          shape: BoxShape.circle,
          color: positionIndex == currentIndex
              ? Color(0XFF6BC4C9)
              : Color(0XFFEAEAEA),
        ),
      ),
    );
  }
}

// class Indicator extends StatelessWidget {
//   final int positionIndex, currentIndex;
//   const Indicator({this.currentIndex, this.positionIndex});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 12,
//       width: 12,
//       decoration: BoxDecoration(
//           border: Border.all(color: Color.fromRGBO(86, 177, 191, 1)),
//           color: positionIndex == currentIndex
//               ? Color.fromRGBO(86, 177, 191, 1)
//               : Colors.white,
//           borderRadius: BorderRadius.circular(100)),
//     );
//   }
// }
