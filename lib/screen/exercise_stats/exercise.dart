import 'package:bodyengineer/model/program/equipment.dart';

import '../../model/planner/exercise_history.dart';
import '../../model/planner/planner_model.dart';
import '../../model/program/exercise.dart';
import '../../screen/exercise_stats/widget/graphic.dart';
import '../../screen/exercise_stats/widget/multilinegraphic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import "package:collection/collection.dart";
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user_model.dart';
import '../../model/user/user.dart';
import 'package:intl/intl.dart' as intl;

class ExerciseStats extends StatefulWidget {
  @override
  _ExerciseStatsState createState() => _ExerciseStatsState();
}

class _ExerciseStatsState extends State<ExerciseStats> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  List<Exercise> exerciseList = [];
  List<String> dateList = [];
  late List<String> _choices;
  final TextEditingController _typeAheadController = TextEditingController();
  List<ExerciseHistoryElement> exerciseHistory = [];
  List<Map<String, Map<DateTime?, List<ExerciseHistoryElement>>>>
      dateFilterExerciseHistory = [];
  List<Map<DateTime?, dynamic>> finalResult = [];
  List<Map<int?, List<Map<DateTime?, dynamic>>>> finalResultMultiple = [];
  List<Map<String, dynamic>> filteredHistory = [];
  String format = 'dd MMMM yyyy';
  List<Map<String, dynamic>> filters = [
    {'filter_name': 'Max weight', 'filter_id': 1},
    {'filter_name': 'Max Reps', 'filter_id': 2},
    {'filter_name': 'Maximal volume', 'filter_id': 3},
    {'filter_name': 'Max weight for reps', 'filter_id': 4},
    {'filter_name': 'Workout Volume', 'filter_id': 5},
    {'filter_name': 'Workout Reps', 'filter_id': 6},
    {'filter_name': '1 RM', 'filter_id': 7},
    {'filter_name': '3 RM', 'filter_id': 8},
    {'filter_name': '5 RM', 'filter_id': 9},
  ];
  String? selectedExerciseId;
  int? selectedFilterId;
  int? selectedDate;

  filterExercise() {
    if (selectedExerciseId != null && selectedFilterId != null) {
      Duration limitDuration = Duration(days: (365) * 20);
      switch (_choices[selectedDate!]) {
        case '1 m':
          limitDuration = Duration(days: 30);
          break;
        case '3 m':
          limitDuration = Duration(days: (30 * 3));

          break;
        case '6 m':
          limitDuration = Duration(days: (30 * 6));

          break;
        case '1 y':
          limitDuration = Duration(days: (30 * 12));

          break;
      }
      // bulk edit //print('********************');
      // bulk edit //print('selectedDate ==>' + selectedDate.toString());
      // bulk edit //print('selectedExerciseId ==>' + selectedExerciseId.toString());
      // bulk edit //print('filterId ==>' + selectedFilterId.toString());
      // bulk edit //print('********************');
      List<ExerciseHistoryElement> filteredExList = exerciseHistory
          .where((element) =>
              element.exerciseId == int.parse(selectedExerciseId!) &&
              element.dateTime!.isAfter(DateTime.now().subtract(limitDuration)))
          .toList();

      filteredExList.sort((a, b) => b.dateTime!.compareTo(a.dateTime!));

      late Map<DateTime?, List<ExerciseHistoryElement>> groupedExerciseHistory;
      if ([1, 2, 3, 5, 6, 7, 8, 9].contains(selectedFilterId))
        groupedExerciseHistory = groupBy(
            filteredExList, (ExerciseHistoryElement obj) => obj.dateTime);
      // bulk edit //print('DATA FİLTERED ////////////');
      // bulk edit //print(groupedExerciseHistory);

      late Map<int?, List<ExerciseHistoryElement>> groupedRepExerciseHistory;
      if ([4].contains(selectedFilterId))
        groupedRepExerciseHistory =
            groupBy(filteredExList, (ExerciseHistoryElement obj) => obj.rep);

      // bulk edit //print(exerciseHistory);
      // bulk edit //print(groupedRepExerciseHistory);
      setState(() {
        finalResult = [];
        finalResultMultiple = [];
      });
      Map<String, List<ExerciseHistoryElement>> nameStage = groupBy(
          filteredExList,
          (ExerciseHistoryElement obj) =>
              obj.name! + '****' + obj.workoutId.toString());
      dateFilterExerciseHistory = [];

      nameStage.forEach((key, value) {
        Map<DateTime?, List<ExerciseHistoryElement>> firstStageList =
            groupBy(value, (ExerciseHistoryElement obj) => obj.dateTime);
        key = key.split('****').first; // To fix multiple same date history

        dateFilterExerciseHistory.add({key: firstStageList});
      });

      // bulk edit //print(finalResult);

      switch (selectedFilterId) {
        case 1:
          //Max weight
          groupedExerciseHistory.forEach((key, value) {
            finalResult
                .add({key: value.map((e) => (e.weight! * 1)).reduce((max))});
          });
          break;
        case 2:
          //Max Reps
          groupedExerciseHistory.forEach((key, value) {
            finalResult
                .add({key: value.map((e) => (e.rep! * 1)).reduce((max))});
          });
          break;
        case 3:
          //Maximal volume
          groupedExerciseHistory.forEach((key, value) {
            finalResult
                .add({key: value.map((e) => e.rep! * e.weight!).reduce((max))});
          });
          break;
        case 4:
          //Max weight for reps
          List<Map<int?, List<Map<DateTime?, double?>>>> tempfinalList = [];

          groupedRepExerciseHistory.forEach((key, value) {
            Map<int?, List<Map<DateTime?, double?>>> tempRepMap = {};
            tempRepMap[key] = [];

            value.forEach((element) {
              Map<DateTime?, double?> tempWeightMap = {};
              tempWeightMap[element.dateTime] = element.weight;
              tempRepMap[key]!.add(tempWeightMap);
            });
            tempfinalList.add(tempRepMap);
          });
          finalResultMultiple = tempfinalList;

          break;
        case 5:
          //Workout Volume
          groupedExerciseHistory.forEach((key, value) {
            var testyilmaz =
                finalResult.where((element) => element.containsKey(key));
            // bulk edit //print(testyilmaz);
            double total = 0;
            value.forEach((e) {
              total += e.rep! * e.weight!;
            });
            finalResult.add({key: total});
          });
          break;
        case 6:
          //Workout Reps
          groupedExerciseHistory.forEach((key, value) {
            var testyilmaz =
                finalResult.where((element) => element.containsKey(key));
            // bulk edit //print(testyilmaz);
            int total = 0;
            value.forEach((e) {
              total += e.rep!;
            });
            finalResult.add({key: total});
          });
          break;
        case 7:
          List<Map<DateTime?, Map<String, dynamic>>> midResult = [];

          // bulk edit //print(groupedExerciseHistory);
          groupedExerciseHistory.forEach((key, value) {
            if (value.isNotEmpty) {
              value.sort((a, b) => b.weight!.compareTo(a.weight!));
              ExerciseHistoryElement exerciseEl = value.first;
              List<ExerciseHistoryElement> maxWeightList = value
                  .where((element) => exerciseEl.weight == element.weight)
                  .toList();
              maxWeightList.sort((a, b) => b.rep!.compareTo(a.rep!));
              ExerciseHistoryElement calcValue = maxWeightList.first;
              midResult.add({
                key: {'weight': calcValue.weight, 'rep': calcValue.rep}
              });
            }
          });
          midResult.forEach((element) {
            element.forEach((key, value) {
              double weight = value['weight'];
              int rep = value['rep'];
              finalResult.add({key: (weight * (1 + (rep / 30))).round()});
            });
          });
          break;
        case 8:
          List<Map<DateTime?, Map<String, dynamic>>> midResult = [];

          // bulk edit //print(groupedExerciseHistory);
          groupedExerciseHistory.forEach((key, value) {
            if (value.isNotEmpty) {
              value.sort((a, b) => b.weight!.compareTo(a.weight!));
              ExerciseHistoryElement exerciseEl = value.first;
              List<ExerciseHistoryElement> maxWeightList = value
                  .where((element) => exerciseEl.weight == element.weight)
                  .toList();
              maxWeightList.sort((a, b) => b.rep!.compareTo(a.rep!));
              ExerciseHistoryElement calcValue = maxWeightList.first;
              midResult.add({
                key: {'weight': calcValue.weight, 'rep': calcValue.rep}
              });
            }
          });
          midResult.forEach((element) {
            element.forEach((key, value) {
              double weight = value['weight'];
              int rep = value['rep'];
              finalResult
                  .add({key: ((weight * (1 + (rep / 30))) * 0.91).round()});
            });
          });
          break;
        case 9:
          List<Map<DateTime?, Map<String, dynamic>>> midResult = [];

          // bulk edit //print(groupedExerciseHistory);
          groupedExerciseHistory.forEach((key, value) {
            if (value.isNotEmpty) {
              value.sort((a, b) => b.weight!.compareTo(a.weight!));
              ExerciseHistoryElement exerciseEl = value.first;
              List<ExerciseHistoryElement> maxWeightList = value
                  .where((element) => exerciseEl.weight == element.weight)
                  .toList();
              maxWeightList.sort((a, b) => b.rep!.compareTo(a.rep!));
              ExerciseHistoryElement calcValue = maxWeightList.first;
              midResult.add({
                key: {'weight': calcValue.weight, 'rep': calcValue.rep}
              });
            }
          });
          midResult.forEach((element) {
            element.forEach((key, value) {
              double weight = value['weight'];
              int rep = value['rep'];
              finalResult
                  .add({key: ((weight * (1 + (rep / 30))) * 0.85).round()});
            });
          });
          break;
        default:
      }
      setState(() {
        finalResult.sort((a, b) => a.keys.first!.compareTo(b.keys.first!));
        finalResult = finalResult;
      });
      // bulk edit //print(finalResult);
      // bulk edit //print(finalResultMultiple);
    }
  }

  @override
  void initState() {
    super.initState();
    _key = GlobalKey<ScaffoldState>();
    selectedDate = 0;
    _choices = ["1 m", "3 m", "6 m", "1 y", "All"];
  }

  Widget _buildChoiceChips() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.07,
      child: ListView.builder(
        itemCount: _choices.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 3),
            child: ChoiceChip(
              padding: EdgeInsets.symmetric(horizontal: 9),
              elevation: 3,
              label: Text(_choices[index]),
              selected: selectedDate == index,
              selectedColor: Color.fromRGBO(86, 177, 191, 1),
              onSelected: (bool selected) {
                setState(() {
                  selectedDate = selected ? index : 0;
                });
                filterExercise();
              },
              backgroundColor: Colors.white,
              labelStyle: TextStyle(color: Colors.black),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    exerciseList =
        Provider.of<PlannerModel>(context, listen: true).allExerciseList;
    exerciseList.sort((a, b) => a.exerciseName!.compareTo(b.exerciseName!));
    exerciseHistory = Provider.of<PlannerModel>(context, listen: true)
        .exerciseHistory
      ..sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
    if (selectedExerciseId == null &&
        args != null &&
        args['exerciseId'] != null) {
      selectedExerciseId = args['exerciseId'].toString();
      this._typeAheadController.text = exerciseList
          .firstWhere((element) => element.exerciseId == selectedExerciseId)
          .exerciseName!;
    }
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: Offset(1, 2),
                  color: Color(0xffd6d6d6))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                  SizedBox(width: 10),
                  Text(
                    allTranslations.text('analysis')!,
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TypeAheadFormField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: this._typeAheadController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: allTranslations.text('exercise')!,
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    return exerciseList
                        .where((exe) => exe.exerciseName!
                            .toLowerCase()
                            .contains(pattern.toLowerCase()))
                        .map(
                            (e) => {'name': e.exerciseName, 'id': e.exerciseId})
                        .toList();
                  },
                  itemBuilder: (context, dynamic suggestion) {
                    return ListTile(
                      title: Text(suggestion['name']),
                    );
                  },
                  onSuggestionSelected: (dynamic suggestion) {
                    this._typeAheadController.text = suggestion['name'];
                    // bulk edit //print(suggestion['name']);
                    selectedExerciseId = suggestion['id'];
                    filterExercise();
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(allTranslations.text('filter')!),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 60,
                    child: DropdownButtonFormField(
                      validator: (dynamic value) =>
                          value == null ? 'This field is required' : null,
                      items: filters
                          .map<DropdownMenuItem<Map<String, dynamic>>>(
                              (Map<String, dynamic> value) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: value,
                          child: Text(
                            value['filter_name'],
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (Map<String, dynamic>? data) {
                        // bulk edit //print(data);
                        selectedFilterId = data!['filter_id'];
                        filterExercise();
                      },
                      icon: Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
                ],
              ),
              finalResultMultiple.isEmpty
                  ? ExerciseGraphic(finalResult)
                  : ExerciseMultilineGraphic(finalResultMultiple),
              _buildChoiceChips(),
              SizedBox(height: 20),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: dateFilterExerciseHistory.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateFilterExerciseHistory[index].keys.first,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(intl.DateFormat(format)
                                    .format(dateFilterExerciseHistory[index]
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
                            itemCount: dateFilterExerciseHistory[index]
                                .values
                                .first
                                .values
                                .first
                                .length,
                            itemBuilder: (context, i) {
                              print(exerciseList);
                              ExerciseHistoryElement exHist =
                                  dateFilterExerciseHistory[index]
                                      .values
                                      .first
                                      .values
                                      .first[i];
                              // bulk edit //print(exHist);
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  children: [
                                    if (exerciseList
                                        .firstWhere((exercise) =>
                                            exercise.exerciseId ==
                                            exHist.exerciseId.toString())
                                        .equipmentGroup
                                        .any((equipment) =>
                                            equipment.equipmentName !=
                                            'Bodyweight'))
                                      Text(exHist.weight.toString() +
                                          ' kg x ' +
                                          exHist.rep.toString() +
                                          ' reps')
                                    else
                                      Text(exHist.rep.toString() + ' reps')
                                  ],
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    );
                  }),
              Align(
                alignment: Alignment.center,
                child: Text(
                  allTranslations.text('recommendations')!,
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
