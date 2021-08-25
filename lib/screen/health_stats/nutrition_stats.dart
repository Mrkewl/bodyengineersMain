import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../be_theme.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class NutritionStats extends StatefulWidget {
  @override
  _NutritionStatsState createState() => _NutritionStatsState();
}

class _NutritionStatsState extends State<NutritionStats> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  MyTheme theme = MyTheme();

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;

    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: theme.currentTheme() == ThemeMode.dark
                ? Colors.grey[700]
                : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(width: 1, color: Colors.black45),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nutrition Stats',
                        style: TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: [
                          Text(
                            '11 May 2020 - 24 May 2020',
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.calendar_today,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Back',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Calories'),
                  RaisedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/calorie_goals_menu'),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    color: Color.fromRGBO(8, 112, 138, 1),
                    child: Text(
                      'Goals',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Text('Protein'),
              Text('Carbonhydrate'),
              Text('Fats'),
            ],
          ),
        ),
      ),
    );
  }
}
