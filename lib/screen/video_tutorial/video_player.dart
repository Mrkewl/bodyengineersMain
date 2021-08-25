import 'package:flutter/material.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// ignore: must_be_immutable
class VideoPlayer extends StatefulWidget {
  bool? isFullScreen;
  String? videoId;
  Function? itIsFullScreen;
  Function? itIsNotFullScreen;
  VideoPlayer(
      {this.isFullScreen,
      this.itIsFullScreen,
      this.itIsNotFullScreen,
      this.videoId});
  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  bool _isPlayerReady = false;

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
        controlsVisibleAtStart: true,
        disableDragSeek: false,
      ),
    )..addListener(listener);
  }

  void listener() {
    if (_isPlayerReady && !_controller.value.isFullScreen) {
      _playerState = _controller.value.playerState;
      _videoMetaData = _controller.metadata;
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
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // _controller.toggleFullScreenMode();
    if (_controller.value.isFullScreen) {
      // bulk edit //print('********** Full Screen **********');
      // bulk edit //print(_controller.initialVideoId);
      // bulk edit //print('********** Full Screen **********');
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(controller: _controller),
      builder: (context, player) => player,
    );
  }
}
