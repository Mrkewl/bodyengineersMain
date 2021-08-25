import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../model/program/exercise.dart';

// ignore: must_be_immutable
class YoutubeVideoItem extends StatefulWidget {
  bool? isFullScreen;
  String? videoId;
  Function? itIsFullScreen;
  Function? itIsNotFullScreen;
  Exercise? exercise;
  YoutubeVideoItem({
    this.isFullScreen,
    this.itIsFullScreen,
    this.itIsNotFullScreen,
    this.videoId,
    this.exercise,
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
        disableDragSeek: true,
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
      widget.itIsNotFullScreen!(widget.exercise);
      setState(() {
        isFullScreen = true;
      });
    } else {
      widget.itIsFullScreen!(widget.exercise);

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
      await widget.itIsNotFullScreen!(widget.exercise);
      setState(() {
        isFullScreen = true;
      });
    } else {
      await widget.itIsFullScreen!(widget.exercise);
      setState(() {
        isFullScreen = false;
      });
    }
    _controller.toggleFullScreenMode();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> helperWidget = [];

    return widget.exercise != null
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
                                              0.33,
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
                                                widget.exercise!.exerciseName!,
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
                                                widget.exercise!.exerciseName!,
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
