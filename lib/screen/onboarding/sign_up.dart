import '../../model/planner/planner_model.dart';
import '../../model/settings/settings_model.dart';
import '../../model/watch/watch_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../../config.dart';
import '../../model/user/user_model.dart';
import '../../model/user/user.dart';
import '../../model/achievement/achievement_model.dart';
import '../../model/goal/goal_model.dart';
import 'dart:io' show Platform;

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _fullnameController = TextEditingController();
  TextEditingController _pass1Controller = TextEditingController();
  TextEditingController _pass2Controller = TextEditingController();
  UserObject? user;
  late bool isLoading;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  registerSuccess(UserObject user) {
    // bulk edit //print('Register Success ->');
    // bulk edit //print(user);
    if (user != null) {
      Provider.of<UserModel>(context, listen: false).appInit();
      Provider.of<PlannerModel>(context, listen: false).appInit();
      Provider.of<WatchModel>(context, listen: false).appInit();
      Provider.of<SettingsModel>(context, listen: false).appInit();
      Provider.of<GoalModel>(context, listen: false).appInit();
      Provider.of<AchievementModel>(context, listen: false).appInit();
      // bulk edit //print('User is not null');
      if (!user.isGeneralInfoFilled!) {
        // bulk edit //print('General info missing');
        _scaffoldKey.currentState!.showSnackBar(SnackBar(
            content:
                Text('Your some info is missing, please fill them all..')));
        Navigator.pushNamedAndRemoveUntil(
            context, '/signupform', (route) => false);
      } else {
        // bulk edit //print('Redirect to feed');
        _scaffoldKey.currentState!.showSnackBar(
            SnackBar(content: Text('Your login is successfully')));
        Navigator.pushNamedAndRemoveUntil(
            context, '/navigation', (route) => false);
      }
    } else {
      // bulk edit //print('User is null');
    }
  }

  registerFail(value) {
    // bulk edit //print('Error fail');
    _scaffoldKey.currentState!
        .showSnackBar(SnackBar(content: Text('Error fail : ' + value)));
    // bulk edit //print(value);
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      isLoading = Provider.of<UserModel>(context, listen: true).loading;
    });
    return Scaffold(
      key: _scaffoldKey,
      appBar: null,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                      child: Image.asset('assets/images/onboarding/logo.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 15),
                          ],
                        ),
                        decoration: BoxDecoration(
                            color: Color.fromRGBO(8, 112, 138, 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black38,
                                offset: Offset(0, 4),
                                spreadRadius: 3,
                                blurRadius: 5,
                              )
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
              Form(
                autovalidateMode: AutovalidateMode.disabled,
                key: _formKey,
                child: Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter Email';
                            }
                            RegExp regex = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                            if (!(regex.hasMatch(value))) {
                              return "Invalid Email";
                            }
                            return null;
                          },
                          controller: _emailController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide()),
                            labelText: 'Email',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter Name';
                            }
                            // RegExp regex = RegExp('[a-zA-Z]');
                            // if (!(regex.hasMatch(value))) {
                            //   return "Invalid Name";
                            // }
                            return null;
                          },
                          inputFormatters: [
                            new FilteringTextInputFormatter.allow(
                                RegExp("[a-zA-Z ]")),
                          ],
                          controller: _fullnameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide()),
                            labelText: 'Full Name',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter Password';
                            }

                            if (value.length < 6) {
                              return "Your Password Length Must Be Greater Than 6 Character";
                            }
                            return null;
                          },
                          controller: _pass1Controller,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide()),
                            labelText: 'Password',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: TextFormField(
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter Password';
                            }

                            if (value.length < 6) {
                              return "Your Password Length Must Be Greater Than 6 Character";
                            }

                            if (_pass1Controller.text != value) {
                              return "Your password doesn't match";
                            }
                            return null;
                          },
                          controller: _pass2Controller,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide()),
                            labelText: 'Confirm Password',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 26),
                child: Column(
                  children: [
                    if (Platform.isAndroid)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 130,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                onPressed: () async {
                                  await Provider.of<UserModel>(context,
                                          listen: false)
                                      .signInWithFacebook(
                                          success: registerSuccess,
                                          fail: registerFail);
                                },
                                color: Color.fromRGBO(58, 145, 247, 1),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/onboarding/facebook.png',
                                      width: 15,
                                      height: 15,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Facebook',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 130,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                onPressed: () async {
                                  await Provider.of<UserModel>(context,
                                          listen: false)
                                      .googleSign(
                                          success: registerSuccess,
                                          fail: registerFail);
                                },
                                color: Color.fromRGBO(252, 251, 251, 1),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/onboarding/google.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Google',
                                      style: TextStyle(
                                        color: currentTheme == ThemeMode.dark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (Platform.isIOS) SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: RaisedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            var email = _emailController.text;
                            var fullname = _fullnameController.text;
                            var pass1 = _pass1Controller.text;
                            var pass2 = _pass2Controller.text;
                            // bulk edit //print('Prressed Button');
                            await Provider.of<UserModel>(context, listen: false)
                                .register(
                                    fullname: fullname,
                                    email: email,
                                    password: pass1,
                                    fail: registerFail,
                                    success: registerSuccess);
                          } else {
                            _scaffoldKey.currentState!.showSnackBar(SnackBar(
                                content: Text('Please Enter Valid Data')));
                          }
                        },
                        child: isLoading
                            ? CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              )
                            : Text(
                                'Continue',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                        color: Color.fromRGBO(86, 177, 191, 1),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
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
