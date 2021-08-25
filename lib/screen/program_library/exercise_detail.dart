import 'dart:io';

import 'package:bodyengineer/screen/widget/youtube_video.dart';

import '../../../model/planner/exercise_history.dart';
import '../../../model/planner/planner_model.dart';
import 'package:chewie/chewie.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:math';
import 'package:video_player/video_player.dart' as video;
import 'package:provider/provider.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../helper/tools_helper.dart';
import '../../model/program/exercise.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class ExerciseDetail extends StatefulWidget {
  @override
  _ExerciseDetailState createState() => _ExerciseDetailState();
}

class _ExerciseDetailState extends State<ExerciseDetail> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  Exercise? exercise;
  String format = 'dd MMMM yyyy';
  bool isComingExerciseList = false;
  List<Map<String, Map<DateTime?, List<ExerciseHistoryElement>>>>?
      dateFilterExerciseHistory;
  PageController? _pageController;
  int currentIndex = 0;
  bool isFavorite = false;
  List<Widget> muscleImageListWidget = [];
  bool fullScreen = false;
  List<ExerciseHistoryElement> exerciseHistory = [];
  video.VideoPlayerController? _controller;
  ChewieController? chewieController;
  Chewie? playerWidget;

  warnMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Custom Exercise"),
          content: Text(
              'If you delete this custom exercise, all data related with this exercise will delete as well. Are you sure to delete?'),
          actions: [
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                "Delete",
                style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
              ),
              onPressed: () => deleteCustomExercise(),
            ),
          ],
        );
      },
    );
  }

  deleteCustomExercise() {
    print(exercise!.exerciseName);
    Provider.of<PlannerModel>(context, listen: false)
        .deleteCustomExercise(exercise);
    if (isComingExerciseList) {
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, '/navigation', (route) => false,
          arguments: {'index': 1});
    }
  }

  onChangedFunction(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  filterExercise() {
    List<ExerciseHistoryElement> filteredExList = exerciseHistory
        .where(
            (element) => element.exerciseId == int.parse(exercise!.exerciseId!))
        .toList()
          ..sort((a, b) => b.dateTime!.compareTo(a.dateTime!));

    Map<String, List<ExerciseHistoryElement>> nameStage = groupBy(
        filteredExList,
        (ExerciseHistoryElement obj) =>
            obj.name! + '****' + obj.workoutId.toString());
    dateFilterExerciseHistory = [];

    nameStage.forEach((key, value) {
      Map<DateTime?, List<ExerciseHistoryElement>> firstStageList =
          groupBy(value, (ExerciseHistoryElement obj) => obj.dateTime);

      key = key.split('****').first; // To fix multiple same date history
      dateFilterExerciseHistory!.add({key: firstStageList});
    });
  }

  bool isFullScreen = false;
  void onFullScreen(Exercise exercise) {
    // bulk edit //print('***************==========================================');
    // bulk edit //print('ONFULLSCREEN');
    // bulk edit //print(exercise.exerciseVideo);
    // bulk edit //print('***************==========================================');
    // bulk edit //print('***************==========================================');
    // bulk edit //print('******videoId******');
    // bulk edit //print(exercise);

    setState(() {
      isFullScreen = true;
    });

    // bulk edit //print('******videoId******');
  }

  void exitFullScreen(Exercise exercise) {
    // bulk edit //print('******videoId******');

    setState(() {
      isFullScreen = false;
    });

    // bulk edit //print('******videoId******');
  }

  // List<String> tags = ['Chest', 'Triceps'];

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    chewieController?.dispose();

    _controller?.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    exerciseHistory =
        Provider.of<PlannerModel>(context, listen: true).exerciseHistory;
    bool _isPlaying = false;
    exercise = args['exercise'];
    isComingExerciseList = args['isComingExerciseList'] ?? false;

    if (exercise!.isVideoLocal! &&
        _controller == null &&
        chewieController == null) {
      _controller = video.VideoPlayerController.file(
        File(exercise!.exerciseVideo!),
      );
      chewieController = ChewieController(
        videoPlayerController: _controller!,
        autoPlay: false,
        looping: false,
      );
      playerWidget = Chewie(
        controller: chewieController!,
      );
      if (exercise!.exerciseVideo != null && exercise!.exerciseVideo != '')
        _controller!
          ..addListener(() {
            final bool isPlaying = _controller!.value.isPlaying;
            if (isPlaying != _isPlaying) {
              setState(() {
                _isPlaying = isPlaying;
              });
            }
          })
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });
    }

    if (exercise!.muscleGroup.isNotEmpty && muscleImageListWidget.isEmpty)
      exercise!.muscleGroup
        ..forEach((muscle) {
          Widget widget = Visibility(
            visible: !isFullScreen,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: double.infinity,
              child: exercise!.muscleGroup.isNotEmpty
                  ? Image.network(muscle.muscleImg!)
                  : Image.asset(
                      'assets/images/bodystats/body_measurement.png',
                      fit: BoxFit.fitHeight,
                    ),
            ),
          );

          muscleImageListWidget.add(widget);
        });
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      // bulk edit //print('IT IS LANFSCAPE');
      setState(() {
        fullScreen = true;
      });
    } else {
      // bulk edit //print('IT IS POTRAIT');

      setState(() {
        fullScreen = false;
      });
    }

    if (dateFilterExerciseHistory == null) filterExercise();

    return Scaffold(
      key: _key,
      appBar: isFullScreen ? null : setAppBar(_key) as PreferredSizeWidget?,
      drawer: isFullScreen ? null : buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        physics:
            isFullScreen ? NeverScrollableScrollPhysics() : ScrollPhysics(),
        child: Padding(
          padding: isFullScreen ? EdgeInsets.all(0) : const EdgeInsets.all(5),
          child: Card(
            elevation: isFullScreen ? 0 : 7,
            child: Column(
              children: [
                Visibility(
                  visible: !isFullScreen,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chevron_left,
                              color: Colors.black54,
                              size: 30,
                            ),
                            Text(
                              exercise!.exerciseName!,
                              style: TextStyle(fontSize: 17),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: !isFullScreen
                      ? MediaQuery.of(context).size.height * 0.35
                      : MediaQuery.of(context).size.height,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      PageView(
                        controller: _pageController,
                        onPageChanged: onChangedFunction,
                        children: [
                          ...muscleImageListWidget,
                          if (exercise!.exerciseVideo != '')
                            exercise!.isVideoLocal!
                                ? playerWidget!
                                : GestureDetector(
                                    onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                YoutubeVideoWidget(
                                                    exercise!.exerciseVideo!))),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  Tools.getYoutubeThumb(
                                                      url: exercise!
                                                          .exerciseVideo!)),
                                              fit: BoxFit.cover)),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 10),
                  height: 15,
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: exercise!.exerciseVideo != ''
                          ? exercise!.muscleGroup.length + 1
                          : exercise!.muscleGroup.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.03),
                          child: Indicator(
                            positionIndex: index,
                            currentIndex: currentIndex,
                          ),
                        );
                      }),
                ),
                Visibility(
                  visible: !isFullScreen,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                    child: GridView.builder(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 3.5,
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 15,
                        ),
                        itemCount: exercise!.muscleGroup.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Container(
                              constraints: BoxConstraints(
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.3),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 2,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7),
                                    child: Text(
                                      exercise!.muscleGroup[index].muscleName!,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),
                Visibility(
                  visible: !isFullScreen,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                      left: 10,
                      bottom: 20,
                    ),
                    child: GridView.builder(
                        itemCount: exercise!.movementGroup.length,
                        padding: EdgeInsets.symmetric(vertical: 5),
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 3,
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 15,
                        ),
                        itemBuilder: (context, index) {
                          return Container(
                            constraints: BoxConstraints(
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.2),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 7),
                                  child: Text(
                                    exercise!
                                        .movementGroup[index].movementName!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),
                Visibility(
                  visible: !isFullScreen && exercise!.isCustom!,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                        padding: EdgeInsets.only(
                          right: 10,
                          left: 10,
                          bottom: 15,
                        ),
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.red.shade700,
                          ),
                          child: Text(
                            'Delete Custom Exercise',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () => warnMessage(context),
                        )),
                  ),
                ),
                Visibility(
                  visible: currentIndex != muscleImageListWidget.length &&
                      !isFullScreen,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise!.exerciseName!,
                                style: TextStyle(
                                  fontSize: 17,
                                ),
                              ),
                              Text(
                                exercise!.exerciseInstructions!,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              if (exerciseHistory
                                  .where((element) =>
                                      element.exerciseId.toString() ==
                                      exercise!.exerciseId)
                                  .isNotEmpty)
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.only(top: 20),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 15),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 3,
                                          spreadRadius: 4,
                                        )
                                      ]),
                                  //TODO getting the different text in ternary operator with bodyweight and others.
                                  child: exercise!.equipmentGroup.any(
                                          (element) =>
                                              element.equipmentName !=
                                              'Bodyweight')
                                      ? Text(
                                          'Personal Record : ' +
                                              exerciseHistory
                                                  .where((element) =>
                                                      element.exerciseId
                                                          .toString() ==
                                                      exercise!.exerciseId)
                                                  .map((e) => e.weight!)
                                                  .reduce((max))
                                                  .toString() +
                                              ' kg ',
                                        )
                                      : Text(
                                          'Personal Record : ' +
                                              exerciseHistory
                                                  .where((element) =>
                                                      element.exerciseId
                                                          .toString() ==
                                                      exercise!.exerciseId)
                                                  .map((e) => e.rep!)
                                                  .reduce((max))
                                                  .toString() +
                                              ' Reps ',
                                        ),
                                )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 10,
                          ),
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: dateFilterExerciseHistory!.length,
                              itemBuilder: (BuildContext ctxt, int index) {
                                return Container(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              dateFilterExerciseHistory![index]
                                                  .keys
                                                  .first,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(intl.DateFormat(format)
                                                .format(
                                                    dateFilterExerciseHistory![
                                                            index]
                                                        .values
                                                        .first
                                                        .keys
                                                        .first!)
                                                .toString()),
                                          ],
                                        ),
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount:
                                            dateFilterExerciseHistory![index]
                                                .values
                                                .first
                                                .values
                                                .first
                                                .length,
                                        itemBuilder: (context, i) {
                                          ExerciseHistoryElement exHist =
                                              dateFilterExerciseHistory![index]
                                                  .values
                                                  .first
                                                  .values
                                                  .first[i];
                                          // bulk edit //print(exHist);
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Row(
                                              children: [
                                                exercise!.equipmentGroup.any(
                                                        (equipment) =>
                                                            equipment
                                                                .equipmentName !=
                                                            'Bodyweight')
                                                    ? Text(exHist.weight
                                                            .toString() +
                                                        ' kg x ' +
                                                        exHist.rep.toString() +
                                                        ' reps')
                                                    : Text(
                                                        exHist.rep.toString() +
                                                            ' reps')
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: currentIndex == muscleImageListWidget.length &&
                      !isFullScreen,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Steps',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          exercise!.exerciseInstructions!,
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
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
