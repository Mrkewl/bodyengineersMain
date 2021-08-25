import 'package:flutter/material.dart';

class DesignRouter extends StatefulWidget {
  @override
  _DesignRouterState createState() => _DesignRouterState();
}

class _DesignRouterState extends State<DesignRouter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                  child: Text('Opening'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/opening');
                  }),
              RaisedButton(
                child: Text('Welcome'),
                onPressed: () {
                  Navigator.pushNamed(context, '/welcome');
                },
              ),
              RaisedButton(
                child: Text('Navigation'),
                onPressed: () {
                  Navigator.pushNamed(context, '/navigation');
                },
              ),
              RaisedButton(
                child: Text('Body Stats'),
                onPressed: () {
                  Navigator.pushNamed(context, '/bs_menu');
                },
              ),
              RaisedButton(
                child: Text('Video Tutorial'),
                onPressed: () {
                  Navigator.pushNamed(context, '/video_tutorial');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
