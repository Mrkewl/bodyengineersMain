import 'package:flutter/material.dart';

import 'package:animated_text_kit/animated_text_kit.dart';

import './sign_in.dart';
import './sign_up.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: null,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Image.asset('assets/images/onboarding/logo.png'),
                ),
                Container(
                  child: Image.asset(
                    'assets/images/onboarding/blackNwhite.png',
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.4,
                    fit: BoxFit.fill,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(4, -1),
                        spreadRadius: 1,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 100,
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedTextKit(
                        repeatForever: true,
                        animatedTexts: <AnimatedText>[
                          RotateAnimatedText("Track Your \nActıve Lıfestyle",
                              textStyle: TextStyle(
                                fontSize: 30,
                                fontFamily: "Staatliches",
                              ),
                              alignment: Alignment.centerLeft),
                          RotateAnimatedText("Defıne Your \nPerformance",
                              textStyle: TextStyle(
                                fontSize: 30,
                                fontFamily: "Staatliches",
                              ),
                              alignment: Alignment.centerLeft),
                        ],
                        isRepeatingAnimation: true,
                        pause: Duration(milliseconds: 500),
                      )
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'With evidence-based driven approach',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (BuildContext ctx) =>
                                        SignUpPage())),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (BuildContext ctx) =>
                                        SignInPage())),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
