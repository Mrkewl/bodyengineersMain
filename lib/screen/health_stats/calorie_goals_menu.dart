import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common_appbar.dart';
import '../common_drawer.dart';

class CalorieGoalsMenu extends StatelessWidget {
  GlobalKey<ScaffoldState> _key = GlobalKey();

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
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
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
                    child: Icon(Icons.arrow_back_ios),
                  ),
                  Text(
                    'Calorie Goal Setting',
                    style: TextStyle(fontSize: 16),
                  ),
                  Container(),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/calorie_goal'),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Text(
                    'Update Calorie Goals',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.pushNamed(context, '/calorie_periodisation'),
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  padding: EdgeInsets.all(20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Text(
                    'Update Calorie Periodisation',
                    style: TextStyle(fontSize: 17),
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
