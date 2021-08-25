import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../model/user/user_model.dart';
import '../../model/user/user.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordController2 = TextEditingController();
  TextEditingController _currentPasswordController = TextEditingController();
  UserObject? user;

  generalInfoSuccess(UserObject user) {
    // bulk edit //print('Register Success ->');
    // bulk edit //print(user);
    if (user != null) {
      // bulk edit //print('User is not null');
      if (!user.isGeneralInfoFilled!) {
        // bulk edit //print('General info missing');
      } else {
        // bulk edit //print('Redirect to feed');
        Navigator.pushNamedAndRemoveUntil(
            context, '/signupform', (route) => false);
      }
    } else {
      // bulk edit //print('User is null');
    }
  }

  bool isDouble(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, ((e) => null) as double Function(String)?) != null;
  }

  bool isInt(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, ((e) => null) as double Function(String)?) != null;
  }

  generalInfoFail(value) {
    // bulk edit //print('Error fail');
    // bulk edit //print(value);
  }

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context, listen: true).user;

    return Scaffold(
      key: _key,
      drawer: buildProfileDrawer(context, user),
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      body: user == null
          ? Container(
              child: Center(
                  child: Container(
                      height: 40, child: CircularProgressIndicator())))
          : SingleChildScrollView(
              child: Container(
                  child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      color: Color.fromRGBO(86, 177, 191, 1),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(
                                Icons.chevron_left,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            width: 30,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Current Password'),
                                  TextFormField(
                                    controller: _currentPasswordController,
                                    validator: (String? value) {
                                      if (value!.length < 6) {
                                        return 'Password Must Be Longer Than 6';
                                      }
                                      return null;
                                    },
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 5.0),
                                    )),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('New Password'),
                                  TextFormField(
                                    controller: _passwordController,
                                    validator: (String? value) {
                                      if (value!.length < 6) {
                                        return 'Password Must Be Longer Than 6';
                                      }
                                      if (_passwordController2.text != value) {
                                        return 'Not Match Passwords';
                                      }
                                      return null;
                                    },
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 5.0),
                                    )),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('New Password (Again)'),
                                  TextFormField(
                                    controller: _passwordController2,
                                    validator: (String? value) {
                                      if (value!.length < 6) {
                                        return 'Password Must Be Longer Than 6';
                                      }
                                      if (_passwordController.text != value) {
                                        return 'Not Match Passwords';
                                      }
                                      return null;
                                    },
                                    obscureText: true,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 5.0),
                                    )),
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
                                    // bulk edit //print('TEST TEST TEST');
                                    Provider.of<UserModel>(context,
                                            listen: false)
                                        .changePassword(
                                            currentPass:
                                                _currentPasswordController.text,
                                            newPass: _passwordController.text);
                                  }
                                },
                                child: Text(
                                  'Continue',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      Color.fromRGBO(86, 177, 191, 1),
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ),
    );
  }
}
