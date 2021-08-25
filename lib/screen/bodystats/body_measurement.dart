import 'package:bodyengineer/translations.dart';

import '../../model/planner/bodystatsDay.dart';
import '../../model/planner/measurement.dart';
import '../../screen/bodystats/widget/body_measurement_element.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';

class BodyMeasurementPage extends StatefulWidget {
  @override
  _BodyMeasurementPageState createState() => _BodyMeasurementPageState();
}

class _BodyMeasurementPageState extends State<BodyMeasurementPage> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  UserObject? user;
  bool didChange = false;
  List<Map<String, dynamic>>? measurementList;
  String measurementUnit = '';
  List<Measurement> dataList = [];
  DateTime? date;
  BodystatsDay? bodystatsDay;
  Function? bodystatsDayCallback;
  late SharedPreferences prefs;
  bool isEdit = false;

  successMessage(BuildContext context) {
    Widget okButton = TextButton(
      child: Text(
        "Great!",
        style: TextStyle(color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(allTranslations.text('body_measurement')!),
      content: Text('Your Body Measurement has been updated successfully.'),
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

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context, listen: true).user;
    measurementUnit = user!.unitOfMeasurementId == 1 ? 'cm' : 'in';
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
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
                        'Enter Body Measurements',
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
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            BodyMeasurementElement(
                              changeCallback: inputChangeCallback,
                              name: 'Neck',
                              measurementUnit: measurementUnit,
                              listMeasurement: bodystatsDay!.measurements,
                              isEdit: isEdit,
                            ),
                            BodyMeasurementElement(
                              changeCallback: inputChangeCallback,
                              name: 'Shoulders',
                              measurementUnit: measurementUnit,
                              listMeasurement: bodystatsDay!.measurements,
                              isEdit: isEdit,
                            ),
                            BodyMeasurementElement(
                              changeCallback: inputChangeCallback,
                              name: 'Chest',
                              measurementUnit: measurementUnit,
                              listMeasurement: bodystatsDay!.measurements,
                              isEdit: isEdit,
                            ),
                            BodyMeasurementElement(
                              changeCallback: inputChangeCallback,
                              name: 'L Biceps',
                              measurementUnit: measurementUnit,
                              listMeasurement: bodystatsDay!.measurements,
                              isEdit: isEdit,
                            ),
                            BodyMeasurementElement(
                              changeCallback: inputChangeCallback,
                              name: 'R Biceps',
                              measurementUnit: measurementUnit,
                              listMeasurement: bodystatsDay!.measurements,
                              isEdit: isEdit,
                            ),
                            BodyMeasurementElement(
                              changeCallback: inputChangeCallback,
                              name: 'L Forearm',
                              measurementUnit: measurementUnit,
                              listMeasurement: bodystatsDay!.measurements,
                              isEdit: isEdit,
                            ),
                            BodyMeasurementElement(
                              changeCallback: inputChangeCallback,
                              name: 'R Forearm',
                              measurementUnit: measurementUnit,
                              listMeasurement: bodystatsDay!.measurements,
                              isEdit: isEdit,
                            ),
                            BodyMeasurementElement(
                              changeCallback: inputChangeCallback,
                              name: 'Waist',
                              measurementUnit: measurementUnit,
                              listMeasurement: bodystatsDay!.measurements,
                              isEdit: isEdit,
                            ),
                            BodyMeasurementElement(
                              changeCallback: inputChangeCallback,
                              name: 'Hips',
                              measurementUnit: measurementUnit,
                              listMeasurement: bodystatsDay!.measurements,
                              isEdit: isEdit,
                            ),
                            BodyMeasurementElement(
                              changeCallback: inputChangeCallback,
                              name: 'L Thigs',
                              measurementUnit: measurementUnit,
                              listMeasurement: bodystatsDay!.measurements,
                              isEdit: isEdit,
                            ),
                            BodyMeasurementElement(
                              changeCallback: inputChangeCallback,
                              name: 'R Thighs',
                              measurementUnit: measurementUnit,
                              listMeasurement: bodystatsDay!.measurements,
                              isEdit: isEdit,
                            ),
                            BodyMeasurementElement(
                              changeCallback: inputChangeCallback,
                              name: 'L Calf',
                              measurementUnit: measurementUnit,
                              listMeasurement: bodystatsDay!.measurements,
                              isEdit: isEdit,
                            ),
                            BodyMeasurementElement(
                              changeCallback: inputChangeCallback,
                              name: 'R Calf',
                              measurementUnit: measurementUnit,
                              listMeasurement: bodystatsDay!.measurements,
                              isEdit: isEdit,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.45,
                        width: MediaQuery.of(context).size.width * 0.45,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage(
                              'assets/images/bodystats/body_measurement.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              isEdit
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(
                          onPressed: () async {
                            successMessage(context);
                            setState(() {
                              isEdit = false;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Text(
                              'Save',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          )),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isEdit = true;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromRGBO(8, 112, 138, 1),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
