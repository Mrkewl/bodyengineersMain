import 'package:bodyengineer/screen/widget/youtube_video.dart';

import '../../../helper/tools_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../be_theme.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/tutorial/tutorial_model.dart';
import '../../model/tutorial/tutorial.dart';
import '../../model/user/user_model.dart';
import '../../model/user/user.dart';

class VideoTutorialPage extends StatefulWidget {
  @override
  _VideoTutorialPageState createState() => _VideoTutorialPageState();
}

class _VideoTutorialPageState extends State<VideoTutorialPage> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  late List<Tutorial> tutorialList;
  Tutorial? tutorial;
  bool didChange = false;
  List<Widget> tutorialWidget = [];

  bool isFullScreen = false;
  void onFullScreen(Tutorial tutorial) {
    // bulk edit //print('***************==========================================');
    // bulk edit //print('ONFULLSCREEN');
    // bulk edit //print(tutorial.tutorialUrl);
    // bulk edit //print('***************==========================================');
    // bulk edit //print('***************==========================================');
    // bulk edit //print('******videoId******');
    // bulk edit //print(tutorial);

    setState(() {
      tutorialList.forEach((element) {
        element.isVisible = false;
      });
      tutorialList.where((element) => element == tutorial).first.isVisible =
          true;
      isFullScreen = true;
    });

    // bulk edit //print('******videoId******');
  }

  void exitFullScreen(Tutorial tutorial) {
    // bulk edit //print('******videoId******');

    setState(() {
      tutorialList.forEach((element) {
        element.isVisible = true;
      });

      isFullScreen = false;
    });

    // bulk edit //print('******videoId******');
  }

  // @override
  // void didChangeDependencies() {
  //   if (!didChange) {
  //     if (tutorialList != null) {
  //       tutorialList.forEach((element) {
  //         // bulk edit //print('******** Tutorial List Is Not Empty *******');
  //         // setState(() {
  //         //   tutorialWidget.add(YoutubeVideoItem(
  //         //       isFullScreen: isFullScreen,
  //         //       itIsFullScreen: itIsFullScreen,
  //         //       itIsNotFullScreen: itIsNotFullScreen,
  //         //       tutorial: element ,
  //         //       videoId: element.tutorialUrl.split('watch?v=')[1]));
  //         // });
  //       });
  //       setState(() {
  //         didChange = true;
  //       });
  //     }
  //   }

  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    Provider.of<TutorialModel>(context, listen: false).getTutorialList();
    // if (tutorialList == null) {
    tutorialList =
        Provider.of<TutorialModel>(context, listen: true).tutorialList;
    // bulk edit //print(tutorialList);
    // }

    UserObject? user = Provider.of<UserModel>(context, listen: true).user;

    return Scaffold(
      key: _key,
      appBar: isFullScreen ? null : setAppBar(_key) as PreferredSizeWidget?,
      drawer: isFullScreen ? null : buildProfileDrawer(context, user),
      body: Column(
        children: [
          Visibility(
            visible: !isFullScreen,
            child: Container(
              color: Color.fromRGBO(8, 112, 138, 1),
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
                    allTranslations.text('video_tutorials')!,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: 30,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: tutorialList.length,
                itemBuilder: (context, index) =>
                    NewYoutubePlayer(tutorial: tutorialList[index])
                // YoutubeVideoItem(
                //     isFullScreen: isFullScreen,
                //     itIsFullScreen: onFullScreen,
                //     itIsNotFullScreen: exitFullScreen,
                //     tutorial: tutorialList[index],
                //     videoId:
                //         tutorialList[index].tutorialUrl.split('watch?v=')[1]),
                // itemCount: tutorialList.length,
                ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class YoutubeVideoItem extends StatefulWidget {
  bool? isFullScreen;
  String? videoId;
  Function? itIsFullScreen;
  Function? itIsNotFullScreen;
  Tutorial? tutorial;
  YoutubeVideoItem({
    this.isFullScreen,
    this.itIsFullScreen,
    this.itIsNotFullScreen,
    this.videoId,
    this.tutorial,
  });
  @override
  _YoutubeVideoItemState createState() => _YoutubeVideoItemState();
}

class _YoutubeVideoItemState extends State<YoutubeVideoItem> {
  bool _isPlayerReady = false;

  String videoId = '';

  bool showInfo = false;
  bool didChange = false;
  bool isFullScreen = false;
  // ignore: unused_field
  PlayerState? _playerState;
  // ignore: unused_field
  YoutubeMetaData? _videoMetaData;
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId!,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        disableDragSeek: false,
      ),
    )..addListener(listener);
  }

  void listener() {
    if (_isPlayerReady && !_controller.value.isFullScreen) {
      _playerState = _controller.value.playerState;
      _videoMetaData = _controller.metadata;
    }
    if (!_controller.value.isFullScreen) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      widget.itIsNotFullScreen!(widget.tutorial);
      setState(() {
        isFullScreen = true;
      });
    } else {
      widget.itIsFullScreen!(widget.tutorial);

      setState(() {
        isFullScreen = false;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller.dispose();
    super.dispose();
  }

  void ontap() async {
    if (_controller.value.isFullScreen) {
      await widget.itIsNotFullScreen!(widget.tutorial);
      setState(() {
        isFullScreen = true;
      });
    } else {
      await widget.itIsFullScreen!(widget.tutorial);
      setState(() {
        isFullScreen = false;
      });
    }
    _controller.toggleFullScreenMode();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> helperWidget = [];
    for (var item in widget.tutorial!.tutorialHelperList) {
      helperWidget.add(Text(item!));
    }

    return widget.tutorial!.isVisible
        ? !isFullScreen
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: YoutubePlayer(
                  controller: _controller,
                ),
              )
            : GestureDetector(
                onDoubleTap: ontap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: YoutubePlayerBuilder(
                      player: YoutubePlayer(
                        controller: _controller,
                      ),
                      builder: (context, player) {
                        return Column(
                          children: [
                            Padding(
                              padding: isFullScreen
                                  ? EdgeInsets.all(10)
                                  : EdgeInsets.all(0),
                              child: Stack(
                                children: [
                                  Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.38,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.black26,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            MediaQuery.of(context).size.height *
                                                0.015,
                                        vertical:
                                            MediaQuery.of(context).size.height *
                                                0.03,
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          player,
                                        ],
                                      )),
                                  Visibility(
                                    visible: !widget.isFullScreen!,
                                    child: Positioned(
                                      left: 15,
                                      right: 15,
                                      child: Column(
                                        children: [
                                          SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                widget.tutorial!.tutorialTitle!,
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      showInfo = !showInfo;
                                                    });
                                                  },
                                                  child:
                                                      Icon(Icons.info_outline)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: showInfo,
                                    child: Positioned(
                                      top: MediaQuery.of(context).size.height *
                                          0.05,
                                      left: MediaQuery.of(context).size.width *
                                          0.05,
                                      right: MediaQuery.of(context).size.width *
                                          0.025,
                                      child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 10),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black26),
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.tutorial!
                                                    .tutorialHelperTitle!,
                                                style: TextStyle(fontSize: 17),
                                              ),
                                              SizedBox(height: 5),
                                              ...helperWidget
                                            ],
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                ))
        : Container();
  }
}

// ignore: must_be_immutable
class NewYoutubePlayer extends StatefulWidget {
  Tutorial? tutorial;
  NewYoutubePlayer({this.tutorial});

  @override
  _NewYoutubePlayerState createState() => _NewYoutubePlayerState();
}

class _NewYoutubePlayerState extends State<NewYoutubePlayer> {
  bool showInfo = false;
  MyTheme theme = MyTheme();

  @override
  Widget build(BuildContext context) {
    List<Widget> helperWidget = [];
    for (var item in widget.tutorial!.tutorialHelperList) {
      helperWidget.add(Text(item!));
    }
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(0),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (showInfo) {
                      setState(() {
                        showInfo = false;
                      });
                    }
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.currentTheme() == ThemeMode.dark
                            ? Colors.grey[600]!
                            : Colors.black26,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.025,
                      right: MediaQuery.of(context).size.width * 0.025,
                      top: MediaQuery.of(context).size.height * 0.075,
                      bottom: MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => YoutubeVideoWidget(
                                  widget.tutorial!.tutorialUrl!))),
                      child: Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(Tools.getYoutubeThumb(
                                    url: widget.tutorial!.tutorialUrl!)),
                                fit: BoxFit.cover)),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 15,
                  right: 15,
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.tutorial!.tutorialTitle!,
                            style: TextStyle(fontSize: 15),
                          ),
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  showInfo = !showInfo;
                                });
                              },
                              child: Icon(Icons.info_outline)),
                        ],
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: showInfo,
                  child: Positioned(
                    top: MediaQuery.of(context).size.height * 0.05,
                    left: MediaQuery.of(context).size.width * 0.05,
                    right: MediaQuery.of(context).size.width * 0.025,
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tutorial!.tutorialHelperTitle!,
                              style: TextStyle(fontSize: 17),
                            ),
                            SizedBox(height: 5),
                            ...helperWidget
                          ],
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
