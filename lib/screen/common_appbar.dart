
import 'package:flutter/material.dart';


Widget setAppBar(GlobalKey<ScaffoldState> globalKey) {
  return PreferredSize(
    preferredSize: Size.fromHeight(95),
    child: Container(
      color: Color(0xff2c2c2c),
      height: 87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 35, left: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 30,
                ),
              
                onPressed: () {
                  globalKey.currentState!.openDrawer();
                },
              ),
              Container(
                  width: 250,
                  child: Image.asset('assets/images/onboarding/logo.png')),
              Container(width: 40),
            ],
          ),
        ),
      ),
    ),
  );
}
