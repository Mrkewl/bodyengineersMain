import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../model/program/programCategory.dart';
import '../../model/program/programLevel.dart';
import '../../model/program/program_model.dart';
import '../../translations.dart';

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  bool isSelected = false;
  double _value = 0;

  late List<ProgramCategory> subCategories;
  late List<ProgramLevel> fitnessLevel;
  List<Map<String, dynamic>> dayOfWeek = [
    {'name': '2-3 Days', 'min': 0, 'max': 3, 'isSelected': false},
    {'name': '3-4 Days', 'min': 3, 'max': 4, 'isSelected': false},
    {'name': '4+ Days', 'min': 5, 'max': 7, 'isSelected': false},
  ];
  // List<Program> daysWeek;
  double _duration = 1;
  double _phases = 1;
  int _division = 1;

  // ignore: missing_return
  Function? clickSubCategory(String title) {
    // bulk edit //print(title);

    setState(() {
      subCategories.forEach((element) {
        element.isSelected = false;
      });
      subCategories
          .where((element) => element.categoryName == title)
          .first
          .isSelected = true;
    });
  }

  void clearSubCategory() {
    setState(() {
      subCategories.forEach((element) {
        element.isSelected = false;
      });
    });
  }

  void clearFitnessLevel() {
    setState(() {
      fitnessLevel.forEach((element) {
        element.isSelected = false;
      });
    });
  }

  void clearDayofWeek() {
    setState(() {
      dayOfWeek.forEach((element) {
        element['isSelected'] = false;
      });
    });
  }

  // ignore: missing_return
  Function? clickFitnessLevel(String title) {
    // bulk edit //print(title);

    setState(() {
      fitnessLevel.forEach((element) {
        element.isSelected = false;
      });
      fitnessLevel
          .where((element) => element.levelName == title)
          .first
          .isSelected = true;
    });
  }

  // ignore: missing_return
  Function? clickDayofWeek(String title) {
    // bulk edit //print(title);

    setState(() {
      dayOfWeek.forEach((element) {
        element['isSelected'] = false;
      });
      dayOfWeek
          .where((element) => element['name'] == title)
          .first['isSelected'] = true;
    });
  }

  // Function clickDaysWeek(String title) {
  //   // bulk edit //print(title);

  //   setState(() {
  //     daysWeek.forEach((element) {
  //       element.isSelected = false;
  //     });
  //     daysWeek.where((element) => element == title).first.isSelected = true;
  //   });
  // }

  void _changeDuration(double value) {
    // bulk edit //print('duration ===>' + value.toString());
    setState(() {
      _duration = value.round().toDouble();
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

  @override
  Widget build(BuildContext context) {
    subCategories = Provider.of<ProgramModel>(context, listen: false)
        .programCategoryList
        .where((element) => element.categoryParentId != '0')
        .toList();
    fitnessLevel = Provider.of<ProgramModel>(context, listen: false)
        .programLevelList
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('filter')!.toUpperCase()),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Color.fromRGBO(86, 177, 191, 1),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.close,
            color: Colors.black,
          ),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 10),
        //     child: GestureDetector(
        //       onTap: () {
        //         Navigator.pushNamed(context, '/filtered_programs');
        //       },
        //       child: Icon(
        //         Icons.search,
        //         color: Colors.black,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(allTranslations.text('goals')!.toUpperCase()),
                  if (subCategories
                      .where((element) => element.isSelected)
                      .isNotEmpty)
                    GestureDetector(
                      onTap: clearSubCategory,
                      child: Icon(Icons.clear),
                    )
                ],
              ),
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 2),
                shrinkWrap: true,
                itemCount: subCategories.length,
                itemBuilder: (context, index) => FilterItem(
                  title: subCategories[index].categoryName,
                  isSelected: subCategories[index].isSelected,
                  clickCallback: clickSubCategory,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Text(allTranslations.text('fitness_level')!.toUpperCase()),
                    if (fitnessLevel
                        .where((element) => element.isSelected)
                        .isNotEmpty)
                      GestureDetector(
                        onTap: clearFitnessLevel,
                        child: Icon(Icons.clear),
                      )
                  ],
                ),
              ),
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 2),
                shrinkWrap: true,
                itemCount: fitnessLevel.length,
                itemBuilder: (context, index) => FilterItem(
                  title: fitnessLevel[index].levelName,
                  isSelected: fitnessLevel[index].isSelected,
                  clickCallback: clickFitnessLevel,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Text(allTranslations.text('days_week')!),
                    if (dayOfWeek
                        .where((element) => element['isSelected'])
                        .isNotEmpty)
                      GestureDetector(
                        onTap: clearDayofWeek,
                        child: Icon(Icons.clear),
                      )
                  ],
                ),
              ),
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 2),
                shrinkWrap: true,
                itemCount: dayOfWeek.length,
                itemBuilder: (context, index) => FilterItem(
                  title: dayOfWeek[index]['name'],
                  isSelected: dayOfWeek[index]['isSelected'],
                  clickCallback: clickDayofWeek,
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 10),
              //   child: Text('GENDER'),
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 10),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceAround,
              //     children: [
              // Expanded(
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 15),
              //     child: GenderItem(
              //       title: 'Male',
              //       isSelected: isSelected,
              //     ),
              //   ),
              // ),
              // Expanded(
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 15),
              //     child: GenderItem(
              //       title: 'Female',
              //       isSelected: isSelected,
              //     ),
              //   ),
              // ),
              //     ],
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      allTranslations.text('program_duration')!.toUpperCase(),
                    ),
                    Text(
                      'Up to ' +
                          _duration.round().toString() +
                          ' ' +
                          allTranslations.text('weeks')!.toUpperCase(),
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: RaisedButton(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    onPressed: () {
                      String? categoryId;
                      if (subCategories
                          .where((element) => element.isSelected)
                          .isNotEmpty)
                        categoryId = subCategories
                            .where((element) => element.isSelected)
                            .first
                            .categoryId;
                      String? levelId;
                      if (fitnessLevel
                          .where((element) => element.isSelected)
                          .isNotEmpty)
                        levelId = fitnessLevel
                            .where((element) => element.isSelected)
                            .first
                            .levelId;
                      int? minDay = 0;
                      int? maxDay = 7;

                      if (dayOfWeek
                          .where((element) => element['isSelected'])
                          .isNotEmpty) {
                        minDay = dayOfWeek
                            .where((element) => element['isSelected'])
                            .first['min'];
                        maxDay = dayOfWeek
                            .where((element) => element['isSelected'])
                            .first['max'];
                      }

                      int maxDuration = _duration.round().toInt();

                      // bulk edit //print('categoryId ===>' + categoryId.toString());
                      // bulk edit //print('levelId ===>' + levelId.toString());
                      // bulk edit //print('minDay ===>' + minDay.toString());
                      // bulk edit //print('maxDay ===>' + maxDay.toString());
                      // bulk edit //print('maxDuration ===>' + maxDuration.toString());
                      // bulk edit //print('**** SEND FİLTER PAGE*****');
                      Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/filtered_programs',
                          (Route route) => route.settings.name == '/navigation',
                          arguments: {
                            'categoryId': categoryId,
                            'levelId': levelId,
                            'min': minDay,
                            'max': maxDay,
                            'duration': maxDuration,
                          });
                    },
                    color: Color.fromRGBO(8, 112, 138, 1),
                    child: Text(
                      allTranslations.text('search')!.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class FilterItem extends StatefulWidget {
  String? title;
  bool? isSelected;
  Function? clickCallback;
  FilterItem({this.title, this.isSelected, this.clickCallback});

  @override
  _FilterItemState createState() => _FilterItemState();
}

class _FilterItemState extends State<FilterItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () {
      // setState(() {
      //   widget.isSelected = !widget.isSelected;
      // });
      // },
      onTap: () => widget.clickCallback!(widget.title),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.28,
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
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.isSelected! ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
