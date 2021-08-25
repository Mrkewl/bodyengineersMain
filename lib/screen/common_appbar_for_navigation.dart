
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';

Widget setAppBarforNavigationPage(GlobalKey<ScaffoldState> globalKey, Function changeindex) {
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
              DescribedFeatureOverlay(
                overflowMode: OverflowMode.extendBackground,
                enablePulsingAnimation: true,
                contentLocation: ContentLocation.below,
                featureId: 'feature1',
                tapTarget: const Icon(Icons.menu,),
                openDuration: Duration(seconds: 1),
                onComplete: () async {
                  //   FeatureDiscovery.completeCurrentStep(globalKey.currentContext!);
                  // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                  //  });
                  changeindex();
                  return true;
                  
                },
                // onBackgroundTap: () async {
                //   return false;
                // // },
                // onDismiss: () async {
                //   return false;
                // },
    
                title: Text(
                  'Navigation',
                  style: TextStyle(fontSize: 24),
                ),
                description: Text(
                  '''
                  Tap the menu icon to view your 
                  Profile page 
                  Manage Settings 
                  View your health Statistics 
                  Exercise Statistics 
                  Tutorial
                  Sync your smart watches.''',
                  style: TextStyle(fontFamily: 'Lato', fontSize: 16),
                ),
                backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                targetColor: Colors.white,
                textColor: Colors.white,
                child: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 30,
                  ),
                
                  onPressed: () {
                    globalKey.currentState!.openDrawer();
                  },
                ),
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
