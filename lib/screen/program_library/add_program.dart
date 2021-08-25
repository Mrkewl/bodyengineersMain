import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../model/planner/planner_model.dart';
import '../../model/program/program.dart';
import '../../model/program/programDay.dart';
import '../../model/program/program_model.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class AddProgram extends StatefulWidget {
  @override
  _AddProgramState createState() => _AddProgramState();
}

class _AddProgramState extends State<AddProgram> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  TextEditingController _textEditingController = TextEditingController();
  DateTime selectedDate1 = DateTime.now();
  DateTime? selectedDate2;
  int? programDuration;
  int? remainingDays;
  int? programDaysPerWeek;
  bool proceedAddProgram = false;
  Program? program;
  UserObject? user;
  FirebaseAuth auth = FirebaseAuth.instance;
  Map<String, bool> isSelectedMap = {
    '1': false,
    '2': false,
    '3': false,
    '4': false,
    '5': false,
    '6': false,
    '7': false
  };
  bool isLoading = false;

  daySelectCallBack(value) {
    // bulk edit //print('Selected Day ==>');
    // bulk edit //print(value);
    isSelectedMap[value] = !isSelectedMap[value]!;
    // bulk edit //print(isSelectedMap);
    // bulk edit //print(programDaysPerWeek);
    // bulk edit //print(isSelectedMap.values.where((element) => element == true).length);
    if (isSelectedMap.values.where((element) => element == true).length !=
        programDaysPerWeek) {
      setState(() {
        proceedAddProgram = false;
      });
      // bulk edit //print('Day count not match program day per week');
    } else {
      setState(() {
        proceedAddProgram = true;
      });
      // bulk edit //print('Day count match program day per week. We can add program');
    }
    setState(() {
      remainingDays = programDaysPerWeek! -
          isSelectedMap.values.where((element) => element == true).length;
    });
  }

  _selectDate1(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDatePicker1(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDatePicker1(context);
    }
  }

  /// This builds material date picker in Android
  buildMaterialDatePicker1(
    BuildContext context,
  ) async {
    final DateTime? picked = await (showDatePicker(
      context: context,
      initialDate: selectedDate1,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child!,
        );
      },
    ));
    if (picked!.isBefore(DateTime.now())) {
      // bulk edit //print('You cannot set yesterday or before');
      return;
    }
    if (picked != null && picked != selectedDate1)
      setState(() {
        selectedDate1 = picked;
      });
  }

  /// This builds cupertion date picker in iOS
  buildCupertinoDatePicker1(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (picked) {
                if (picked.isBefore(DateTime.now())) {
                  // bulk edit //print('You cannot set yesterday or before');
                  return;
                }
                if (picked != null && picked != selectedDate1)
                  setState(() {
                    selectedDate1 = picked;
                    selectedDate2 = selectedDate1
                        .add(Duration(days: (7 * programDuration!)));
                  });
              },
              initialDateTime: selectedDate1,
              minimumYear: DateTime.now().year,
              maximumYear: 2022,
            ),
          );
        });
  }

  addProgramConfirm() async {
    setState(() {
      isLoading = true;
    });
    // bulk edit //print('Program Confirm!');
    int todayCount = DateTime.now().weekday;
    // bulk edit //print('todayCount ==>' + todayCount.toString());
    List<String> selectedDayList = [];
    isSelectedMap.forEach((key, value) {
      if (value) {
        selectedDayList.add(key);
      }
    });
    int totalDays = programDuration! * 7;
    List<DateTime> programDateList = [];
    for (var i = 0; i < selectedDate2!.difference(selectedDate1).inDays; i++) {
      DateTime date = selectedDate1.add(Duration(days: i));
      // bulk edit //print(date.weekday);
      if (selectedDayList.contains(date.weekday.toString())) {
        // bulk edit //print('startDate ===>' + date.toString());
        programDateList.add(date);
      }
    }
    // bulk edit //print('selectedDayList ==>' + selectedDayList.toString());
    // // bulk edit //print('selectedDayGapList ==>' + selectedDayGapList.toString());
    // bulk edit //print('selectedDate1 Start ==>' + selectedDate1.toString());
    // bulk edit //print('selectedDate2 End ==>' + selectedDate2.toString());
    List<ProgramDay> programDayList = [];
    program!.phaseList.forEach((phase) {
      phase.programWeek.forEach((week) {
        week.weekDays.forEach((day) {
          if (programDateList.isNotEmpty) {
            day.weekNumber = week.weekNumber;
            day.phaseNumber = phase.phaseNumber;
            day.programId = program!.programId;
            day.uid = auth.currentUser!.uid;
            day.dateTime = programDateList.first;
            day.isAddonDay = program!.isAddOn;
            day.registerDate = DateTime.now();
            programDateList.removeAt(0);
            day.equalizeUserSets();

            programDayList.add(day);
          }
        });
      });
    });

    print(programDayList);
    // // bulk edit //print(result);

    await Provider.of<PlannerModel>(context, listen: false)
        .saveProgramToPlanner(newProgramDayList: programDayList);

    await Provider.of<UserModel>(context, listen: false)
        .saveUserPrograms(int.parse(program!.programId!));

    await Provider.of<PlannerModel>(context, listen: false).setPlanner();

    Navigator.pushNamedAndRemoveUntil(context, '/navigation', (route) => false,
        arguments: {'index': 1});
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context, listen: true).user;
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    program = Provider.of<ProgramModel>(context)
        .programList
        .where((element) => element.programId == args!['programId'])
        .first;
    if (program != null && programDaysPerWeek == null) {
      setState(() {
        programDaysPerWeek = program!.programDaysPerWeek;
        remainingDays = programDaysPerWeek;
      });
    }
    if (program != null && selectedDate2 == null) {
      setState(() {
        programDuration = program!.programDuration;
        selectedDate2 =
            selectedDate1.add(Duration(days: (7 * program!.programDuration!)));
        // bulk edit //print('selectedDate2 ==>' + selectedDate2.toString());
      });
    }
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.chevron_left,
                      size: 30,
                      color: Colors.black87,
                    ),
                  ),
                  Spacer(),
                  Text(
                    allTranslations.text('details')!,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
            Container(
                alignment: Alignment.center,
                child: Text(allTranslations.text('selected_program_duration')! +
                    ' ' +
                    '${program!.programDuration}' +
                    ' ' +
                    allTranslations.text('weeks')!)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allTranslations.text('start_date')!.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: GestureDetector(
                        onTap: () => _selectDate1(context),
                        child: TextField(
                          controller: TextEditingController()
                            ..text = selectedDate1.day.toString() +
                                '/' +
                                selectedDate1.month.toString() +
                                '/' +
                                selectedDate1.year.toString(),
                          onChanged: (text) => {
                            text = selectedDate1.day.toString() +
                                '/' +
                                selectedDate1.month.toString() +
                                '/' +
                                selectedDate1.year.toString()
                          },
                          enabled: false,
                          decoration: InputDecoration(hintText: 'DD.MMM.YY'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allTranslations.text('end_date')!.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: GestureDetector(
                        // onTap: () => _selectDate2(context),
                        child: TextField(
                          controller: TextEditingController()
                            ..text = selectedDate2!.day.toString() +
                                '/' +
                                selectedDate2!.month.toString() +
                                '/' +
                                selectedDate2!.year.toString(),
                          onChanged: (text) => {
                            text = selectedDate2!.day.toString() +
                                '/' +
                                selectedDate2!.month.toString() +
                                '/' +
                                selectedDate2!.year.toString()
                          },
                          enabled: false,
                          decoration: InputDecoration(hintText: 'DD.MMM.YY'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        Text(allTranslations.text('pick_days')! + ' '),
                        remainingDays! > 0
                            ? Text(
                                allTranslations.text('please_select')! +
                                    ' ' +
                                    remainingDays.toString() +
                                    ' ' +
                                    allTranslations.text('days')!,
                                style: TextStyle(color: Colors.red),
                              )
                            : Text(
                                allTranslations.text('can_add_program')!,
                                style: TextStyle(color: Colors.green),
                              )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.1),
                          child: PickDay(
                              title: 'M',
                              isSelected: isSelectedMap['1'],
                              daySelectCallback: daySelectCallBack,
                              dayCount: '1',
                              proceedAddProgram: proceedAddProgram),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.1),
                          child: PickDay(
                              title: 'T',
                              isSelected: isSelectedMap['2'],
                              daySelectCallback: daySelectCallBack,
                              dayCount: '2',
                              proceedAddProgram: proceedAddProgram),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.1),
                          child: PickDay(
                              title: 'W',
                              isSelected: isSelectedMap['3'],
                              daySelectCallback: daySelectCallBack,
                              dayCount: '3',
                              proceedAddProgram: proceedAddProgram),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.1),
                          child: PickDay(
                              title: 'TH',
                              isSelected: isSelectedMap['4'],
                              daySelectCallback: daySelectCallBack,
                              dayCount: '4',
                              proceedAddProgram: proceedAddProgram),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.1),
                          child: PickDay(
                              title: 'F',
                              isSelected: isSelectedMap['5'],
                              daySelectCallback: daySelectCallBack,
                              dayCount: '5',
                              proceedAddProgram: proceedAddProgram),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.1),
                          child: PickDay(
                              title: 'S',
                              isSelected: isSelectedMap['6'],
                              daySelectCallback: daySelectCallBack,
                              dayCount: '6',
                              proceedAddProgram: proceedAddProgram),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.1),
                          child: PickDay(
                              title: 'S',
                              isSelected: isSelectedMap['7'],
                              daySelectCallback: daySelectCallBack,
                              dayCount: '7',
                              proceedAddProgram: proceedAddProgram),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 35),
              child: Center(
                child: Text(
                  allTranslations.text('date_can_adjusted')!,
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 35, right: 35, bottom: 20),
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.075,
                child: remainingDays! > 0
                    ? RaisedButton(
                        onPressed: () {},
                        color: Color.fromRGBO(8, 112, 138, 1),
                        child: Text(
                          allTranslations.text('please_select')! +
                              ' ' +
                              remainingDays.toString() +
                              ' ' +
                              allTranslations.text('days')!,
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : RaisedButton(
                        onPressed: addProgramConfirm,
                        color: Color.fromRGBO(8, 112, 138, 1),
                        child: isLoading
                            ? CircularProgressIndicator()
                            : Text(
                                allTranslations.text('confirm')!,
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class PickDay extends StatefulWidget {
  String? title;
  bool? isSelected;
  bool? proceedAddProgram;
  String? dayCount;
  Function? daySelectCallback;
  PickDay(
      {this.title,
      this.proceedAddProgram,
      this.isSelected,
      this.dayCount,
      this.daySelectCallback});

  @override
  _PickDayState createState() => _PickDayState();
}

class _PickDayState extends State<PickDay> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.isSelected!) {
          if (!widget.proceedAddProgram!) {
            setState(() {
              widget.daySelectCallback!(widget.dayCount);
              widget.isSelected = !widget.isSelected!;
            });
          }
        } else {
          setState(() {
            widget.daySelectCallback!(widget.dayCount);
            widget.isSelected = !widget.isSelected!;
          });
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.12,
        height: MediaQuery.of(context).size.height * 0.05,
        decoration: BoxDecoration(
          color: widget.isSelected!
              ? Color.fromRGBO(8, 112, 138, 1)
              : Color.fromRGBO(86, 177, 191, 1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            widget.title!,
            style: TextStyle(
              color: widget.isSelected! ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
