import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  final _picker = ImagePicker();
  File? _image;
  UserObject? user;
  TextEditingController _bioController = TextEditingController();
  bool isPrivacyHidden = false;

  changeBio(BuildContext context, UserObject user) {
    _bioController.text = user.bio!;
    Widget okButton = FlatButton(
      child: Text(
        allTranslations.text('save')!,
        style: TextStyle(fontSize: 14, color: Color.fromRGBO(8, 112, 138, 1)),
      ),
      onPressed: () async {
        await Provider.of<UserModel>(context, listen: false)
            .setUserBio(uid: user.uid, bio: _bioController.text);
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        allTranslations.text('change_profile_description')!,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            child: TextField(
              controller: _bioController,
              maxLength: 120,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(5),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black12,
                    width: 1,
                  ),
                ),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
      actions: [
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            allTranslations.text('cancel')!,
            style: TextStyle(
              fontSize: 14,
              color: Color.fromRGBO(8, 112, 138, 1),
            ),
          ),
        ),
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

  Future<void> _imgFromCamera() async {
    // ignore: deprecated_member_use
    PickedFile? image =
        await _picker.getImage(source: ImageSource.camera, imageQuality: 20);

    setState(() {
      _image = File(image!.path);
      uploadImage();
    });
  }

  Future<void> _imgFromGallery() async {
    // bulk edit //print('** Function Start **');
    final pickedFile =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 20);

    if (pickedFile != null) {
      File image = File(pickedFile.path);
      // File image = await ImagePicker.pickImage(
      //     source: ImageSource.gallery, imageQuality: 50);
      // bulk edit //print('** Image Picked **');
      setState(() {
        _image = image;
        uploadImage();
        // bulk edit //print('** State Set **');
      });
    }
  }

  void uploadImage() async {
    Provider.of<UserModel>(context, listen: false).uploadAvatar(_image!);
  }

  void resetPasswordDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Container(
                  child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    allTranslations.text('want_reset_password')!,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(
                        "We'll send you an email to reset your password. Please check your email after click on 'Reset' button."),
                  ),
                ],
              )),
              actions: [
                RaisedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    allTranslations.text('cancel')!,
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Color.fromRGBO(86, 177, 191, 1),
                ),
                RaisedButton(
                  onPressed: () {
                    Provider.of<UserModel>(context, listen: false)
                        .resetPassword();
                    Navigator.pop(context);
                  },
                  child: Text(
                    allTranslations.text('reset')!,
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Color.fromRGBO(8, 112, 138, 1),
                ),
              ],
            ));
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text(allTranslations.text('photo_library')!),
                      onTap: () async {
                        await _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading: Icon(Icons.photo_camera),
                    title: Text(allTranslations.text('camera')!),
                    onTap: () async {
                      await _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  void privacyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(allTranslations.text('privacy_settings')!),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    allTranslations.text('privacy_settings_desc')!,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        allTranslations.text('total_workouts')!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CupertinoSwitch(
                          value: user!.userPrivacy.totalWorkoutsPrivate,
                          onChanged: (value) {
                            setState(() {
                              user!.userPrivacy.totalWorkoutsPrivate = value;
                            });
                          },
                          activeColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        allTranslations.text('total_weight_lifted')!,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CupertinoSwitch(
                          value: user!.userPrivacy.totalWeightPrivate,
                          onChanged: (value) {
                            setState(() {
                              user!.userPrivacy.totalWeightPrivate = value;
                            });
                          },
                          activeColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Deadlift',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CupertinoSwitch(
                          value: user!.userPrivacy.maxDeadliftPrivate,
                          onChanged: (value) {
                            setState(() {
                              user!.userPrivacy.maxDeadliftPrivate = value;
                            });
                          },
                          activeColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Squat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CupertinoSwitch(
                          value: user!.userPrivacy.maxSquatPrivate,
                          onChanged: (value) {
                            setState(() {
                              user!.userPrivacy.maxSquatPrivate = value;
                            });
                          },
                          activeColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bench',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CupertinoSwitch(
                          value: user!.userPrivacy.maxBenchPrivate,
                          onChanged: (value) {
                            setState(() {
                              user!.userPrivacy.maxBenchPrivate = value;
                            });
                          },
                          activeColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'BodyFat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: CupertinoSwitch(
                          value: user!.userPrivacy.bodyFatPrivate,
                          onChanged: (value) {
                            setState(() {
                              user!.userPrivacy.bodyFatPrivate = value;
                            });
                          },
                          activeColor: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                RaisedButton(
                  onPressed: () {
                    Provider.of<UserModel>(context, listen: false)
                        .setPrivacy(user!.userPrivacy);
                    Navigator.pop(context);
                  },
                  child: Text(allTranslations.text('save')!),
                  color: Color.fromRGBO(8, 112, 138, 1),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context, listen: true).user;

    return Scaffold(
      key: _key,
      drawer: buildProfileDrawer(context, user),
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          children: [
            Container(
              color: Color.fromRGBO(86, 177, 191, 1),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                    allTranslations.text('profile')!.toUpperCase(),
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
            SizedBox(height: 10),
            Center(
              child: GestureDetector(
                onTap: () {
                  _showPicker(context);
                },
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Color.fromRGBO(86, 177, 191, 1),
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.file(
                            _image!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : user != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: user!.avatar != '' && user!.avatar != null
                                  ? Image.network(
                                      user!.avatar!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      child: Image.asset(
                                        'assets/images/onboarding/opening1.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(50)),
                              width: 100,
                              height: 100,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.grey[800],
                              ),
                            ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _showPicker(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  allTranslations.text('change_profile_picture')!,
                  style: TextStyle(
                    color: Color.fromRGBO(8, 112, 138, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            GestureDetector(
                onTap: () async {
                  await changeBio(context, user!);
                },
                child: Text(
                  allTranslations.text('change_description')!,
                  style: TextStyle(
                    color: Color.fromRGBO(8, 112, 138, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    allTranslations.text('activity')!,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ProfilePageCards(
                      title: allTranslations.text('total_workouts'),
                      value: user!.userStats != null
                          ? user!.userStats!.totalWorkouts.toString()
                          : '-'),
                  ProfilePageCards(
                    title: allTranslations.text('total_cardio_activities'),
                    value: '-',
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        allTranslations.text('profile_settings')!,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FlatButton(
                        onPressed: () => resetPasswordDialog(),
                        child: Text(
                          allTranslations.text('reset_password')!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  ProfilePageCards(
                    title: allTranslations.text('fullname'),
                    value: user != null ? user!.fullname ?? '' : '',
                  ),
                  ProfilePageCards(
                    title: allTranslations.text('gender'),
                    value: user != null
                        ? user!.gender == 1
                            ? 'Male'
                            : 'Female'
                        : '',
                  ),
                  ProfilePageCards(
                    title: 'Email',
                    value: user != null ? user!.email ?? '' : '',
                  ),
                  ProfilePageCards(
                    title: allTranslations.text('birthdate'),
                    value: user != null && user!.birthday != null
                        ? "${user!.birthday!.day}/${user!.birthday!.month}/${user!.birthday!.year} "
                        : '',
                  ),
                  ProfilePageCards(
                    title: allTranslations.text('location'),
                    value: user != null ? user!.country ?? '' : '',
                  ),
                  GestureDetector(
                    onTap: () => privacyDialog(),
                    child: ProfilePageCards(
                      title: allTranslations.text('privacy_settings'),
                      value: '',
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ProfilePageCards extends StatefulWidget {
  String? title;
  String? value;
  ProfilePageCards({this.title, this.value});
  @override
  _ProfilePageCardsState createState() =>
      _ProfilePageCardsState(title: title, value: value);
}

class _ProfilePageCardsState extends State<ProfilePageCards> {
  String? title;
  String? value;
  _ProfilePageCardsState({this.title, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.all(Radius.circular(7)),
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title!,
                style: TextStyle(fontSize: 17),
              ),
              Text(
                value!,
                style: TextStyle(fontSize: 17),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
