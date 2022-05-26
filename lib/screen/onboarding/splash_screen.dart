import 'package:bodyengineer/model/goal/goal_model.dart';
import 'package:bodyengineer/model/planner/planner_model.dart';

import '../../model/user/user_model.dart';
import '../../model/watch/watch_model.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? isUserFilledCheck;
  bool? isUserFilled;
  bool? isCompleted;
  AssetImage? assetImage;
  @override
  void initState() {
    super.initState();
  }

  Future<void> afterComplete() async {
    return WidgetsBinding.instance.addPostFrameCallback((_) async =>
        await Navigator.pushNamedAndRemoveUntil(
            context, '/navigation', (route) => false,
            arguments: {'index': 0}));
  }

  checkInformation() async {
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        // you can use "context" here, for example:
        // await Future<String>.delayed(const Duration(seconds: 3));
        Navigator.pushNamedAndRemoveUntil(
            context, '/signupform', (route) => false));
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    isUserFilledCheck =
        Provider.of<UserModel>(context, listen: true).isUserFilledCheck;
    isUserFilled = Provider.of<UserModel>(context, listen: true).isUserFilled;
    isCompleted = Provider.of<WatchModel>(context, listen: true).isCompleted &&
        Provider.of<PlannerModel>(context, listen: true).isCompleted &&
        Provider.of<GoalModel>(context, listen: true).isCompleted;

    if (isUserFilledCheck != null &&
        isUserFilled != null &&
        isCompleted != null) {
      if (isUserFilledCheck!) {
        if (!isUserFilled!) {
          checkInformation();
        } else {
          if (isCompleted!) afterComplete();
        }
      }
    }
// loadImage();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Center(
            //   child: Container(
            //     padding: EdgeInsets.all(10),
            //     height: 300,
            //     width: 350,
            //     child: Lottie.asset('assets/json/loading.json', fit: BoxFit.cover),
            //   ),
            // ),
            /* Jazz Edit*/
            // Container(
            //     width: double.infinity,
            //     child: Image(image: assetImage,fit: BoxFit.cover,),)
            // child: AssetImage('assets/json/launchgif.gif',fit: BoxFit.cover)),
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                child: FadeInImage(
                  width: 350,
                  height: 150,
                  placeholder: MemoryImage(kTransparentImage),
                  image: AssetImage('assets/images/onboarding/logo.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
