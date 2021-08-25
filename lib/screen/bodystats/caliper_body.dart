import '../../model/planner/bodystatsDay.dart';
import '../../model/planner/measurement.dart';
import '../../screen/bodystats/widget/caliper_body_element.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';

class CaliperBodyFatPage extends StatefulWidget {
  @override
  _CaliperBodyFatPageState createState() => _CaliperBodyFatPageState();
}

class _CaliperBodyFatPageState extends State<CaliperBodyFatPage> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  PageController? _pageController;
  static const _kDuration = const Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;
  int currentIndex = 0;
  // TextEditingController _firstValue = TextEditingController();
  // TextEditingController _secondValue = TextEditingController();
  // TextEditingController _thirdValue = TextEditingController();
  bool didChange = false;
  List<Map<String, dynamic>>? measurementList;
  String measurementUnit = '';
  bool? isLoading;
  List<Map<String, dynamic>> newData = [];
  List<Measurement> dataList = [];
  DateTime? date;
  BodystatsDay? bodystatsDay;
  Function? bodystatsDayCallback;
  late SharedPreferences prefs;
  UserObject? user;
  int? bodyfatValue;
  bool showBodyfatValue = false;
  bool isEdit = true;

  successMessage(BuildContext context) {
    Widget okButton = TextButton(
      child: Text(
        "Great!",
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text("Caliper Body Fat"),
      content: Text('Your Caliper Body Fat has been updated successfully.'),
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

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      setState(() {
        measurementUnit = prefs.getInt('unit') == 1 ? 'cm' : 'in';
      });
    });
    super.initState();
    _pageController = PageController();
  }

  onChangedFunction(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  nextFunction() {
    _pageController!.nextPage(duration: _kDuration, curve: _kCurve);
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  showAlertDialog(BuildContext context) {
    Widget okButton = TextButton(
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

  inputChangeCallback(measurement) {
    bodystatsDay!.measurements
        .removeWhere((element) => element.name == measurement.name);
    bodystatsDay!.measurements.add(measurement);
    bodystatsDayCallback!(bodystatsDay);
  }

  calculateBodyfat() {
    int age = DateTime.now().year - user!.birthday!.year;
    int? gender = user!.gender;
    bodyfatValue =
        int.parse(bodystatsDay!.calculateCaliperBodyFat(gender, age));
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    user = Provider.of<UserModel>(context, listen: true).user;
    measurementUnit = user!.unitOfMeasurementId == 1 ? 'mm' : 'in';

    if (bodystatsDay == null) {
      bodystatsDay = args!['bodystatsDay'];
    }
    if (bodystatsDayCallback == null) {
      bodystatsDayCallback = args!['bodystatsDayCallback'];
    }
    dataList = bodystatsDay!.measurements;

    // bulk edit //print(dataList);

    return Scaffold(
        key: _key,
        appBar: setAppBar(_key) as PreferredSizeWidget?,
        drawer: buildProfileDrawer(context, user),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
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
                        'Caliper Body Fat',
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
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Stack(
                    children: [
                      PageView(
                        controller: _pageController,
                        onPageChanged: onChangedFunction,
                        children: [
                          Column(
                            children: [
                              Container(
                                child: Image.asset(
                                  'assets/images/bodystats/caliper1.png',
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Indicator(
                                    positionIndex: 0,
                                    currentIndex: currentIndex,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Indicator(
                                    positionIndex: 1,
                                    currentIndex: currentIndex,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Indicator(
                                    positionIndex: 2,
                                    currentIndex: currentIndex,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                child: Image.asset(
                                  'assets/images/bodystats/caliper2.png',
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Indicator(
                                    positionIndex: 0,
                                    currentIndex: currentIndex,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Indicator(
                                    positionIndex: 1,
                                    currentIndex: currentIndex,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Indicator(
                                    positionIndex: 2,
                                    currentIndex: currentIndex,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                child: Image.asset(
                                  'assets/images/bodystats/caliper3.png',
                                  height:
                                      MediaQuery.of(context).size.height * 0.4,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Indicator(
                                    positionIndex: 0,
                                    currentIndex: currentIndex,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Indicator(
                                    positionIndex: 1,
                                    currentIndex: currentIndex,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Indicator(
                                    positionIndex: 2,
                                    currentIndex: currentIndex,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                user!.gender == 1
                    ? Column(
                        children: [
                          CaliperBodyElement(
                            changeCallback: inputChangeCallback,
                            name: 'Abdomen',
                            measurementUnit: measurementUnit,
                            listMeasurement: dataList,
                            inputKey: 'abdomen',
                            isEdit: isEdit,
                          ),
                          CaliperBodyElement(
                            changeCallback: inputChangeCallback,
                            name: 'Chest C',
                            measurementUnit: measurementUnit,
                            listMeasurement: dataList,
                            inputKey: 'caliper_chest',
                            isEdit: isEdit,
                          ),
                          CaliperBodyElement(
                            changeCallback: inputChangeCallback,
                            name: 'Thighs',
                            measurementUnit: measurementUnit,
                            listMeasurement: dataList,
                            inputKey: 'caliper_thighs',
                            isEdit: isEdit,
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          CaliperBodyElement(
                            changeCallback: inputChangeCallback,
                            name: 'Triceps',
                            measurementUnit: measurementUnit,
                            listMeasurement: dataList,
                            inputKey: 'caliper_triceps',
                            isEdit: isEdit,
                          ),
                          CaliperBodyElement(
                            changeCallback: inputChangeCallback,
                            name: 'Suprailiac',
                            measurementUnit: measurementUnit,
                            listMeasurement: dataList,
                            inputKey: 'suprailiac',
                            isEdit: isEdit,
                          ),
                          CaliperBodyElement(
                            changeCallback: inputChangeCallback,
                            name: 'Thighs',
                            measurementUnit: measurementUnit,
                            listMeasurement: dataList,
                            inputKey: 'caliper_thighs',
                            isEdit: isEdit,
                          ),
                        ],
                      ),
                Visibility(
                  visible: showBodyfatValue,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Material(
                      elevation: 7,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Body Fat Percentage',
                                style: TextStyle(fontSize: 17),
                              ),
                              Text(bodyfatValue.toString() + '%')
                            ],
                          )),
                    ),
                  ),
                ),
                isEdit
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                          ),
                          onPressed: () async {
                            calculateBodyfat();
                            setState(() {
                              showBodyfatValue = true;
                              isEdit = false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 25),
                            child: Text(
                              'Save',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                          backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),

                          ),
                          onPressed: () async {
                            setState(() {
                              showBodyfatValue = false;
                              isEdit = true;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 25),
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ));
  }
}

class Indicator extends StatelessWidget {
  final int? positionIndex, currentIndex;
  const Indicator({this.currentIndex, this.positionIndex});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      width: 12,
      decoration: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(86, 177, 191, 1)),
          color: positionIndex == currentIndex
              ? Color.fromRGBO(86, 177, 191, 1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100)),
    );
  }
}
