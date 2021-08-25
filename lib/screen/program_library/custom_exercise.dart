import 'dart:io';

import 'package:bodyengineer/screen/widget/selecter/multi_selector.dart';

import '../../model/planner/planner_model.dart';
import '../../model/program/exercise.dart';
import '../../model/program/movement.dart';
import '../../model/program/muscle.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class AddCustomExercise extends StatefulWidget {
  @override
  _AddCustomExerciseState createState() => _AddCustomExerciseState();
}

class _AddCustomExerciseState extends State<AddCustomExercise> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController instructionController = TextEditingController();
  List<Muscle> muscleList = [];
  List<Movement> movementList = [];
  List<Exercise> allExerciseList = [];
  List<int> muscleValue = [];

  List<int> movementValue = [];
  final _picker = ImagePicker();
  File? _video;

  videoUploded(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Video uploaded successfully.'),
        );
      },
    );
  }

  exerciseCreated(BuildContext context, Exercise exercise) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('${exercise.exerciseName} has been added'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Great !'))
          ],
        );
      },
    );
  }

  Future<void> _videoFromGallery() async {
    // PickedFile pickedFile = await _picker.getVideo(
    //   source: ImageSource.gallery,
    // );
    FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
      allowedUtiTypes: [
        'public.video',
        'public.mpeg',
        'public.mpeg-4-audio',
        'com.apple.protected-​mpeg-4-audio'
      ],
      allowedMimeTypes: [
        'video/mpeg',
        'video/x-flv',
        'video/mp4',
        'application/x-mpegURL',
        'video/quicktime',
        'video/x-msvideo',
        'video/x-ms-wmv',
        'video/ogg',
        'video/mp2t',
        'video/3gpp'
      ],
      invalidFileNameSymbols: ['/'],
    );
    var path;
    if (Platform.isAndroid) {
      path = await FlutterDocumentPicker.openDocument(params: params);
    } else if (Platform.isIOS) {
      PickedFile? pickedFile =
          await (_picker.getVideo(source: ImageSource.gallery));
      path = pickedFile!.path;
    }
    if (path != null) {
      File video = File(path);
      setState(() {
        _video = video;
        print('Video Başarıyla Seçildi');
        videoUploded(context);
      });
    }
  }

  createExercise() {
    if (_formKey.currentState!.validate()) {
      // bulk edit //print('TEST TEST TEST');

      Exercise exercise = Exercise();
      exercise.exerciseId = '100000' +
          allExerciseList
              .where((element) => element.isCustom!)
              .length
              .toString(); // Increase
      exercise.exerciseName = nameController.text;
      exercise.exerciseVideo = _video != null ? _video!.path : '';
      exercise.exerciseInstructions = instructionController.text;
      exercise.isVideoLocal = true; // For custom exercise
      exercise.isCustom = true; // For custom exercise
      if (muscleValue != null)
        exercise.muscleGroup = muscleList
            .where(
                (element) => muscleValue.contains(int.parse(element.muscleId!)))
            .toList();
      if (movementValue != null)
        exercise.movementGroup = movementList
            .where((element) =>
                movementValue.contains(int.parse(element.movementId!)))
            .toList();

      print(exercise);
      Provider.of<PlannerModel>(context, listen: false)
          .addCustomExercise(exercise);
      exerciseCreated(context, exercise);
    }
  }

  List<Muscle> filterMuscle(List<Muscle> muscleList) {
    Map<String?, Muscle> mp = {};
    for (var item in muscleList) {
      mp[item.muscleId] = item;
    }
    List<Muscle> filteredMuscleList = mp.values.toList();
    return filteredMuscleList;
  }

  List<Movement> filterMovement(List<Movement> movementList) {
    Map<String?, Movement> mp = {};
    for (var item in movementList) {
      mp[item.movementId] = item;
    }
    List<Movement> filteredMovementList = mp.values.toList();
    return filteredMovementList;
  }

  onChangeMuscle(result) {
    setState(() {
      muscleValue = result;
    });
  }

  onChangeMovement(result) {
    setState(() {
      movementValue = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;

    allExerciseList =
        Provider.of<PlannerModel>(context, listen: true).allExerciseList;

    muscleList = allExerciseList
        .map((e) => e.muscleGroup)
        .toSet()
        .expand((element) => element)
        .toList();

    movementList = allExerciseList
        .map((e) => e.movementGroup)
        .toSet()
        .expand((element) => element)
        .toList();

    muscleList = filterMuscle(muscleList);
    movementList = filterMovement(movementList);
    print(muscleList);
    print(movementList);

    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Stack(
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 25, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Exercise Video (Optional):',
                          style: TextStyle(fontSize: 17),
                        ),
                        GestureDetector(
                          onTap: () => _videoFromGallery(),
                          child: Icon(
                            Icons.video_call,
                            size: 60,
                            color: _video != null
                                ? Color.fromRGBO(86, 177, 191, 1)
                                : Colors.black,
                          ),
                        ),
                        if (_video != null)
                          Text(
                            'Video has been uploaded',
                            style: TextStyle(
                              color: Color.fromRGBO(86, 177, 191, 1),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Text(
                            'Name of Exercise:',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                        TextFormField(
                          controller: nameController,
                          validator: (String? val) {
                            if (val!.length < 1)
                              return 'Please Enter Exercise Name';

                            return null;
                          },
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(86, 177, 191, 1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              hintText: 'Name of Exercise'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            'Muscle Group:',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  spreadRadius: 2,
                                )
                              ]),
                          child: GestureDetector(
                            child: Container(
                              height: 60,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Muscles',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MultiSelectorWidget(
                                        title: 'Muscle Group',
                                        values: muscleValue,
                                        choices: muscleList
                                            .map((e) => MultiSelectorElement(
                                                value: int.parse(e.muscleId!),
                                                name: e.muscleName))
                                            .toList(),
                                        onChanged: onChangeMuscle,
                                      )),
                            ),
                          ),
                        ),
                        ListView.builder(
                            physics: ClampingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: muscleValue.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              Muscle muscle = muscleList.firstWhere((element) =>
                                  element.muscleId ==
                                  muscleValue[index].toString());
                              return Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  child: Text(
                                    muscle.muscleName!,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(7),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 3,
                                        spreadRadius: 2,
                                      )
                                    ]),
                              );
                            }),
                        Text('Movemenent:', style: TextStyle(fontSize: 17)),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  spreadRadius: 2,
                                )
                              ]),
                          child: GestureDetector(
                            child: Container(
                              height: 60,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              decoration: BoxDecoration(),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Movement Group',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MultiSelectorWidget(
                                        title: 'Movement Group',
                                        values: movementValue,
                                        choices: movementList
                                            .map((e) => MultiSelectorElement(
                                                value: int.parse(e.movementId!),
                                                name: e.movementName))
                                            .toList(),
                                        onChanged: onChangeMovement,
                                      )),
                            ),
                          ),
                        ),
                        if (movementValue != null)
                          ListView.builder(
                              physics: ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: movementValue.length,
                              itemBuilder: (BuildContext ctxt, int index) {
                                Movement movement = movementList.firstWhere(
                                    (element) =>
                                        element.movementId ==
                                        movementValue[index].toString());
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 15),
                                    child: Text(
                                      movement.movementName!,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(7),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 3,
                                          spreadRadius: 2,
                                        )
                                      ]),
                                );
                              }),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            'Text Instruction (Optional):',
                            style: TextStyle(fontSize: 17),
                          ),
                        ),
                        TextFormField(
                          controller: instructionController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(86, 177, 191, 1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              hintText: 'Text Instruction'),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 30),
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                            style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7)),
                            padding: EdgeInsets.all(20),
                            backgroundColor: Color.fromRGBO(8, 112, 138, 1),

                            ),
                            onPressed: createExercise,
                            child: Text(
                              'Save',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
