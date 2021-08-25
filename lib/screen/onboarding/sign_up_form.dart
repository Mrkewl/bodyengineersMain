import '../../helper/json_helper.dart';
import '../../model/user/region_country.dart';
import 'package:flutter/material.dart';
import '../../model/planner/planner_model.dart';
import '../../model/settings/settings_model.dart';
import '../../model/watch/watch_model.dart';
import 'package:provider/provider.dart';

import '../../model/user/user_model.dart';
import '../../model/user/user.dart';
import '../../model/achievement/achievement_model.dart';
import '../../model/goal/goal_model.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  int? selectedGenderRadio = 2;
  DateTime selectedDate = DateTime(2000, 01, 01);
  int? selectedUnitRadio = 1;
  String weight = '';
  String height = '';
  String bmi = '';
  int? countryId;
  int? regionId;
  late bool isLoading;

  bool? dontKnowBF = false;
  List<Country>? listCountry = [
    Country(name: 'Singapore', id: 1),
    Country(name: 'Turkey', id: 2),
  ];
  List<Region> listRegion = [];
  List<Region>? constListRegion = [
    Region(name: 'Singapore', id: 1, countryId: 1),
    Region(name: 'Clementy', id: 2, countryId: 1),
    Region(name: 'İstanbul', id: 3, countryId: 2),
    Region(name: 'Ankara', id: 4, countryId: 2),
    Region(name: 'İzmir', id: 5, countryId: 2),
  ];

  Future<void> getCountryAndRegion() async {
    listCountry = await JsonHelper().getCountries();
    listRegion = await JsonHelper().getRegions();
  }

  setGenderRadio(int? val) {
    setState(() {
      selectedGenderRadio = val;
    });
  }

  setUnitRadio(int? val) {
    setState(() {
      selectedUnitRadio = val;
    });
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1940),
      lastDate: DateTime(DateTime.now().year - 15),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color.fromRGBO(8, 112, 138, 1),
              surface: Color.fromRGBO(86, 177, 191, 1),
            ),
          ),
          child: child!,
        );
      },
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  generalInfoSuccess(UserObject user) {
    // bulk edit //print('Register Success ->');
    // bulk edit //print(user);
    if (user != null) {
      // bulk edit //print('User is not null');
      if (!user.isGeneralInfoFilled!) {
        // bulk edit //print('General info missing');
      } else {
        Provider.of<UserModel>(context, listen: false).appInit();
        Provider.of<PlannerModel>(context, listen: false).appInit();
        Provider.of<WatchModel>(context, listen: false).appInit();
        Provider.of<SettingsModel>(context, listen: false).appInit();
        Provider.of<GoalModel>(context, listen: false).appInit();
        Provider.of<AchievementModel>(context, listen: false).appInit();
        // bulk edit //print('Redirect to feed');
        Navigator.pushNamedAndRemoveUntil(
            context, '/navigation', (route) => false);
      }
    } else {
      // bulk edit //print('User is null');
    }
  }

  bool isDouble(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  bool isInt(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
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
    listCountry = Provider.of<UserModel>(context, listen: false).listCountry;
    constListRegion = Provider.of<UserModel>(context, listen: false).listRegion;
    if (listCountry!.isNotEmpty)
      listCountry!.sort(
          (a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
    if (constListRegion!.isNotEmpty)
      constListRegion!.sort(
          (a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
    setState(() {
      isLoading = Provider.of<UserModel>(context, listen: true).loading;
    });
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child:
                              Image.asset('assets/images/onboarding/logo.png'),
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
                                  onTap: () async {
                                    await Provider.of<UserModel>(context,
                                            listen: false)
                                        .logOut();
                                    await Provider.of<PlannerModel>(context,
                                            listen: false)
                                        .logOut();
                                    await Provider.of<WatchModel>(context,
                                            listen: false)
                                        .logOut();
                                    await Provider.of<GoalModel>(context,
                                            listen: false)
                                        .logOut();
                                    await Provider.of<AchievementModel>(context,
                                            listen: false)
                                        .logOut();

                                    await Navigator.pushNamedAndRemoveUntil(
                                        context, '/welcome', (route) => false);
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Personal Information',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Gender'),
                                  Row(
                                    children: [
                                      Radio(
                                        value: 1,
                                        groupValue: selectedGenderRadio,
                                        onChanged: (dynamic val) =>
                                            setGenderRadio(val),
                                        activeColor:
                                            Color.fromRGBO(8, 112, 138, 1),
                                      ),
                                      Text('Male'),
                                      SizedBox(width: 5),
                                      Radio(
                                        value: 2,
                                        groupValue: selectedGenderRadio,
                                        onChanged: (dynamic val) =>
                                            setGenderRadio(val),
                                        activeColor:
                                            Color.fromRGBO(8, 112, 138, 1),
                                      ),
                                      Text('Female')
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date of Birth'),
                                  GestureDetector(
                                    onTap: () => _selectDate(context),
                                    child: TextField(
                                      controller: TextEditingController()
                                        ..text = selectedDate.day.toString() +
                                            '/' +
                                            selectedDate.month.toString() +
                                            '/' +
                                            selectedDate.year.toString(),
                                      onChanged: (text) => {
                                        text = selectedDate.day.toString() +
                                            '/' +
                                            selectedDate.month.toString() +
                                            '/' +
                                            selectedDate.year.toString()
                                      },
                                      enabled: false,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: Colors.black87, width: 1),
                                        ),
                                        disabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)),
                                          borderSide: BorderSide(
                                              width: 1, color: Colors.black87),
                                        ),
                                        suffixIcon:
                                            Icon(Icons.keyboard_arrow_down),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Country/Region'),
                                  if (listCountry != null)
                                    DropdownButtonFormField(
                                      validator: (dynamic value) =>
                                          value == null
                                              ? 'This field is required'
                                              : null,
                                      items: listCountry!
                                          .map<DropdownMenuItem<Country>>(
                                              (Country value) {
                                        return DropdownMenuItem<Country>(
                                          value: value,
                                          child: Text(
                                            value.name!,
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (Country? data) {
                                        setState(() {
                                          countryId = data!.id;
                                          regionId = null;
                                          listRegion = constListRegion!
                                              .where((element) =>
                                                  element.countryId ==
                                                  countryId)
                                              .toList();
                                        });
                                      },
                                      icon: Icon(Icons.keyboard_arrow_down),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black87,
                                              width: 1.0),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('State'),
                                  DropdownButtonFormField(
                                    validator: (dynamic value) => value == null
                                        ? 'This field is required'
                                        : null,
                                    items: listRegion
                                        .map<DropdownMenuItem<int>>(
                                            (Region value) {
                                      return DropdownMenuItem<int>(
                                        value: value.id,
                                        child: Text(
                                          value.name!,
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (int? data) {
                                      setState(() {
                                        regionId = data;
                                      });
                                    },
                                    value: regionId ?? null,
                                    isDense: true,
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black87, width: 1.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'How do you want your units? (Height/Weight)'),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Radio(
                                            value: 1,
                                            groupValue: selectedUnitRadio,
                                            onChanged: (dynamic val) =>
                                                setUnitRadio(val),
                                            activeColor:
                                                Color.fromRGBO(8, 112, 138, 1),
                                          ),
                                          Text('cm/kg (Metrics)'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Radio(
                                            value: 2,
                                            groupValue: selectedUnitRadio,
                                            onChanged: (dynamic val) =>
                                                setUnitRadio(val),
                                            activeColor:
                                                Color.fromRGBO(8, 112, 138, 1),
                                          ),
                                          Text('ft/in/ibs (Imperial)')
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Please Key in Your Weight'),
                                  SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 75,
                                        height: 50,
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter your weight';
                                            }
                                            if (!(isInt(value))) {
                                              return 'Please enter only number';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              weight = value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Text(selectedUnitRadio == 1
                                          ? 'kg'
                                          : 'ibs'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Please Key in Your Height'),
                                  SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 75,
                                        height: 50,
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter your Height';
                                            }
                                            if (!(isInt(value))) {
                                              return 'Please enter only number';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              height = value;
                                            });
                                          },
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Text(selectedUnitRadio == 1
                                          ? 'cm'
                                          : 'inches'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Please Key in Your Bodyfat%'),
                                  SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 75,
                                        height: 50,
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          // ignore: missing_return
                                          validator: (value) {
                                            if (!dontKnowBF!) {
                                              if (value!.isEmpty) {
                                                return 'Please enter your weight';
                                              }
                                              if (!(isDouble(value))) {
                                                return 'Please enter only double';
                                              }
                                              return null;
                                            }
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              bmi = value;
                                            });
                                          },
                                          readOnly: dontKnowBF!,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Text(
                                        '%',
                                        style: TextStyle(fontSize: 17),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                                value: dontKnowBF,
                                                activeColor: Color.fromRGBO(
                                                    8, 112, 138, 1),
                                                onChanged: (bool? val) {
                                                  setState(() {
                                                    dontKnowBF = val;
                                                  });
                                                }),
                                            Text("I don't know"),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                // // bulk edit //print('GENDER =>' + selectedGenderRadio.toString());
                                // // bulk edit //print('BIRTHDAY =>' + selectedDate.toString());
                                // // bulk edit //print('countryId =>' + countryId.toString());
                                // // bulk edit //print('regionId =>' + regionId.toString());
                                // // bulk edit //print('selectedUnitRadio =>' +
                                //     selectedUnitRadio.toString());
                                // // bulk edit //print('weight =>' + weight.toString());
                                // // bulk edit //print('height =>' + height.toString());
                                // // bulk edit //print('bmi   =>' + bmi.toString());
                                if (_formKey.currentState!.validate()) {
                                  Map<String, dynamic> data = {
                                    'user_gender': selectedGenderRadio,
                                    'user_birthday': selectedDate.toString(),
                                    'country_id': countryId,
                                    'region_id': regionId,
                                    'unit_of_measerument': selectedUnitRadio,
                                    'user_kilo': weight,
                                    'user_length': height,
                                    'user_bmi': !dontKnowBF! ? bmi : 0,
                                  };
                                  Provider.of<UserModel>(context, listen: false)
                                      .setGeneralInfo(
                                          data: data,
                                          success: generalInfoSuccess,
                                          fail: generalInfoSuccess);
                                  // // bulk edit //print(data);
                                }
                              },
                              child: isLoading
                                  ? CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                    )
                                  : Text(
                                      'Continue',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
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
