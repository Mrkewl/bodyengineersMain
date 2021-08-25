import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:provider/provider.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/program/program_model.dart';

class CreateNewProgram extends StatefulWidget {
  @override
  _CreateNewProgramState createState() => _CreateNewProgramState();
}

class _CreateNewProgramState extends State<CreateNewProgram> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  DateTime selectedDate1 = DateTime.now();
  DateTime? selectedDate2;
  bool isSelected = false;
  double _duration = 1;
  double _phases = 1;
  int _division = 1;
  bool valid = true;
  bool validDays = true;

  Map<String, bool> isSelectedMap = {
    '1': false,
    '2': false,
    '3': false,
    '4': false,
    '5': false,
    '6': false,
    '7': false
  };

  daySelectCallBack(value) {
    setState(() {
      isSelectedMap[value] = !isSelectedMap[value]!;
    });
    _isValid();
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
    final DateTime picked = await (showDatePicker(
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
    ) as Future<DateTime>);
    if (picked.isBefore(DateTime.now())) {
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
                        .add(Duration(days: (7 * _duration.round())));
                  });
              },
              initialDateTime: selectedDate1,
              minimumYear: DateTime.now().year,
              maximumYear: 2026,
            ),
          );
        });
  }

  void _changeDuration(double value) {
    // bulk edit //print('duration ===>' + value.toString());
    setState(() {
      // if (_phases > value) {
      //   _phases = value;
      // }
      _duration = value.round().toDouble();
      _makeValidPhases(isChangeDuration: true);
      _isValid();

      selectedDate2 =
          selectedDate1.add(Duration(days: (7 * _duration.round())));
    });
  }

  void _getDivisionofPhases(value) {
    List divisons = [];

    for (var i = 1; i < _duration.round(); i++) {
      if (_duration.round() % i.toDouble() == 0) {
        divisons.add(i);
      }
    }
    setState(() {
      _division = divisons.length + 2;
    });
  }

  void _makeValidPhases({bool? isGoingtoNegative, bool? isChangeDuration}) {
    while (_duration.round() % _phases.round() != 0) {
      if (isChangeDuration!) {
        if (_phases.round() > _duration.round()) {
          setState(() {
            _phases = _duration.round().toDouble();
          });
          return;
        }
        if (_phases.round() < _duration.round()) {
          setState(() {
            _phases = _phases + 1;
          });
        } else {
          setState(() {
            _phases = _phases - 1;
          });
        }
      } else {
        if (isGoingtoNegative!) {
          if (_phases - 1 < 1) {
            setState(() {
              _phases = 1;
            });
          } else {
            setState(() {
              _phases = _phases - 1;
            });
          }
        } else {
          if (_phases + 1 > _duration || _phases > _duration) {
            setState(() {
              _phases = _duration.round().toDouble();
            });
          } else {
            setState(() {
              _phases = _phases + 1;
            });
          }
        }
      }
      // bulk edit //print('VALİDATED PHASES ==> ' + _phases.toString());
    }
  }

  void _changePhases(double value) {
    // bulk edit //print('phases ===>' + value.toString());
    bool isGoingtoNegative;
    if (value > _phases) {
      isGoingtoNegative = false;
    } else {
      isGoingtoNegative = true;
    }
    setState(() {
      _phases = value.round().toDouble();
    });

    _makeValidPhases(
        isGoingtoNegative: isGoingtoNegative, isChangeDuration: false);
    _isValid();
  }

  void _isValid() {
    setState(() {
      if (_duration.round().toInt() < _phases.round().toInt()) {
        valid = false;
      } else {
        if (_duration.round().toInt() % _phases.round().toInt() != 0) {
          valid = false;
        } else {
          valid = true;
        }
      }
      List<String> selectedDayList = [];
      isSelectedMap.forEach((key, value) {
        if (value) {
          selectedDayList.add(key);
        }
      });

      if (selectedDayList.length < 1) {
        validDays = false;
      } else {
        validDays = true;
      }
    });
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () => Navigator.pop(context),
    );

    AlertDialog alert = AlertDialog(
      title: Text("Phases Info"),
      content: Text(
          "How many segments do you want in your program duration? Program duration has to be divisible by Phases. It will be divided equally"),
      actions: [
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
    super.initState();
    _isValid();
  }

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    if (selectedDate2 == null) {
      setState(() {
        selectedDate2 =
            selectedDate1.add(Duration(days: (7 * _duration.round())));
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
                      allTranslations.text('create_new_program')!,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            allTranslations
                                .text('program_duration')!
                                .toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _duration.round().toString() +
                                ' ' +
                                allTranslations.text('weeks')!.toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: valid ? Colors.black : Colors.red),
                          ),
                        ],
                      ),
                    ),
                    Slider(
                      min: 1,
                      max: 52,
                      value: _duration,
                      onChanged: _changeDuration,
                      onChangeEnd: _getDivisionofPhases,
                    ),
                    Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Text(
                                        allTranslations
                                            .text('phase')!
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () => showAlertDialog(context),
                                        child: Icon(
                                          Icons.info_outline,
                                          color:
                                              valid ? Colors.black : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _phases.round().toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: valid ? Colors.black : Colors.red),
                                ),
                              ],
                            ),
                          ),
                          Slider(
                            min: 1,

                            // divisions: _division,
                            max: _duration.round() + 1.toDouble(),
                            value: _phases,
                            // onChangeEnd: (double value) {
                            //   int result = value.round();
                            //   if (_duration.round() % result != 0) {
                            //     setState(() {
                            //       _phases = _phases + 1;
                            //     });
                            //   }
                            // },
                            onChanged: _changePhases,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Container(
                        child: Column(
                          children: [
                            Text(
                              allTranslations.text('select_workout_days')!,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (!validDays)
                              Text(
                                allTranslations.text('select_at_least')!,
                                style: TextStyle(color: Colors.red),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right:
                                            MediaQuery.of(context).size.width *
                                                0.1),
                                    child: PickDay(
                                      title: 'M',
                                      isSelected: isSelectedMap['1'],
                                      daySelectCallback: daySelectCallBack,
                                      dayCount: '1',
                                      // proceedAddProgram: proceedAddProgram,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right:
                                            MediaQuery.of(context).size.width *
                                                0.1),
                                    child: PickDay(
                                      title: 'T',
                                      isSelected: isSelectedMap['2'],
                                      daySelectCallback: daySelectCallBack,
                                      dayCount: '2',
                                      // proceedAddProgram: proceedAddProgram,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right:
                                            MediaQuery.of(context).size.width *
                                                0.1),
                                    child: PickDay(
                                      title: 'W',
                                      isSelected: isSelectedMap['3'],
                                      daySelectCallback: daySelectCallBack,
                                      dayCount: '3',
                                      // proceedAddProgram: proceedAddProgram,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        right:
                                            MediaQuery.of(context).size.width *
                                                0.1),
                                    child: PickDay(
                                      title: 'TH',
                                      isSelected: isSelectedMap['4'],
                                      daySelectCallback: daySelectCallBack,
                                      dayCount: '4',
                                      // proceedAddProgram: proceedAddProgram,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.1),
                                  child: PickDay(
                                    title: 'F',
                                    isSelected: isSelectedMap['5'],
                                    daySelectCallback: daySelectCallBack,
                                    dayCount: '5',
                                    // proceedAddProgram: proceedAddProgram,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.1),
                                  child: PickDay(
                                    title: 'S',
                                    isSelected: isSelectedMap['6'],
                                    daySelectCallback: daySelectCallBack,
                                    dayCount: '6',
                                    // proceedAddProgram: proceedAddProgram,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.1),
                                  child: PickDay(
                                    title: 'S',
                                    isSelected: isSelectedMap['7'],
                                    daySelectCallback: daySelectCallBack,
                                    dayCount: '7',
                                    // proceedAddProgram: proceedAddProgram,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                textAlign: TextAlign.center,
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
                                decoration:
                                    InputDecoration(hintText: 'DD.MMM.YY'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                              onTap: () {},
                              child: TextField(
                                textAlign: TextAlign.center,
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
                                decoration:
                                    InputDecoration(hintText: 'DD.MMM.YY'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                child: SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.075,
                  child: ElevatedButton(
                    onPressed: () async {
                      // // bulk edit //print('Duration ==>' + _duration.round().toString());
                      // // bulk edit //print('Phases ==>' + _phases.round().toString());
                      // // bulk edit //print(
                      //     'Selected Date 1 ==>' + selectedDate1.toString());
                      // // bulk edit //print(
                      //     'Selected Date 2 ==>' + selectedDate2.toString());

                      if (valid && validDays) {
                        List<String> selectedDayList = [];
                        isSelectedMap.forEach((key, value) {
                          if (value) {
                            selectedDayList.add(key);
                          }
                        });
                        await Provider.of<ProgramModel>(context, listen: false)
                            .createNewProgram(
                          durationWeek: _duration.round().toInt(),
                          endDate: selectedDate2,
                          startDate: selectedDate1,
                          phaseCount: _phases.round().toInt(),
                          dayList: selectedDayList,
                          uid: user!.uid,
                        );
                        Navigator.pushNamed(context, '/new_program',
                            arguments: {
                              'selectedDate1': selectedDate1,
                              'selectedDate2': selectedDate2,
                              'duration': _duration.round(),
                              'phases': _phases.round(),
                            });
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                    ),
                    child: Text(
                      valid || validDays
                          ? allTranslations.text('confirm')!
                          : allTranslations.text('invalid')!,
                      style:
                          TextStyle(color: valid ? Colors.white : Colors.red),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// ignore: must_be_immutable
class PickDay extends StatefulWidget {
  String? title;
  bool? isSelected;
  // bool proceedAddProgram;
  String? dayCount;
  Function? daySelectCallback;
  PickDay(
      {this.title,
      // this.proceedAddProgram,
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
          setState(() {
            widget.daySelectCallback!(widget.dayCount);
            widget.isSelected = !widget.isSelected!;
          });
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
