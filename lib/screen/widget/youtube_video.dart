import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideoWidget extends StatefulWidget {
  String videoUrl;
  YoutubeVideoWidget(this.videoUrl);
  @override
  _YoutubeVideoWidgetState createState() => _YoutubeVideoWidgetState();
}

class _YoutubeVideoWidgetState extends State<YoutubeVideoWidget> {
  YoutubePlayerController? _youtubeVideoPlayerController;
  bool isFullScreen = false;
  listener() {
    setState(() {
      if (isFullScreen != _youtubeVideoPlayerController!.value.isFullScreen)
        isFullScreen = _youtubeVideoPlayerController!.value.isFullScreen;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _youtubeVideoPlayerController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.videoUrl)!,
      flags: YoutubePlayerFlags(
        isLive: false,
        autoPlay: true,
        enableCaption: false,
      ),
    )..addListener(listener);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _youtubeVideoPlayerController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        YoutubePlayerBuilder(
            player: YoutubePlayer(
              onEnded: (YoutubeMetaData metaData) {
                if (isFullScreen) {
                  _youtubeVideoPlayerController!.toggleFullScreenMode();
                }
                return Navigator.pop(context);
              },
              controller: _youtubeVideoPlayerController!,
            ),
            builder: (context, player) {
              return Scaffold(
                  backgroundColor: Colors.black,
                  body: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.center,
                    child: player,
                  ));
            }),
        Visibility(
          visible: !isFullScreen,
          child: Positioned(
              right: 25,
              top: 25,
              child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: Colors.white, size: 30))),
        ),
      ],
    );
  }
}
