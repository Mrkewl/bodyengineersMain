import '../../model/planner/bodystatsDay.dart';
import '../../model/planner/measurement.dart';
import '../../model/planner/planner_model.dart';
import '../../model/planner/progress_photo.dart';
import '../../screen/bodystats/widget/bs_menu_item.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../be_theme.dart';
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';

class BodyStatsMenu extends StatefulWidget {
  @override
  _BodyStatsMenuState createState() => _BodyStatsMenuState();
}

class _BodyStatsMenuState extends State<BodyStatsMenu> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool isFilled = true;
  TextEditingController _weightController = TextEditingController();
  TextEditingController _bmiController = TextEditingController();
  late SharedPreferences prefs;
  List<BodystatsDay?> bodystatsDayList = [];
  BodystatsDay? bodystatsDay = BodystatsDay();
  DateTime? selectedDate;
  UserObject? user;
  MyTheme theme = MyTheme();

  bodystatsDayCallback(BodystatsDay? bodystatsDayCallbackElement) {
    setState(() {
      bodystatsDay = bodystatsDayCallbackElement;
      Provider.of<PlannerModel>(context, listen: false)
          .addBodyStatsDay(bodystatsDay: bodystatsDay);
    });
  }

  addBodyWeight(BuildContext context) {
    String measurement = Provider.of<UserModel>(context, listen: false)
                .user!
                .unitOfMeasurementId ==
            1
        ? 'kg'
        : 'lbs';
    String initValue = bodystatsDay!.measurements
            .where((element) => element.name == 'Body Weight')
            .isNotEmpty
        ? bodystatsDay!.measurements
            .where((element) => element.name == 'Body Weight')
            .first
            .value
            .toString()
        : user!.bodyWeightInKilo != null
            ? user!.bodyWeightInKilo.toString()
            : '0.0';
    Widget okButton = FlatButton(
      child: Text(
        "Save",
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        // Provider.of<UserModel>(context, listen: false)
        //     .setWeight(uid: user.uid, weight: _weightController.text);
        Measurement measurement = Measurement();
        measurement.name = 'Body Weight';
        measurement.value = double.tryParse(initValue) ??
            int.tryParse(initValue) as double? ??
            0.0;
        measurement.isImperial = prefs.get('unit') == 1 ? false : true;
        bodystatsDay!.measurements
            .removeWhere((element) => element.name == measurement.name);
        bodystatsDay!.measurements.add(measurement);
        bodystatsDayCallback(bodystatsDay);
        Navigator.pop(context);
        weightSuccessMessage(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Add Bodyweight"),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Weight:'),
          Container(
            width: 50,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: TextFormField(
              keyboardType: TextInputType.number,
              initialValue: initValue,
              onChanged: (value) {
                if (value != null && value != '') {
                  initValue = value;
                }
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0.0),
                isDense: true,
              ),
            ),
          ),
          Text(measurement)
        ],
      ),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  addBodyfat(BuildContext context) {
    String initValue = bodystatsDay!.measurements
            .where((element) => element.name == 'Body Fat')
            .isNotEmpty
        ? bodystatsDay!.measurements
            .where((element) => element.name == 'Body Fat')
            .first
            .value
            .toString()
        : user!.bodyFatPercentage != null
            ? user!.bodyFatPercentage.toString()
            : '0.0';
    Widget okButton = FlatButton(
      child: Text(
        "Save",
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        Measurement measurement = Measurement();
        measurement.name = 'Body Fat';
        measurement.value = double.tryParse(initValue) ??
            int.tryParse(initValue) as double? ??
            0.0;

        measurement.isImperial = prefs.get('unit') == 1 ? false : true;
        bodystatsDay!.measurements
            .removeWhere((element) => element.name == measurement.name);
        bodystatsDay!.measurements.add(measurement);
        bodystatsDayCallback(bodystatsDay);
        Navigator.pop(context);
        fatSuccessMessage(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Add Bodyfat %"),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('Bodyfat:'),
          Container(
            width: 50,
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: TextFormField(
              keyboardType: TextInputType.number,
              initialValue: initValue,
              onChanged: (value) {
                if (value != null && value != '') {
                  initValue = value;
                }
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(0.0),
                isDense: true,
              ),
            ),
          ),
          Text('%'),
        ],
      ),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  bodyweightOptions(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!bodystatsDay!.isInitialBodyStat)
            SizedBox(
              width: double.infinity,
              height: 40,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () {
                  Navigator.pop(context);
                  addBodyWeight(context);
                },
                child: Text(
                  allTranslations.text('add_bodyweight')!,
                  style: TextStyle(color: Colors.white),
                ),
                color: Color.fromRGBO(8, 112, 138, 1),
              ),
            ),
          if (bodystatsDay!.isInitialBodyStat)
            Text(
              'Initial Bodyweight Value Cannot be Changed.',
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/body_weight');
              },
              child: Text(
                allTranslations.text('see_bodyweight_history')!,
                style: TextStyle(color: Colors.white),
              ),
              color: Color.fromRGBO(86, 177, 191, 1),
            ),
          ),
        ],
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  bodyfatOptions(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!bodystatsDay!.isInitialBodyStat)
            SizedBox(
              width: double.infinity,
              height: 40,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () {
                  Navigator.pop(context);
                  addBodyfat(context);
                },
                child: Text(
                  allTranslations.text('add_bodyfat')!,
                  style: TextStyle(color: Colors.white),
                ),
                color: Color.fromRGBO(8, 112, 138, 1),
              ),
            ),
          if (bodystatsDay!.isInitialBodyStat)
            Text(
              'Initial Bodyfat Value Cannot be Changed.',
              textAlign: TextAlign.center,
            ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/bodyfat');
              },
              child: Text(
                allTranslations.text('see_bodyfat_history')!,
                style: TextStyle(color: Colors.white),
              ),
              color: Color.fromRGBO(86, 177, 191, 1),
            ),
          ),
        ],
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  caliperBodyfatOptions(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 40,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/caliper_bodyfat', arguments: {
                  'bodystatsDayCallback': bodystatsDayCallback,
                  'bodystatsDay': bodystatsDay
                });
              },
              child: Text(
                allTranslations.text('add_caliper')!,
                style: TextStyle(color: Colors.white),
              ),
              color: Color.fromRGBO(8, 112, 138, 1),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/caliper_history');
              },
              child: Text(
                allTranslations.text('see_caliper_history')!,
                style: TextStyle(color: Colors.black),
              ),
              color: Color.fromRGBO(86, 177, 191, 1),
            ),
          ),
        ],
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  bodyMeasurementOptions(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 40,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/body_measurement', arguments: {
                  'bodystatsDayCallback': bodystatsDayCallback,
                  'bodystatsDay': bodystatsDay
                });
              },
              child: Text(
                allTranslations.text('add_body_measurement')!,
                style: TextStyle(color: Colors.white),
              ),
              color: Color.fromRGBO(8, 112, 138, 1),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/body_measurement_history');
              },
              child: Text(
                allTranslations.text('see_body_measurement_history')!,
                style: TextStyle(color: Colors.white),
              ),
              color: Color.fromRGBO(86, 177, 191, 1),
            ),
          ),
        ],
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  progressPhotoOptions(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 40,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/progress_photo',
                    arguments: {'datetime': bodystatsDay!.dateTime});
              },
              child: Text(
                allTranslations.text('add_progress')!,
                style: TextStyle(color: Colors.white),
              ),
              color: Color.fromRGBO(8, 112, 138, 1),
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/progress_photo_history');
              },
              child: Text(
                allTranslations.text('see_progress_history')!,
                style: TextStyle(color: Colors.black),
              ),
              color: Color.fromRGBO(86, 177, 191, 1),
            ),
          ),
        ],
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  weightSuccessMessage(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text(
        "Great!",
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Bodyweight"),
      content: Text('Your bodyweight has updated successfully.'),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  fatSuccessMessage(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text(
        "Great!",
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Bodyfat"),
      content: Text('Your bodyfat has updated successfully.'),
      actions: [
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () => Navigator.pop(context),
    );

    AlertDialog alert = AlertDialog(
      contentPadding: EdgeInsets.all(15),
      actionsPadding: EdgeInsets.all(0),
      content: Text("There will be an info message withing this alert dialog"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void initState() {
    Provider.of<UserModel>(context, listen: false).getUserInfo();
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
    });
    super.initState();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _bmiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context, listen: true).user;
    bodystatsDayList =
        Provider.of<PlannerModel>(context, listen: true).bodystatsDayList;
    List<ProgressPhoto?> progressPhotoList =
        Provider.of<PlannerModel>(context, listen: true).progressPhotoList;
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (selectedDate == null) {
      setState(() {
        selectedDate = args != null && args['selectedDate'] != null
            ? args['selectedDate']
            : DateTime.now();
        if (bodystatsDayList
            .where((element) =>
                element!.dateTime ==
                DateTime(
                    selectedDate!.year, selectedDate!.month, selectedDate!.day))
            .isEmpty) {
          bodystatsDay!.dateTime = DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day);
        } else {
          bodystatsDay = bodystatsDayList
              .where((element) =>
                  element!.dateTime ==
                  DateTime(selectedDate!.year, selectedDate!.month,
                      selectedDate!.day))
              .first;
        }
      });
    }

    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Container(
          color: theme.currentTheme() == ThemeMode.dark
              ? Colors.grey[850]
              : Colors.white,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                  ),
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
                          ),
                        ),
                      ),
                      Text(
                        allTranslations.text('enter_bs')!,
                        style: TextStyle(fontSize: 20),
                      ),
                      GestureDetector(
                          onTap: () => showAlertDialog(context),
                          child: Icon(
                            Icons.info_outline,
                            size: 25,
                          )),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(selectedDate!.day.toString() +
                          '/' +
                          selectedDate!.month.toString() +
                          '/' +
                          selectedDate!.year.toString())),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => bodyweightOptions(context),
                    child: BsMenuItem(
                      isFilled: bodystatsDay!.measurements
                          .where((element) => element.name == 'Body Weight')
                          .isNotEmpty,
                      title: allTranslations.text('bodyweight')!,
                      icon: 'assets/images/bodystats/bodyweight.svg',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => bodyfatOptions(context),
                    child: BsMenuItem(
                      isFilled: bodystatsDay!.measurements
                          .where((element) => element.name == 'Body Fat')
                          .isNotEmpty,
                      title: allTranslations.text('bodyfat')!,
                      icon: 'assets/images/bodystats/bodyfat.svg',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => caliperBodyfatOptions(context),
                    child: BsMenuItem(
                      isFilled: bodystatsDay!.measurements
                          .where((measure) =>
                              measure.name == 'Abdomen' ||
                              measure.name == 'Chest C' ||
                              measure.name == 'Thighs' ||
                              measure.name == 'Triceps' ||
                              measure.name == 'Suprailiac' ||
                              measure.name == 'Thighs')
                          .isNotEmpty,
                      title: 'Caliper Bodyfat',
                      icon: 'assets/images/bodystats/caliper.svg',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => bodyMeasurementOptions(context),
                    child: BsMenuItem(
                      isFilled: bodystatsDay!.measurements
                          .where((measure) =>
                              measure.name == 'Neck' ||
                              measure.name == 'Shoulders' ||
                              measure.name == 'Chest' ||
                              measure.name == 'L Biceps' ||
                              measure.name == 'R Biceps' ||
                              measure.name == 'L Forearm' ||
                              measure.name == 'R Forearm' ||
                              measure.name == 'Waist' ||
                              measure.name == 'Hips' ||
                              measure.name == 'L Thigs' ||
                              measure.name == 'R Thighs' ||
                              measure.name == 'L Calf' ||
                              measure.name == 'R Calf')
                          .isNotEmpty,
                      title: allTranslations.text('body_measurement')!,
                      icon: 'assets/images/bodystats/body_measurement.svg',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => progressPhotoOptions(context),
                    child: BsMenuItem(
                      isFilled: progressPhotoList != null &&
                          progressPhotoList
                              .where((element) =>
                                  element!.dateTime == bodystatsDay!.dateTime)
                              .isNotEmpty,
                      title: allTranslations.text('progress_photo')!,
                      icon: 'assets/images/bodystats/progress_photo.svg',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
