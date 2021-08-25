import '../../helper/json_helper.dart';
import '../../model/user/region_country.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../model/user/user_model.dart';
import '../../model/user/user.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

class EditProfileInfo extends StatefulWidget {
  @override
  _EditProfileInfoState createState() => _EditProfileInfoState();
}

class _EditProfileInfoState extends State<EditProfileInfo> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  TextEditingController _nameController = TextEditingController();
  UserObject? user;
  int? selectedGenderRadio = 2;
  DateTime selectedDate = DateTime(2000, 01, 01);
  int? countryId;
  int? regionId;
  late bool isLoading;
  bool isChange = false;
  bool dontKnowBF = false;
  List<Country>? listCountry = [];
  List<Region> listRegion = [];
  List<Region>? constListRegion = [];

  Future<void> getCountryAndRegion() async {
    listCountry = await JsonHelper().getCountries();
    listRegion = await JsonHelper().getRegions();
  }

  setGenderRadio(int? val) {
    setState(() {
      selectedGenderRadio = val;
    });
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1940),
      lastDate: DateTime(DateTime.now().year - 15),
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (user != null) {
      setState(() {
        _nameController.text = user!.fullname!;

        selectedGenderRadio = user!.gender;
        countryId = user!.countryId;
        regionId = user!.regionId;
      });
      setState(() {
        isChange = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    listCountry = Provider.of<UserModel>(context, listen: true).listCountry;
    constListRegion = Provider.of<UserModel>(context, listen: true).listRegion;
    user = Provider.of<UserModel>(context, listen: true).user;

    setState(() {
      isLoading = Provider.of<UserModel>(context, listen: true).loading;
    });
    return Scaffold(
      key: _key,
      drawer: buildProfileDrawer(context, user),
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      body: user == null || listCountry == null || constListRegion == null
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
                            'Edit Profile Info',
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
                                  Text('Name'),
                                  TextFormField(
                                    controller: _nameController,
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
                                            borderSide: BorderSide(),
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
                                    DropdownButtonFormField(
                                      validator: (dynamic value) => value == null
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
                                      value: listCountry!
                                          .where((element) =>
                                              element.id == user!.countryId)
                                          .first,
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: RaisedButton(
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
                                    };
                                    Provider.of<UserModel>(context,
                                            listen: false)
                                        .setGeneralInfo(
                                            data: data,
                                            success: generalInfoSuccess,
                                            fail: generalInfoSuccess);
                                    // // bulk edit //print(data);
                                  }
                                },
                                child: isLoading
                                    ? CircularProgressIndicator()
                                    : Text(
                                        'Continue',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                color: Color.fromRGBO(86, 177, 191, 1),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
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
