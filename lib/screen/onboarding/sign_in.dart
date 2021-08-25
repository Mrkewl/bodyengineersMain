import '../../model/planner/planner_model.dart';
import '../../model/settings/settings_model.dart';
import '../../model/watch/watch_model.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../config.dart';
import '../../model/user/user_model.dart';
import '../../model/user/user.dart';
import '../../model/achievement/achievement_model.dart';
import '../../model/goal/goal_model.dart';
import 'dart:io' show Platform;

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  late bool isLoading;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  loginSuccess(UserObject user) {
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
        _scaffoldKey.currentState!.showSnackBar(SnackBar(
            content:
                Text('Your some info is missing, please fill them all..')));
        // bulk edit //print('General info missing');

        Navigator.pushNamedAndRemoveUntil(
            context, '/signupform', (route) => false);
      } else {
        // bulk edit //print('Redirect to feed');
        _scaffoldKey.currentState!
            .showSnackBar(SnackBar(content: Text('Your login is successful')));

        Navigator.pushNamedAndRemoveUntil(
            context, '/navigation', (route) => false);
      }
    } else {
      _scaffoldKey.currentState!
          .showSnackBar(SnackBar(content: Text('Your login is failed')));
      // bulk edit //print('User is null');
    }
  }

  loginFail(value) {
    // bulk edit //print('Error fail');
    _scaffoldKey.currentState!.showSnackBar(SnackBar(
        content: Text(
            'The email and password you entered did not match our records. Please re-check and try again.')));
    // bulk edit //print(value);
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<UserModel>(context, listen: false).user != null) {}
    setState(() {
      isLoading = Provider.of<UserModel>(context, listen: true).loading;
    });
    return Scaffold(
      key: _scaffoldKey,
      appBar: null,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 30),
          height: MediaQuery.of(context).size.height,
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
                        height: 60,
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
                              'Sign In',
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
                    Form(
                      autovalidateMode: AutovalidateMode.disabled,
                      key: _formKey,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter Email';
                                  }
                                  Pattern pattern =
                                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                  RegExp regex = new RegExp(pattern as String);
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                keyboardType: TextInputType.visiblePassword,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter Password';
                                  }

                                  if (value.length < 6) {
                                    return "Your Password Length Must Be Greater Than 6 Character";
                                  }
                                  return null;
                                },
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide()),
                                  labelText: 'Password',
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/forgot_password');
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Color.fromRGBO(8, 112, 138, 1),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
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
                              child: ElevatedButton(
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  backgroundColor:
                                      Color.fromRGBO(58, 145, 247, 1),
                                ),
                                onPressed: () async {
                                  await Provider.of<UserModel>(context,
                                          listen: false)
                                      .signInWithFacebook(
                                          success: loginSuccess,
                                          fail: loginFail);
                                },
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
                              child: ElevatedButton(
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  backgroundColor:
                                      Color.fromRGBO(252, 251, 251, 1),
                                ),
                                onPressed: () async {
                                  // bulk edit //print('Google Sign-in Start');
                                  // await _handleGoogleSignIn();
                                  await Provider.of<UserModel>(context,
                                          listen: false)
                                      .googleSign(
                                          success: loginSuccess,
                                          fail: loginFail);
                                },
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
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            var email = _emailController.text;
                            var password = _passwordController.text;

                            await Provider.of<UserModel>(context, listen: false)
                                .login(
                                    email: email,
                                    password: password,
                                    fail: loginFail,
                                    success: loginSuccess);
                            _scaffoldKey.currentState!.showSnackBar(
                                SnackBar(content: Text('Please Wait..')));
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
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromRGBO(86, 177, 191, 1),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
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
