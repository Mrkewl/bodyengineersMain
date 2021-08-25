import '../../../model/planner/planner_model.dart';
import '../../../model/program/exercise.dart';
import '../../../model/user/user.dart';
import '../../../model/user/user_model.dart';
import '../../../screen/common_appbar.dart';
import '../../../screen/common_drawer.dart';
import '../../../screen/dashboard/goals/goal_exercise_item.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class GoalExerciseList extends StatefulWidget {
  @override
  _GoalExerciseListState createState() => _GoalExerciseListState();
}

class _GoalExerciseListState extends State<GoalExerciseList> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  late List<Exercise> allExerciseList;
  Function? callback;

  String searchTerm = '';
  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    if (searchTerm != '') {
      allExerciseList = Provider.of<PlannerModel>(context, listen: true)
          .allExerciseList
          .where((element) => element.exerciseName!
              .toLowerCase()
              .contains(searchTerm.toLowerCase()))
          .toList();
    } else {
      allExerciseList = Provider.of<PlannerModel>(context, listen: true)
          .allExerciseList
          .where((element) => !element.isCardio!)
          .toList();
    }

    Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    callback = args['callback'];
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Stack(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.chevron_left,
                                      size: 30,
                                      color: Colors.black87,
                                    ),
                                    Text(
                                      'Exercise Details',
                                      style: TextStyle(
                                        fontSize: 17,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                                onTap: () async {
                                  allExerciseList
                                      .where((element) => element.isSelected)
                                      .forEach((element) {
                                    element.isSelected = false;
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                )
                              ]),
                          child: TextField(
                            onChanged: (String value) {
                              setState(() {
                                searchTerm = value;
                              });
                            },
                            decoration: InputDecoration(
                              icon: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Icon(Icons.search),
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: allExerciseList.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return GoalExerciseListItem(
                                exercise: allExerciseList[index],
                                callback: callback,
                              );
                            }),
                      ),
                    ],
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
