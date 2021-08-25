import 'dart:io';
import 'dart:async';
import '../../helper/json_helper.dart';
import '../../helper/sqflite_helper.dart';
import '../../model/achievement/achievement.dart';
import '../../model/achievement/achievement_model.dart';
import '../../model/planner/bodystatsDay.dart';
import '../../model/planner/exercise_history.dart';
import '../../model/planner/measurement.dart';
import '../../model/program/programDay.dart';

import '../../model/user/region_country.dart';
import '../../model/user/user_stats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'dart:convert' as convert;
import '../../services/index.dart';
import './user.dart';
import '../../services/firebase.dart';
import '../../helper/tools_helper.dart';
import './user_privacy.dart';

class UserModel with ChangeNotifier {
  FirebaseApi firebaseConnection = FirebaseApi();
  FirebaseFirestore _fireStoreDataBase = FirebaseFirestore.instance;
  List<Country>? listCountry;
  List<Region>? listRegion;
  AchievementModel _achievementModel = AchievementModel();
  Future<void> getCountryAndRegion() async {
    listCountry = await JsonHelper().getCountries();
    listRegion = await JsonHelper().getRegions();
  }

  final Services _service = Services();
  List<UserObject> allUserList = [];
  UserObject? user;
  bool loggedIn = false;
  bool loading = false;
  bool isUserFilledCheck = false;
  bool isUserFilled = true;
  bool isCompleted = false;
  int? preferedUnit;

  final _sqfLiteDatabase = SqfliteHelper.instance;
  List<ProgramDay> programDayList = [];
  List<BodystatsDay> bodystatsDayList = [];
  List<ExerciseHistoryElement> exerciseHistory = [];
  UserObject? get userObjectGetter => user;
  UserModel() {
    appInit();
  }

  void appInit() async {
    getCountryAndRegion()
      ..then((value) async => {
            getUserInfo()
              ..then((value) {
                if (user != null) {
                  getAllUserBasicInfo().then((value) {
                    generateStatistics();
                    getUserPrograms();
                    getUserFriends();
                  });
                }
              })
          });
    isCompleted = true;
    notifyListeners();
  }

  Future<void> getAllUserBasicInfo() async {
    allUserList = await _service.getAllUserBasicInfo();
    notifyListeners();
  }

  Future<void> getCurrentUserStats() async {
    user!.userStats = await _service.phpGetUserStats();
    notifyListeners();
  }

  Future<void> getFriendUserStats(String? uid) async {
    if (allUserList.where((element) => element.uid == uid).isNotEmpty) {
      UserObject friendUser =
          allUserList.firstWhere((element) => element.uid == uid);
      if (friendUser.userStats == null) {
        friendUser.userStats = await _service.phpGetUserStats(uid: uid);
        UserPrivacy userPrivacy = await _service.getUserPrivacy(uid: uid);
        print(userPrivacy);
        friendUser.userStats!.userPrivacy = userPrivacy;

        allUserList.firstWhere((element) => element.uid == uid).userStats =
            friendUser.userStats;
        notifyListeners();
      }
    }
  }

  Future<void> setPrivacy(UserPrivacy userPrivacy) async {
    await _service.phpSetPrivacy(userPrivacy);
  }

  Future<void> sendBodyStats() async {
    await _service.phpTransferUserStats(user!.userStats);
  }

  Future<void> changePassword({String? currentPass, String? newPass}) async {
    await _service.changePassword(currentPass: currentPass, newPass: newPass);
  }

  Future<void> resetPassword() async {
    await _service.resetPassword();
  }

  Future<void> getUserInfo() async {
    if (FirebaseAuth.instance.currentUser != null) {
      // signed in
      loggedIn = true;
      user = await _service.getUserInfo(
          uid: FirebaseAuth.instance.currentUser!.uid);

      if (user!.isGeneralInfoFilled!) {
        user!.country = listCountry!
            .where((element) => element.id == user!.countryId)
            .first
            .name;
      } else {
        isUserFilled = false;
      }
      if (user != null)
        user!.userPrivacy = await _service.getUserPrivacy(uid: user!.uid);

      isUserFilledCheck = true;
      notifyListeners();
      // bulk edit //print(FirebaseAuth.instance.currentUser);
      // bulk edit //print(FirebaseAuth.instance.currentUser.uid);
      // bulk edit //print('Sign In');
    }
  }

  Future<void> getFriendPrograms(String? uid) async {
    if (allUserList.where((element) => element.uid == uid).isNotEmpty) {
      if (allUserList
              .where((element) => element.uid == uid)
              .first
              .userPrograms ==
          null) {
        allUserList.where((element) => element.uid == uid).first.userPrograms =
            await _service.phpGetUserPrograms(uid: uid);
        notifyListeners();
      }
    }
  }

  Future<void> getFriendAchievement(String? uid) async {
    if (allUserList.where((element) => element.uid == uid).isNotEmpty) {
      if (allUserList
              .where((element) => element.uid == uid)
              .first
              .userAchievement ==
          null) {
        List<String?> userAchievementListId =
            await _service.phpGetAchievements(uid: uid);
        allUserList
            .where((element) => element.uid == uid)
            .first
            .userAchievement = [];
        List<Achievement> userAchievement = _achievementModel.achievementList!
            .where((element) =>
                userAchievementListId.contains(element.id.toString()))
            .toList();
        allUserList
            .where((element) => element.uid == uid)
            .first
            .userAchievement!
            .addAll(userAchievement);

        notifyListeners();
      }
    }
  }

  // ignore: missing_return
  Future<UserCredential?> signInWithFacebook(
      {required Function success, Function? fail}) async {
    try {
      loading = true;
      notifyListeners();
      // Trigger the sign-in flow
      final LoginResult? result = await FacebookAuth.instance
          .login(loginBehavior: LoginBehavior.webOnly);
      // bulk edit //print(result.status);
      // bulk edit //print(result.accessToken);
      // bulk edit //print(result.status);
      // Create a credential from the access token
      final FacebookAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(result!.accessToken!.token)
              as FacebookAuthCredential;

      // bulk edit //print(facebookAuthCredential);
      // Once signed in, return the UserCredential

      user = await _service.facebookSign(
          accessToken: facebookAuthCredential.accessToken,
          idToken: facebookAuthCredential.idToken,
          credential: facebookAuthCredential);

      notifyListeners();
      success(user);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (user!.isGeneralInfoFilled!) {
        var value = user!.unitOfMeasurementId ?? 1;
        prefs.setInt('database_unit', value);
      }
      // bulk edit //print('database_unit ===>' + prefs.getInt('database_unit').toString());
      loading = false;
      notifyListeners();
    } catch (err) {
      loading = false;
      fail!(err.toString());
      notifyListeners();
    }
  }

  Future<void> googleSign({required Function success, Function? fail}) async {
    try {
      loading = true;
      notifyListeners();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request

      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // Create a new credential
      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      ) as GoogleAuthCredential;

      user = await _service.googleSign(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
          credential: credential);
      notifyListeners();
      success(user);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (user!.isGeneralInfoFilled!) {
        var value = user!.unitOfMeasurementId ?? 1;
        prefs.setInt('database_unit', value);
      }
      // bulk edit //print('database_unit ===>' + prefs.getInt('database_unit').toString());

      // if (UserObject.id != null) {
      //   return true;
      // } else {
      //   return false;
      // }
      loading = false;
      notifyListeners();
    } catch (err) {
      loading = false;
      fail!(err.toString());
      notifyListeners();
    }
  }

  // ignore: missing_return
  followFriend({String? uid}) {
    _service.followFriend(uid: uid);
  }

  // ignore: missing_return
  unfollowFriend({String? uid}) {
    _service.unfollowFriend(uid: uid);
  }

  // ignore: missing_return
  Stream<List<UserObject>>? get userFriends {
    if (FirebaseAuth.instance.currentUser != null && allUserList.isNotEmpty) {
      return _fireStoreDataBase
          .collection('friend_list')
          .where('follower', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .map((QuerySnapshot event) => event.docs
              .map((e) => allUserList
                  .where(
                      (element) => element.uid == (e.data() as Map)['followed'])
                  .first)
              .first)
          .toList()
          .asStream();
    }
  }
  // Stream<UserObject> get getUser {
  //   if (FirebaseAuth.instance.currentUser != null && allUserList.isNotEmpty) {
  //     return _a
  //   }
  // }

  Future<void> getUserFriends() async {
    if (FirebaseAuth.instance.currentUser != null) {
      _fireStoreDataBase
          .collection('friend_list')
          .where('follower', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots()
          .listen((event) {
        // bulk edit //print(event.docs);
        List<UserObject?> streamUserList = event.docs.map((snapShot) {
          if (allUserList.isNotEmpty) {
            if (allUserList
                .where((element) => element.uid == snapShot.data()['followed'])
                .isNotEmpty) {
              // bulk edit //print(snapShot.data());
              return allUserList
                  .where(
                      (element) => element.uid == snapShot.data()['followed'])
                  .first;
            }
          }
        }).toList();
        // postStreamControl.add(streamPostList);
        if (allUserList.isNotEmpty && streamUserList.isNotEmpty) {
          syncUserFrineds(streamUserList);
        }
        // bulk edit //print(event.docChanges);
        // bulk edit //print(event.size);
        // bulk edit //print(event.size);
        // postStreamControl.add(event)
      });
    }
  }

  syncUserFrineds(List<UserObject?> userList) {
    user!.friendList = userList;
    notifyListeners();
    // bulk edit //print(user);
  }

  Future<void> setUserPreferences() async {}

  Future<void> logOut() async {
    await _service.logout();
    user = null;
    loggedIn = false;
    loading = false;
    isUserFilledCheck = false;
    isUserFilled = true;
    programDayList = [];
    bodystatsDayList = [];
    exerciseHistory = [];
    notifyListeners();
  }

  Future<void> setWeight({uid, required weight}) async {
    String convertedWeight =
        await (Tools.convertedWeightForDatabase(double.parse(weight))
            as FutureOr<String>);
    Map<String, dynamic> data = {
      'user_uid': uid,
      'user_kilo': double.parse(convertedWeight)
    };
    Map<String, dynamic>? result = await (_service.setGeneralInfo(data: data));
    if (result!['result']) {
      user!.bodyWeightInKilo = double.parse(convertedWeight);
      notifyListeners();
    }
  }

  Future<void> setUserBio({uid, bio}) async {
    Map<String, dynamic> data = {'user_uid': uid, 'user_bio': bio};
    Map<String, dynamic>? result = await (_service.setGeneralInfo(data: data));
    if (result!['result']) {
      user!.bio = bio;
      notifyListeners();
    }
  }

  Future<void> uploadAvatar(File image) async {
    String fileName = image.path.split('/').last;
    String uploadPath = "images/" + user!.uid! + '/' + fileName;
    String avatarUrl = await _service.uploadImageToFireaseStorage(
        image: image, uploadPath: uploadPath);
    if (avatarUrl != null && avatarUrl != '') {
      Map<String, String?> data = {
        'user_uid': user!.uid,
        'user_avatar': avatarUrl
      };
      await updateUserBasicInfo(data);
    }
  }

  Future<void> updateUserBasicInfo(Map<String, String?> data) async {
    Map<String, dynamic>? result =
        await _service.updateUserBasicInfo(data: data);

    if (data.containsKey('user_avatar')) {
      user!.avatar = data['user_avatar'];
    }
    if (data.containsKey('user_email')) {
      user!.email = data['user_email'];
    }
    if (data.containsKey('user_fullname')) {
      user!.fullname = data['user_fullname'];
    }
    notifyListeners();

    // // bulk edit //print('*******Result*******');
    // // bulk edit //print(result);
  }

  Future<void> setGender({uid, gender}) async {
    Map<String, dynamic> data = {'user_uid': uid, 'user_gener': gender};
    Map<String, dynamic>? result = await (_service.setGeneralInfo(data: data));
    if (result!['result']) {
      user!.gender = gender;
      notifyListeners();
    }
    // // bulk edit //print('uid ===>' + uid);
  }

  Future<void> setBmi({uid, bmi}) async {
    Map<String, dynamic> data = {'user_uid': uid, 'user_bmi': bmi};
    Map<String, dynamic>? result = await (_service.setGeneralInfo(data: data));
    if (result!['result']) {
      user!.bodyFatPercentage = double.parse(bmi);
      notifyListeners();
    }
    // // bulk edit //print('uid ===>' + uid);
    // // bulk edit //print('bmi ===>' + bmi);
  }

  Future<void> register(
      {required email,
      required password,
      fullname,
      required Function success,
      Function? fail}) async {
    try {
      // bulk edit //print('________User Model________');
      // bulk edit //print('Email =>' + email);
      // bulk edit //print('password =>' + password);
      // bulk edit //print('surname =>' + fullname);
      // bulk edit //print('________________');
      loading = true;
      notifyListeners();

      user = await _service.register(
          email: email, password: password, fullname: fullname, fail: fail);
      success(user);
      notifyListeners();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (user!.isGeneralInfoFilled!) {
        prefs.setInt(
            'database_unit', int.tryParse(user!.unitOfMeasurement) ?? 1);
      }
      // bulk edit //print('database_unit ===>' + prefs.getInt('database_unit').toString());
      loggedIn = true;
      notifyListeners();

      // await saveUserObject(UserObject);
      // await checkUserObjectLogin();
      // await getUserObjectPost();
      // await getUserObjectFriends();
      loading = false;
      notifyListeners();
    } catch (err) {
      loading = false;
      fail!(err.toString());
      notifyListeners();
    }
  }

  Future<void> forgotPassword(
      {required email, Function? success, Function? fail}) async {
    loading = true;
    notifyListeners();
    bool? isAuth = await (_service.isUserFirebaseAuth(email: email));
    if (isAuth != null) {
      if (isAuth) {
        await _service.forgotPassword(email: email);
        success!('Your reset email succesfully send');
      } else {
        fail!('Email doesn\'t match any records.');
      }
    } else {
      fail!('Email doesn\'t match any records.');
    }
    loading = false;
    notifyListeners();
  }

  Future<void> login(
      {email, password, required Function success, Function? fail}) async {
    try {
      // bulk edit //print('_______MODEL_________');
      // bulk edit //print('Email =>' + email);
      // bulk edit //print('password =>' + password);
      // bulk edit //print('________________');
      loading = true;
      notifyListeners();

      user = await _service.login(email: email, password: password, fail: fail);
      notifyListeners();
      success(user);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (user!.isGeneralInfoFilled!) {
        var value = user!.unitOfMeasurementId ?? 1;
        prefs.setInt('database_unit', value);
      }
      // bulk edit //print('database_unit ===>' + prefs.getInt('database_unit').toString());

      // if (UserObject.id != null) {
      //   return true;
      // } else {
      //   return false;
      // }
      loading = false;
      notifyListeners();
    } catch (err) {
      loading = false;
      fail!(err.toString());
      notifyListeners();
    }
  }

  Future<void> setGeneralInfo(
      {required Map<String, dynamic> data,
      Function? success,
      Function? fail}) async {
    try {
      loading = true;
      notifyListeners();

      data['user_uid'] = user!.uid;

      Map<String, dynamic>? result =
          await (_service.setGeneralInfo(data: data));
      // bulk edit //print(result);
      if (result!['result']) {
        Map<String, dynamic> newUser = data;

        newUser.addAll(user!.toBasicJson());

        newUser['general_info'] = true;

        user = UserObject.fromMysqlDatabase(newUser);
        notifyListeners();

        isUserFilled = true;
        isUserFilledCheck = true;
        success!(user);

        loading = false;
        notifyListeners();
      } else {
        fail!(result['message']);
      }
    } catch (err) {
      loading = false;
      fail!(err.toString());
      notifyListeners();
    }
  }

  saveUserPrograms(int programId) async {
    user!.userPrograms = await _service.phpAddUserProgram(programId);
    notifyListeners();
  }

  getUserPrograms() async {
    List<String?>? userPrograms = await _service.phpGetUserPrograms();
    user!.userPrograms = userPrograms ?? null;
    notifyListeners();
  }

  prepareUserStat() {
    UserStats userStats = UserStats();
    userStats.uid = user!.uid;
    userStats.totalWorkouts =
        programDayList.where((element) => element.isDayCompleted).length;

    double totalWeightFromHistory = 0;
    exerciseHistory.forEach((element) {
      totalWeightFromHistory += element.rep! * element.weight!;
    });
    userStats.totalWeight = totalWeightFromHistory.round().toInt();
    /**
           * 17 --> Romanian Deadlift
           * 29 --> Hack Squat
           * ?? --> Bench ??
           */
    List<ExerciseHistoryElement> deadLiftHistory = exerciseHistory
        .where((element) => element.exerciseId == 45)
        .toList(); //Barbell Deadlift
    List<ExerciseHistoryElement> squatHistory = exerciseHistory
        .where((element) => element.exerciseId == 41)
        .toList(); //Barbell back squat
    List<ExerciseHistoryElement> benchHistory = exerciseHistory
        .where((element) => element.exerciseId == 42)
        .toList(); //Barbell Bench Press

    userStats.maxDeadlift = deadLiftHistory.isNotEmpty
        ? deadLiftHistory
            .map<double?>((e) => e.weight)
            .reduce((a, b) => a! > b! ? a : b) // TODO : check for null safety
        : 0;

    userStats.maxSquat = squatHistory.isNotEmpty
        ? squatHistory
            .map<double?>((e) => e.weight)
            .reduce((a, b) => a! > b! ? a : b) // TODO : check for null safety
        : 0;

    userStats.maxBench = benchHistory.isNotEmpty
        ? benchHistory
            .map<double>((e) => e.weight!)
            .reduce((a, b) => a > b ? a : b) // TODO : check for null safety
        : 0;

    List<Measurement> measurementList = bodystatsDayList.isEmpty
        ? []
        : bodystatsDayList
            .map((e) {
              e.measurements.forEach((element) {
                element.dateTime = e.dateTime;
              });
              return e.measurements;
            })
            .toList()
            .reduce((a, b) {
              a.addAll(b);
              return a;
            });
    measurementList =
        measurementList.where((element) => element.name == 'Body Fat').toList();
    if (measurementList.isNotEmpty)
      measurementList.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
    userStats.bodyFat =
        measurementList.isNotEmpty ? measurementList.last.value : user!.bodyFatPercentage;

    user!.userStats = userStats;
    notifyListeners();
  }

  generateStatistics() async {
    await getUserDataSqflite().then((value) async {
      // bulk edit //print(programDayList);
      await getBodystatDays().then((value) async {
        // bulk edit //print(bodystatsDayList);
        await getExerciseHistories().then((value) async {
          // List<Workout> workoutList = programDayList.isEmpty
          //     ? []
          //     : programDayList
          //         .map((e) => e.workoutList
          //             .where((element) => element.isItDone)
          //             .toList())
          //         .reduce((a, b) {
          //         a.addAll(b);
          //         return a;
          //       });
          // List<WorkoutSet> workoutSets = workoutList.isEmpty
          //     ? []
          //     : workoutList
          //         .map((e) => e.userWorkoutSet)
          //         .toList()
          //         .reduce((a, b) {
          //         a.addAll(b);
          //         return a;
          //       });

          prepareUserStat();
          sendBodyStats();
        });
      });
    });
  }

  /// Below Functions Need For Generate Statistics

  Future<void> getUserDataSqflite() async {
    List<Map<String, dynamic>>? userDataSqflite = [];
    userDataSqflite = await _sqfLiteDatabase.userDataQueryAllRows();
    programDayList = [];
    print(userDataSqflite);
    if (userDataSqflite != null) {
      userDataSqflite.forEach((data) {
        try {
          Map<String, dynamic> decodedData = convert.jsonDecode(data['json']);
          for (var item in decodedData['programDayList']) {
            programDayList.add(ProgramDay.fromLocalJson(item));
          }
        } catch (e) {
          print(e.toString());
        }
      });
      notifyListeners();
    }
  }

  Future<void> getPlannerProgram() async {
    // bulk edit //print('Get Planner Program');
    // programDayList = [];
    // List<Map<String, dynamic>>? plannerProgramRaw = [];
    // plannerProgramRaw = await _sqfLiteDatabase.plannerQueryAllRows();
    // // bulk edit //print(plannerProgramRaw);
    // if (plannerProgramRaw != null) {
    //   plannerProgramRaw.forEach((element) {
    //     if (element['isActive'] == 1) {
    //       for (var item in convert.jsonDecode(element['json'])) {
    //         programDayList.add(ProgramDay.fromLocalJson(
    //             convert.jsonDecode(item),
    //             element['isAddon'] == 1 ? true : false));
    //       }
    //     }
    //   });
    // }
  }

  Future<void> getBodystatDays() async {
    // bulk edit //print('Get Planner Program');
    List<Map<String, dynamic>>? bodystatRaw = [];
    bodystatRaw = await _sqfLiteDatabase.bodystatsQueryAllRows();
    // bulk edit //print(bodystatRaw);
    if (bodystatRaw != null) {
      bodystatRaw.forEach((element) {
        // bulk edit //print(element);
        for (var item in convert.jsonDecode(element['json'])) {
          bodystatsDayList
              .add(BodystatsDay.fromLocalJson(convert.jsonDecode(item)));
        }
      });
      notifyListeners();
    }
  }

  Future<void> getExerciseHistories() async {
    // bulk edit //print('Get Planner Program');
    List<Map<String, dynamic>>? exerciseRaw = [];
    exerciseRaw = await _sqfLiteDatabase.exerciseHistoryQueryAllRows();
    // bulk edit //print(exerciseRaw);
    if (exerciseRaw != null) {
      exerciseRaw.forEach((element) {
        // bulk edit //print(element);
        exerciseHistory = [];
        for (var item in convert.jsonDecode(element['json'])) {
          exerciseHistory.add(
              ExerciseHistoryElement.fromSqfliteJson(convert.jsonDecode(item)));
        }
      });
      notifyListeners();
    }
  }

  Future<void> deleteAllLocalData() async {
    await _sqfLiteDatabase.exerciseHistoryDeleteAll();

    programDayList = [];
    bodystatsDayList = [];
    exerciseHistory = [];
    notifyListeners();
  }
}
