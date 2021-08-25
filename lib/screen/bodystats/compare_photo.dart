import '../../model/planner/planner_model.dart';
import '../../model/planner/progress_photo.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:provider/provider.dart';

import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user_model.dart';
import '../../model/user/user.dart';

import 'package:intl/intl.dart' as intl;

class ComparePhoto extends StatefulWidget {
  @override
  _ComparePhotoState createState() => _ComparePhotoState();
}

class _ComparePhotoState extends State<ComparePhoto> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool didchange = false;
  bool isFront = true;
  bool isSide = false;
  bool isBack = false;
  File? frontBefore;
  File? frontAfter;
  File? backBefore;
  File? backAfter;
  File? sideBefore;
  File? sideAfter;
  List<ProgressPhoto?>? images;
  List<String> dateList = [];
  String? beforeDate = '';
  String? afterDate = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!didchange) {
      // bulk edit //print('Did Change ********');
      if (images != null) {
        // bulk edit //print('Images Not Null ********');
        if (images!.isNotEmpty) {
          images!.forEach((element) {
            // bulk edit //print(element);
            setState(() {});
          });
          setState(() {
            didchange = false;
          });
        }
      }
    }
  }

  changeBeforeImage() {
    if (isFront) {
      // bulk edit //print('isFront');
      // bulk edit //print(images.where((element) => element.dateTime == DateTime.parse(beforeDate)));
      setState(() {
        frontBefore = File(images!
            .where((element) => element!.dateTime == DateTime.parse(beforeDate!))
            .first!
            .front!);
      });
    }
    if (isSide) {
      // bulk edit //print('isSide');
      // bulk edit //print(images.where((element) => element.dateTime == DateTime.parse(beforeDate)));
      setState(() {
        sideBefore = File(images!
            .where((element) => element!.dateTime == DateTime.parse(beforeDate!))
            .first!
            .side!);
      });
    }
    if (isBack) {
      // bulk edit //print('isBack');
      // bulk edit //print(images.where((element) => element.dateTime == DateTime.parse(beforeDate)));
      setState(() {
        backBefore = File(images!
            .where((element) => element!.dateTime == DateTime.parse(beforeDate!))
            .first!
            .back!);
      });
    }
  }

  changeAfterImage() {
    if (isFront) {
      // bulk edit //print('isFront After');
      // bulk edit //print(images);
      // bulk edit //print('*****');
      // // bulk edit //print(images.where((element) => element['date'] == afterDate));
      frontAfter = File(images!
          .where((element) => element!.dateTime == DateTime.parse(afterDate!))
          .first!
          .front!);
    }
    if (isSide) {
      // bulk edit //print('isSide After');
      // bulk edit //print(images);
      // bulk edit //print('*****');
      // // bulk edit //print(images.where((element) => element['date'] == afterDate));
      sideAfter = File(images!
          .where((element) => element!.dateTime == DateTime.parse(afterDate!))
          .first!
          .side!);
    }
    if (isBack) {
      // bulk edit //print('isBackAfter');
      // bulk edit //print(images);
      // bulk edit //print('*****');
      // // bulk edit //print(images.where((element) => element['date'] == afterDate));
      backAfter = File(images!
          .where((element) => element!.dateTime == DateTime.parse(afterDate!))
          .first!
          .back!);
    }
  }

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    images = Provider.of<PlannerModel>(context, listen: true).progressPhotoList;
    if (images != null && dateList.isEmpty) {
      dateList.addAll(images!.map((e) => e!.dateTime.toString()));
    }
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 50,
                ),
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
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      width: 70,
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            isFront = true;
                            isSide = false;
                            isBack = false;
                          });
                        },
                        child: Text(
                          'Front',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Color.fromRGBO(8, 112, 138, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      width: 70,
                      child: RaisedButton(
                        onPressed: () {
                          setState(() {
                            isFront = false;
                            isSide = true;
                            isBack = false;
                          });
                        },
                        child: Text(
                          'Side',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Color.fromRGBO(8, 112, 138, 1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 30),
                      child: SizedBox(
                        height: 30,
                        width: 70,
                        child: RaisedButton(
                          onPressed: () {
                            setState(() {
                              isFront = false;
                              isSide = false;
                              isBack = true;
                            });
                          },
                          child: Text(
                            'Back',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Color.fromRGBO(8, 112, 138, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: isFront,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 60,
                              child: DropdownButtonFormField(
                                validator: (dynamic value) => value == null
                                    ? 'This field is required'
                                    : null,
                                items: dateList.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  DateTime dateTime = DateTime.parse(value);
                                  // bulk edit //print(dateTime);
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      intl.DateFormat('dd/MM/yyyy')
                                          .format(dateTime)
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? data) {
                                  setState(() {
                                    beforeDate = data;
                                    // bulk edit //print('***Before Date***');
                                    // bulk edit //print(beforeDate);
                                  });
                                  changeBeforeImage();
                                },
                                icon: Icon(Icons.keyboard_arrow_down),
                              ),
                            ),
                          ),
                          Container(
                            height: 280,
                            child: AspectRatio(
                              aspectRatio: 9 / 16,
                              child: frontBefore != null
                                  ? Image.file(frontBefore!)
                                  : Container(
                                      color: Color.fromRGBO(86, 177, 191, 1),
                                      child: Center(child: Text('Front')),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 60,
                              child: DropdownButtonFormField(
                                validator: (dynamic value) => value == null
                                    ? 'This field is required'
                                    : null,
                                items: dateList.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  DateTime dateTime = DateTime.parse(value);
                                  // bulk edit //print(dateTime);
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      intl.DateFormat('dd/MM/yyyy')
                                          .format(dateTime)
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? data) {
                                  setState(() {
                                    afterDate = data;
                                    // bulk edit //print('***After Date***');
                                    // bulk edit //print(afterDate);
                                  });
                                  changeAfterImage();
                                },
                                icon: Icon(Icons.keyboard_arrow_down),
                              ),
                            ),
                          ),
                          Container(
                            height: 280,
                            child: AspectRatio(
                              aspectRatio: 9 / 16,
                              child: frontAfter != null
                                  ? Image.file(frontAfter!)
                                  : Container(
                                      color: Color.fromRGBO(86, 177, 191, 1),
                                      child: Center(child: Text('Front')),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: isSide,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 60,
                              child: DropdownButtonFormField(
                                validator: (dynamic value) => value == null
                                    ? 'This field is required'
                                    : null,
                                items: dateList.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  DateTime dateTime = DateTime.parse(value);
                                  // bulk edit //print(dateTime);
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      intl.DateFormat('dd/MM/yyyy')
                                          .format(dateTime)
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? data) {
                                  setState(() {
                                    beforeDate = data;
                                    // bulk edit //print('***Before Date***');
                                    // bulk edit //print(beforeDate);
                                  });
                                  changeBeforeImage();
                                },
                                icon: Icon(Icons.keyboard_arrow_down),
                              ),
                            ),
                          ),
                          Container(
                            height: 280,
                            child: AspectRatio(
                              aspectRatio: 9 / 16,
                              child: sideBefore != null
                                  ? Image.file(sideBefore!)
                                  : Container(
                                      color: Color.fromRGBO(86, 177, 191, 1),
                                      child: Center(child: Text('Side')),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 60,
                              child: DropdownButtonFormField(
                                validator: (dynamic value) => value == null
                                    ? 'This field is required'
                                    : null,
                                items: dateList.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  DateTime dateTime = DateTime.parse(value);
                                  // bulk edit //print(dateTime);
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      intl.DateFormat('dd/MM/yyyy')
                                          .format(dateTime)
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? data) {
                                  setState(() {
                                    afterDate = data;
                                    // bulk edit //print('***After Date***');
                                    // bulk edit //print(afterDate);
                                  });
                                  changeAfterImage();
                                },
                                icon: Icon(Icons.keyboard_arrow_down),
                              ),
                            ),
                          ),
                          Container(
                            height: 280,
                            child: AspectRatio(
                              aspectRatio: 9 / 16,
                              child: sideAfter != null
                                  ? Image.file(sideAfter!)
                                  : Container(
                                      color: Color.fromRGBO(86, 177, 191, 1),
                                      child: Center(child: Text('Side')),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: isBack,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 60,
                              child: DropdownButtonFormField(
                                validator: (dynamic value) => value == null
                                    ? 'This field is required'
                                    : null,
                                items: dateList.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  DateTime dateTime = DateTime.parse(value);
                                  // bulk edit //print(dateTime);
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      intl.DateFormat('dd/MM/yyyy')
                                          .format(dateTime)
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? data) {
                                  setState(() {
                                    beforeDate = data;
                                    // bulk edit //print('***Before Date***');
                                    // bulk edit //print(beforeDate);
                                  });
                                  changeBeforeImage();
                                },
                                icon: Icon(Icons.keyboard_arrow_down),
                              ),
                            ),
                          ),
                          Container(
                            height: 280,
                            child: AspectRatio(
                              aspectRatio: 9 / 16,
                              child: backBefore != null
                                  ? Image.file(backBefore!)
                                  : Container(
                                      color: Color.fromRGBO(86, 177, 191, 1),
                                      child: Center(child: Text('Back')),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              height: 60,
                              child: DropdownButtonFormField(
                                validator: (dynamic value) => value == null
                                    ? 'This field is required'
                                    : null,
                                items: dateList.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  DateTime dateTime = DateTime.parse(value);
                                  // bulk edit //print(dateTime);
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      intl.DateFormat('dd/MM/yyyy')
                                          .format(dateTime)
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? data) {
                                  setState(() {
                                    afterDate = data;
                                    // bulk edit //print('***After Date***');
                                    // bulk edit //print(afterDate);
                                  });
                                  changeAfterImage();
                                },
                                icon: Icon(Icons.keyboard_arrow_down),
                              ),
                            ),
                          ),
                          Container(
                            height: 280,
                            child: AspectRatio(
                              aspectRatio: 9 / 16,
                              child: backAfter != null
                                  ? Image.file(backAfter!)
                                  : Container(
                                      color: Color.fromRGBO(86, 177, 191, 1),
                                      child: Center(child: Text('Back')),
                                    ),
                            ),
                          ),
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
