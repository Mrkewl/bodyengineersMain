import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common_appbar.dart';
import '../common_drawer.dart';

class CalorieGoal extends StatefulWidget {
  @override
  _CalorieGoalState createState() => _CalorieGoalState();
}

class _CalorieGoalState extends State<CalorieGoal> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  TextEditingController nameController = TextEditingController();
  int _calorieTargetRadioValue = 9;
  int _weightLossRadioValue = 0;

  void _weightLossValueChange(int value) {
    setState(() {
      _weightLossRadioValue = value;

      switch (_weightLossRadioValue) {
        case 0:
          break;
        case 1:
          break;
        case 2:
          break;
        case 3:
          break;
        case 4:
          break;
        case 5:
          break;
        case 6:
          break;
        case 7:
          break;
        case 8:
          break;
      }
    });
  }

  void _calorieTargetValueChange(int value) {
    setState(() {
      _calorieTargetRadioValue = value;

      switch (_calorieTargetRadioValue) {
        case 9:
          break;
        case 10:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;

    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(right: 10, left: 10, top: 10, bottom: 50),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(width: 1, color: Colors.black38),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.arrow_back_ios)),
                  Text(
                    'Calorie Goal',
                    style: TextStyle(fontSize: 18),
                  ),
                  Container(
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Text(
                'Calories per Day Target',
                style: TextStyle(fontSize: 17),
              ),
              ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  CalorieRadio(
                    value: 0,
                    groupValue: _calorieTargetRadioValue,
                    onChanged: _calorieTargetValueChange,
                    title: "Auto Set",
                  ),
                  CalorieRadio(
                    value: 1,
                    groupValue: _calorieTargetRadioValue,
                    onChanged: _calorieTargetValueChange,
                    title: "Manual Set",
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.025),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      height: 40,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        onChanged: null,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(8, 112, 138, 1),
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      'Kcal',
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Weight Loss Goal',
                style: TextStyle(fontSize: 17),
              ),
              ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  CalorieRadio(
                    value: 0,
                    groupValue: _weightLossRadioValue,
                    onChanged: _weightLossValueChange,
                    title: "Lose 1 Kg per Week",
                  ),
                  CalorieRadio(
                    value: 1,
                    groupValue: _weightLossRadioValue,
                    onChanged: _weightLossValueChange,
                    title: "Lose 0.75 Kg per Week",
                  ),
                  CalorieRadio(
                    value: 2,
                    groupValue: _weightLossRadioValue,
                    onChanged: _weightLossValueChange,
                    title: "Lose 0.5 Kg per Week",
                  ),
                  CalorieRadio(
                    value: 3,
                    groupValue: _weightLossRadioValue,
                    onChanged: _weightLossValueChange,
                    title: "Lose 0.25 Kg per Week",
                  ),
                  CalorieRadio(
                    value: 4,
                    groupValue: _weightLossRadioValue,
                    onChanged: _weightLossValueChange,
                    title: "Maintain my current weight per Week",
                  ),
                  CalorieRadio(
                    value: 5,
                    groupValue: _weightLossRadioValue,
                    onChanged: _weightLossValueChange,
                    title: "Gain 1 Kg per Week",
                  ),
                  CalorieRadio(
                    value: 6,
                    groupValue: _weightLossRadioValue,
                    onChanged: _weightLossValueChange,
                    title: "Gain  0.75 Kg per Week",
                  ),
                  CalorieRadio(
                    value: 7,
                    groupValue: _weightLossRadioValue,
                    onChanged: _weightLossValueChange,
                    title: "Gain  0.5 Kg  per Week",
                  ),
                  CalorieRadio(
                    value: 8,
                    groupValue: _weightLossRadioValue,
                    onChanged: _weightLossValueChange,
                    title: "Gain  0.25 Kg per Week",
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Activity Level',
                    style: TextStyle(fontSize: 17),
                  ),
                  Text('According to the Smartwatch/App'),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text('Lightly Active'),
                  SizedBox(width: 15),
                  Text(
                    'Change',
                    style: TextStyle(
                      color: Color.fromRGBO(8, 112, 138, 1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class CalorieRadio extends StatelessWidget {
  int? value;
  int? groupValue;
  Function? onChanged;
  String? title;

  CalorieRadio({this.value, this.groupValue, this.onChanged, this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged as void Function(dynamic)?,
          activeColor: Color.fromRGBO(8, 112, 138, 1),
        ),
        Text(
          title!,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
