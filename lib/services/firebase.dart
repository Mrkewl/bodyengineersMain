import 'dart:io';
import 'dart:async';
import 'dart:convert' as convert;

import '../model/user/user.dart';
import './index.dart';
import '../model/watch/fitbit.dart';
import '../model/achievement/achievement.dart';
import '../model/user/user_stats.dart';
import '../model/watch/garmin.dart';
import '../model/watch/polar.dart';
import '../model/program/exercise.dart';
import '../model/program/program.dart';
import '../model/program/programCategory.dart';
import '../model/program/programLevel.dart';
import '../model/program/programPhase.dart';
import '../model/user/user_privacy.dart';

import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;

enum authProblems { UserNotFound, PasswordNotValid, NetworkError }

class FirebaseApi implements BaseServices {
  static final FirebaseApi _instance = FirebaseApi._internal();
  factory FirebaseApi() => _instance;
  FirebaseApi._internal();
  // final FirebaseMessaging _fcm = FirebaseMessaging();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String? firebaseUserid;
  // final dbRef = FirebaseDatabase.instance.reference();
  FirebaseStorage _storage = FirebaseStorage.instance;

  final firestoreInstance = FirebaseFirestore.instance;
  final firestorePostList = FirebaseFirestore.instance.collection('post_list');
  final firestoreFriendtList =
      FirebaseFirestore.instance.collection('friend_list');
  final firestorePostComment =
      FirebaseFirestore.instance.collection('post_comment');
  final firestoreStoryList =
      FirebaseFirestore.instance.collection('story_list');

  String? cookie;
  String domain = 'https://www.bodyengineersapp.xyz/';
  static const apiUrlCheck = 'JazzsleyZainalBodyengineers';
  String apiKey = convert.base64
      .encode(convert.utf8.encode(apiUrlCheck + '~bodyengineersApp'));

  Future<UserObject?> getUserInfo({uid}) async {
    UserObject? user;
    Map<String, dynamic> phpGetUserBasicInfoResult =
        await phpGetUserBasicInfo(uid: uid);

    if (phpGetUserBasicInfoResult['result']) {
      Map<String, dynamic> phpCheckUserGeneralResult =
          await phpCheckUserGeneralInfo(uid: uid);

      if (phpCheckUserGeneralResult['result']) {
        // bulk edit //print('Everyting is OK- redirect to feed');
        Map<String, dynamic> data = {
          ...phpGetUserBasicInfoResult['data'],
          ...phpCheckUserGeneralResult['data']
        };

        data['general_info'] = true;
        user = UserObject.fromMysqlDatabase(data);
      } else {
        // bulk edit //print('Some of your data missing - redirect to general info page');
        phpGetUserBasicInfoResult['data']['general_info'] = false;
        user = UserObject.fromMysqlDatabase(phpGetUserBasicInfoResult['data']);

        // bulk edit //print('Inside Login Service -> ');
        // bulk edit //print(user.uid);
      }
    } else {
      // bulk edit //print('Database Error - Some of Your Result Missing');
    }

    return user;
  }

  // ignore: missing_return
  Future<bool> isUserRegistered({uid}) async {
    try {
      var response = await http.post(Uri.parse("$domain/api/isUserRegistered"),
          body: convert.jsonEncode({
            'uid': uid,
            "bodyengineer_token": apiKey,
            // 'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        // bulk edit //print(body);
        return body['result'];
      } else {
        List? error = body["error"];
        return false;
        // if (error != null && error.isNotEmpty) {
        //   throw Exception(error[0]);
        // } else {
        //   throw Exception("Can not create user");
        // }
      }
    } catch (e) {
      return false;
      // bulk edit //print(e.toString());
    }
  }

  // ignore: missing_return
  Future<UserObject?> googleSign(
      {accessToken, idToken, required credential}) async {
    UserObject? user;
    try {
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((UserCredential result) async {
        if (result.user != null) {
          bool isUserRegister =
              await (isUserRegistered(uid: result.user!.uid) as FutureOr<bool>);
          var phpUserSaveBasicResult;
          if (!isUserRegister) {
            phpUserSaveBasicResult = await phpSaveUserBasic(
                uid: result.user!.uid,
                avatar: result.user!.photoURL,
                fullname: result.user!.displayName,
                email: result.user!.email,
                authmethod: 'google');
          } else {
            phpUserSaveBasicResult = true;
          }

          if (phpUserSaveBasicResult) {
            user =
                await login(email: result.user!.email, credential: credential);
            // bulk edit //print('User Login - > After Service');
            // bulk edit //print(user.uid);
            // bulk edit //print(user.isGeneralInfoFilled);
          } else {
            // bulk edit //print('Database error - Please try again later');
          }
        }
      });
      return user;
    } catch (e) {}
  }

  Future<UserObject?> facebookSign(
      {accessToken, idToken, required credential}) async {
    UserObject? user;
    // Map<String, dynamic> userData =
    //     await FacebookAuth.instance.getUserData(fields: 'name,email,picture');
    try {
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((UserCredential result) async {
        if (result.user != null) {
          bool? isUserRegister = await isUserRegistered(uid: result.user!.uid);
          var phpUserSaveBasicResult;
          if (!isUserRegister) {
            phpUserSaveBasicResult = await phpSaveUserBasic(
                uid: result.user!.uid,
                avatar: result.user!.photoURL,
                fullname: result.user!.displayName,
                email: result.user!.email ??
                    result.user!.displayName!.replaceAll(' ', '_') +
                        '@facebook.com',
                authmethod: 'facebook');
          } else {
            phpUserSaveBasicResult = true;
          }

          if (phpUserSaveBasicResult) {
            user =
                await login(email: result.user!.email, credential: credential);
            // bulk edit //print('User Login - > After Service');
            // bulk edit //print(user.uid);
            // bulk edit //print(user.isGeneralInfoFilled);
          } else {
            // bulk edit //print('Database error - Please try again later');
          }
        }
      });
      return user;
    } catch (e) {}
  }

  @override
  // ignore: override_on_non_overriding_member
  Future<bool?> phpSaveUserBasic(
      {uid, email, avatar, fullname, authmethod}) async {
    try {
      var response = await http.post(Uri.parse("$domain/api/saveBasicInfo"),
          body: convert.jsonEncode({
            'uid': uid,
            'avatar': avatar ?? '',
            'fullname': fullname,
            'email': email,
            'authmethod': authmethod,
            "bodyengineer_token": apiKey,
            // 'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        return body['result'];
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<UserObject?> register({
    required email,
    required password,
    fullname,
    Function? fail,
  }) async {
    UserObject? user;

    try {
      await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((UserCredential result) async {
        // bulk edit //print(result);
        if (result.user != null) {
          await result.user!.sendEmailVerification();

          var phpUserSaveBasicResult = await (phpSaveUserBasic(
              uid: result.user!.uid,
              avatar: result.user!.photoURL,
              fullname: fullname,
              email: email,
              authmethod: 'email'));

          if (phpUserSaveBasicResult!) {
            user = await login(email: email, password: password);
            // bulk edit //print('User Login - > After Service');
            // bulk edit //print(user.uid);
            // bulk edit //print(user.isGeneralInfoFilled);
          } else {
            // bulk edit //print('Database error - Please try again later');
          }
        }
      });
      // bulk edit //print('Service register return');
      // bulk edit //print(user.uid);
      // bulk edit //print(user.isGeneralInfoFilled);
      return user;
    } on FirebaseAuthException catch (e) {
      // bulk edit //print('Failed with error code: ${e.code}');
      // bulk edit //print(e.message);
      fail!(e.message);
    }
  }

  @override
  // ignore: override_on_non_overriding_member
  Future<Map<String, dynamic>> phpCheckUserGeneralInfo({uid}) async {
    try {
      var response = await http.post(
          Uri.parse("$domain/api/checkusergeneralinfo"),
          body: convert.jsonEncode({
            'uid': uid,
            "bodyengineer_token": apiKey,
            // 'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        // bulk edit //print(body);
        return body;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> setGeneralInfo({data}) async {
    try {
      var response = await http.post(Uri.parse("$domain/api/savegeneralinfo"),
          body: convert.jsonEncode({
            'data': data,
            "bodyengineer_token": apiKey,
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        return body;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<double> rateProgram({String? programId, double? rate}) async {
    try {
      var response = await http.post(Uri.parse("$domain/api/rateProgram"),
          body: convert.jsonEncode({
            'program_id': int.parse(programId!),
            'uid': auth.currentUser!.uid,
            'rate': rate,
            "bodyengineer_token": apiKey,
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        double result = 5.0;
        if (body['result']) {
          result = double.parse(body['data']);
        }
        return result;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> updateUserBasicInfo(
      {Map<String, String?>? data}) async {
    try {
      var response = await http.post(Uri.parse("$domain/api/updateBasicInfo"),
          body: convert.jsonEncode({
            'data': data,
            "bodyengineer_token": apiKey,
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        return body;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<void> fetchNewDataFromWatches() async {
    if (auth.currentUser != null) {
      try {
        var response = await http.post(
            Uri.parse("$domain/api/fetchNewDataFromWatches"),
            body: convert.jsonEncode({
              'uid': auth.currentUser!.uid,
              "bodyengineer_token": apiKey,
            }),
            headers: {
              "cookie": cookie ?? '',
              "content-type": "application/json"
            });
        // bulk edit //print(response.body);
        final body = convert.jsonDecode(response.body);
        if (response.statusCode == 200) {
          // bulk edit //print(body);
        } else {
          List? error = body["error"];
          if (error != null && error.isNotEmpty) {
            throw Exception(error[0]);
          } else {
            throw Exception("Can not create user");
          }
        }
      } catch (err) {
        rethrow;
      }
    }
  }

  Future<String> uploadImageToFireaseStorage(
      {File? image, String? uploadPath}) async {
    Reference reference = _storage.ref().child(uploadPath!);
    UploadTask uploadTask = reference.putFile(image!);

    var storageTaskSnapshot = await uploadTask;
    var downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  @override
  Future<void> forgotPassword({required email}) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<bool?> isUserFirebaseAuth({required email}) async {
    bool? result;
    await auth.fetchSignInMethodsForEmail(email).then((value) {
      result = value.length > 0 ? true : false;
    });
    return result;
  }

  @override
  // ignore: override_on_non_overriding_member
  Future<Map<String, dynamic>> phpGetUserBasicInfo({uid}) async {
    try {
      var response = await http.post(Uri.parse("$domain/api/getuserbasicinfo"),
          body: convert.jsonEncode({
            'uid': uid,
            "bodyengineer_token": apiKey,
            //'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        // bulk edit //print(body);
        return body;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<ProgramCategory>> phpGetProgramCategoryList() async {
    try {
      var response = await http.post(
          Uri.parse("$domain/api/getProgramCategoryList"),
          body: convert.jsonEncode({
            "bodyengineer_token": apiKey,
            // 'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        // bulk edit //print(body);
        List<ProgramCategory> list = [];
        for (var item in body['data']) {
          list.add(ProgramCategory.fromMysqlDatabase(item));
        }
        return list;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Exercise>> phpGetExerciseList() async {
    try {
      var response = await http.post(Uri.parse("$domain/api/getExerciseList"),
          body: convert.jsonEncode({
            "bodyengineer_token": apiKey,
            // 'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        // bulk edit //print(body);
        List<Exercise> list = [];
        for (var item in body['data']) {
          list.add(Exercise.fromMysqlDatabase(item));
        }
        return list;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<String?>> phpAddAchievement(Achievement achievement) async {
    try {
      var response = await http.post(Uri.parse("$domain/api/addAchievement"),
          body: convert.jsonEncode({
            "bodyengineer_token": apiKey,
            "uid": auth.currentUser!.uid,
            "data": achievement.id
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        // bulk edit //print(body);
        List<String?> list = [];
        if (body['result']) {
          for (var item in body['data']) {
            list.add(item['achievement_id']);
          }
        }
        return list;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<void> phpSetPrivacy(UserPrivacy userPrivacy) async {
    try {
      var response = await http.post(Uri.parse("$domain/api/setPrivacy"),
          body: convert.jsonEncode({
            "bodyengineer_token": apiKey,
            "uid": auth.currentUser!.uid,
            "data": userPrivacy.toBasicJson(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not set privacy");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<String?>> phpGetAchievements({String? uid}) async {
    try {
      if (auth.currentUser != null) {
        var response = await http.post(Uri.parse("$domain/api/getAchievements"),
            body: convert.jsonEncode({
              "bodyengineer_token": apiKey,
              "uid": uid ?? auth.currentUser!.uid,
            }),
            headers: {
              "cookie": cookie ?? '',
              "content-type": "application/json"
            });
        // bulk edit //print(response.body);
        final body = convert.jsonDecode(response.body);
        // bulk edit //print(body);
        if (response.statusCode == 200) {
          // bulk edit //print(body);
          List<String?> list = [];
          if (body['result']) {
            for (var item in body['data']) {
              list.add(item['achievement_id']);
            }
          }
          return list;
        } else {
          List? error = body["error"];
          if (error != null && error.isNotEmpty) {
            throw Exception(error[0]);
          } else {
            throw Exception("Can not create user");
          }
        }
      } else {
        return [];
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<String?>?> phpAddUserProgram(int programId) async {
    try {
      if (auth.currentUser != null) {
        var response = await http.post(Uri.parse("$domain/api/addUserProgram"),
            body: convert.jsonEncode({
              "bodyengineer_token": apiKey,
              "uid": auth.currentUser!.uid,
              "data": programId,
            }),
            headers: {
              "cookie": cookie ?? '',
              "content-type": "application/json"
            });
        // bulk edit //print(response.body);
        final body = convert.jsonDecode(response.body);
        // bulk edit //print(body);
        if (response.statusCode == 200) {
          // bulk edit //print(body);
          List<String?> list = [];
          if (body['result']) {
            for (var item in body['data']) {
              list.add(item['program_id']);
            }
          }
          return list;
        } else {
          List? error = body["error"];
          if (error != null && error.isNotEmpty) {
            throw Exception(error[0]);
          } else {
            throw Exception("Can not create user");
          }
        }
      } else {
        return null;
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<String?>?> phpGetUserPrograms({String? uid}) async {
    try {
      if (auth.currentUser != null) {
        var response = await http.post(Uri.parse("$domain/api/getUserPrograms"),
            body: convert.jsonEncode({
              "bodyengineer_token": apiKey,
              "uid": uid ?? auth.currentUser!.uid,
            }),
            headers: {
              "cookie": cookie ?? '',
              "content-type": "application/json"
            });
        // bulk edit //print(response.body);
        final body = convert.jsonDecode(response.body);
        // bulk edit //print(body);
        if (response.statusCode == 200) {
          // bulk edit //print(body);
          List<String?> list = [];
          if (body['result']) {
            for (var item in body['data']) {
              list.add(item['program_id']);
            }
          }
          return list;
        } else {
          List? error = body["error"];
          if (error != null && error.isNotEmpty) {
            throw Exception(error[0]);
          } else {
            throw Exception("Can not create user");
          }
        }
      } else {
        return null;
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<void> changePassword({String? currentPass, String? newPass}) async {
    // bulk edit //print('Current Pass: ' + currentPass);
    // bulk edit //print('New Pass: ' + newPass);

    auth.signInWithEmailAndPassword(
        email: auth.currentUser!.email!, password: currentPass!);
  }

  Future<void> resetPassword() async {
    auth.sendPasswordResetEmail(email: auth.currentUser!.email!);
  }

  @override
  Future<DateTime?> phpTransferLocalDataToServer(
      Map<String, dynamic> data) async {
    if (auth.currentUser != null) {
      try {
        var response = await http.post(
            Uri.parse("$domain/api/transferLocalData"),
            body: convert.jsonEncode({
              "bodyengineer_token": apiKey,
              "uid": auth.currentUser!.uid,
              "data": convert.jsonEncode(data)
              // 'device': getDeviceIdentity(),
            }),
            headers: {
              "cookie": cookie ?? '',
              "content-type": "application/json"
            });
        // bulk edit //print(response.body);
        final body = convert.jsonDecode(response.body);
        // bulk edit //print(body);
        if (response.statusCode == 200) {
          // bulk edit //print(body);
          if (body['result']) {
            return DateTime.parse(body['data']);
          } else {
            return null;
          }
        } else {
          List? error = body["error"];
          if (error != null && error.isNotEmpty) {
            throw Exception(error[0]);
          } else {
            throw Exception("Can not create user");
          }
        }
      } catch (err) {
        rethrow;
      }
    } else {
      return DateTime.now();
    }
  }

  @override
  Future<UserStats> phpGetUserStats({String? uid}) async {
    try {
      var response = await http.post(Uri.parse("$domain/api/getUserStats"),
          body: convert.jsonEncode({
            "bodyengineer_token": apiKey,
            "uid": uid ?? auth.currentUser!.uid,
            // 'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        // bulk edit //print(body);
        UserStats userSt = UserStats();
        if (body['result']) {
          Map<String, dynamic> json =
              convert.jsonDecode(body['data'][0]['data']);
          json['user_uid'] = uid ?? auth.currentUser!.uid;
          userSt = UserStats.fromJson(json);
        }
        return userSt;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<UserPrivacy> getUserPrivacy({String? uid}) async {
    try {
      var response = await http.post(Uri.parse("$domain/api/getUserPrivacy"),
          body: convert.jsonEncode({
            "bodyengineer_token": apiKey,
            "uid": uid ?? auth.currentUser!.uid,
            // 'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      UserPrivacy userPrivacy = UserPrivacy();

      if (response.statusCode == 200) {
        // bulk edit //print(body);
        if (body['result']) {
          Map<String?, dynamic> json = {};

          for (var item in body['data']) {
            json.addAll({item['key_name']: item['value']});
          }

          userPrivacy = UserPrivacy.fromJson(json);
        }
      }
      return userPrivacy;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<void> phpTransferUserStats(UserStats? userStats) async {
    try {
      var response = await http.post(Uri.parse("$domain/api/transferUserStats"),
          body: convert.jsonEncode({
            "bodyengineer_token": apiKey,
            "uid": auth.currentUser!.uid,
            "data": userStats!.toBasicJson()
            // 'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
    } catch (err) {
      rethrow;
    }
  }

  bool isValidDate(String input) {
    if (input.length < 5) return false;
    try {
      final date = DateTime.parse(input);
      if (date != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  String toOriginalFormatString(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return "$y$m$d";
  }

  @override
  Future<List<dynamic>> phpGetWatchesData() async {
    try {
      if (auth.currentUser != null) {
        var response = await http.post(Uri.parse("$domain/api/getWatchesData"),
            body: convert.jsonEncode({
              "bodyengineer_token": apiKey,
              "uid": auth.currentUser!.uid,
              // 'device': getDeviceIdentity(),
            }),
            headers: {
              "cookie": cookie ?? '',
              "content-type": "application/json"
            });
        // bulk edit //print(response.body);
        final body = convert.jsonDecode(response.body);
        // bulk edit //print(body);
        if (response.statusCode == 200) {
          // bulk edit //print(body);
          List<dynamic> list = [];
          if (body['result']) {
            for (var item in body['data']) {
              dynamic serverData = convert.jsonDecode(item['json']);
              // print(serverData);
              switch (item['api']) {
                case 'Garmin':
                  Map<String, dynamic> garminData = {};
                  if (item['json'] != null && serverData is Map)
                    garminData = Map<String, dynamic>.from(
                        convert.jsonDecode(item['json']));
                  // bulk edit //print(garminData);
                  garminData.forEach((key, value) {
                    if (key != '' && key != null) {
                      if (isValidDate(key))
                        list.add(Garmin.mysqlDatabase(
                            dateTime: DateTime.parse(key), json: value));
                    }
                  });
                  break;

                case 'Polar':
                  Map<String, dynamic> polarData = {};

                  if (item['json'] != null && serverData is Map)
                    polarData = Map<String, dynamic>.from(
                        convert.jsonDecode(item['json']));

                  // bulk edit //print(polarData);
                  polarData.forEach((key, value) {
                    if (key != '' && key != null) {
                      if (isValidDate(key))
                        list.add(Polar.mysqlDatabase(
                            dateTime: DateTime.parse(key), json: value));
                    }
                  });
                  break;

                case 'Fitbit':
                  Map<String, dynamic> fitbitData = {};
                  if (item['json'] != null && serverData is Map)
                    fitbitData = Map<String, dynamic>.from(
                        convert.jsonDecode(item['json']));

                  // bulk edit //print(polarData);
                  fitbitData.forEach((key, value) {
                    if (key != '' && key != null) {
                      if (isValidDate(key))
                        list.add(Fitbit.mysqlDatabase(
                            dateTime: DateTime.parse(key), json: value));
                    }
                  });
                  break;
              }
            }
          }

          return list;
        } else {
          List? error = body["error"];
          if (error != null && error.isNotEmpty) {
            throw Exception(error[0]);
          } else {
            throw Exception("Can not create user");
          }
        }
      } else {
        return [];
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<ProgramLevel>> phpGetProgramLevelList() async {
    try {
      var response = await http.post(
          Uri.parse("$domain/api/getProgramLevelList"),
          body: convert.jsonEncode({
            "bodyengineer_token": apiKey,
            // 'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        // bulk edit //print(body);
        List<ProgramLevel> list = [];
        if (body['result']) {
          for (var item in body['data']) {
            list.add(ProgramLevel.fromMysqlDatabase(item));
          }
        }

        return list;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<UserObject>> getAllUserBasicInfo() async {
    try {
      var response = await http.post(
          Uri.parse("$domain/api/getAllUserBasicInfo"),
          body: convert.jsonEncode({
            "bodyengineer_token": apiKey,
            // 'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        // bulk edit //print(body);
        List<UserObject> list = [];
        if (body['result']) {
          for (var item in body['data']) {
            UserObject user = UserObject();
            user.uid = item['user_uid'];
            user.avatar =
                item['user_avatar'] != '' ? item['user_avatar'] : null;
            user.fullname = item['user_fullname'];
            list.add(user);
          }
        }

        return list;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Program>> phpGetProgramList() async {
    try {
      var response = await http.post(Uri.parse("$domain/api/getProgramList"),
          body: convert.jsonEncode({
            "bodyengineer_token": apiKey,
            // 'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        // bulk edit //print(body);
        List<Program> list = [];
        for (var item in body['data']) {
          list.add(Program.fromMysqlDatabase(item));
        }
        return list;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>?>> getProgramRates() async {
    try {
      var response = await http.post(Uri.parse("$domain/api/getProgramRates"),
          body: convert.jsonEncode({
            "bodyengineer_token": apiKey,
            // 'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        // bulk edit //print(body);
        List<Map<String, dynamic>?> result = [];
        if (body['result']) {
          for (var item in body['data']) {
            result.add(item);
          }
        }
        return result;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>?>> getUserProgramRates() async {
    if (auth.currentUser != null) {
      try {
        var response = await http.post(
            Uri.parse("$domain/api/getUserProgramRates"),
            body: convert.jsonEncode({
              'uid': auth.currentUser!.uid,
              "bodyengineer_token": apiKey,
              // 'device': getDeviceIdentity(),
            }),
            headers: {
              "cookie": cookie ?? '',
              "content-type": "application/json"
            });
        // bulk edit //print(response.body);
        final body = convert.jsonDecode(response.body);
        // bulk edit //print(body);
        if (response.statusCode == 200) {
          // bulk edit //print(body);
          List<Map<String, dynamic>?> result = [];
          if (body['result']) {
            for (var item in body['data']) {
              result.add(item);
            }
          }
          return result;
        } else {
          List? error = body["error"];
          if (error != null && error.isNotEmpty) {
            throw Exception(error[0]);
          } else {
            throw Exception("Can not create user");
          }
        }
      } catch (err) {
        rethrow;
      }
    } else {
      return <Map<String, dynamic>>[];
    }
  }

  @override
  Future<List<ProgramPhase>> phpGetProgramCalender({String? programId}) async {
    try {
      var response = await http.post(
          Uri.parse("$domain/api/getProgramCalender"),
          body: convert.jsonEncode({
            "program_id": programId,
            "bodyengineer_token": apiKey,
            // 'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        List<ProgramPhase> result = [];

        for (var item in body['data']) {
          ProgramPhase addElement = ProgramPhase.fromMysqlDatabase(item);
          result.add(addElement);
        }

        return result;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> phpGetTutorialList() async {
    try {
      var response = await http.post(Uri.parse("$domain/api/getTutorialList"),
          body: convert.jsonEncode({
            "bodyengineer_token": apiKey,
            // 'device': getDeviceIdentity(),
          }),
          headers: {
            "cookie": cookie ?? '',
            "content-type": "application/json"
          });
      // bulk edit //print(response.body);
      final body = convert.jsonDecode(response.body);
      // bulk edit //print(body);
      if (response.statusCode == 200) {
        // bulk edit //print(body);
        return body;
      } else {
        List? error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await auth.signOut();
  }

  @override
  Future<UserObject?> login(
      {email, password, Function? fail, AuthCredential? credential}) async {
    UserObject? user;

    // bool isEmailVerify;
    if (credential != null) {
      try {
        await auth
            .signInWithCredential(credential)
            .then((UserCredential result) async {
          // isEmailVerify = value.user.isEmailVerified;
          // if (isEmailVerify) {
          if (result.user != null) {
            // bulk edit //print('Login is successfull');
            user = await getUserInfo(uid: result.user!.uid);
          } else {
            /// Hatalı işlem
            // bulk edit //print('Not Auth User');
          }
        });
      } on FirebaseAuthException catch (e) {
        // bulk edit //print('Failed with error code: ${e.code}');
        // bulk edit //print(e.message);
        fail!(e.message);
      }
    } else {
      await auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((UserCredential result) async {
        // isEmailVerify = value.user.isEmailVerified;
        // if (isEmailVerify) {
        if (result.user != null) {
          // bulk edit //print('Login is successfull');
          user = await getUserInfo(uid: result.user!.uid);
        } else {
          /// Hatalı işlem
          // bulk edit //print('Not Auth User');
        }
      });
    }
    // bulk edit //print('Return user');
    return user;
  }

  @override
  Future<void> followFriend({String? uid}) async {
    if (uid != null && auth.currentUser!.uid != null) {
      QuerySnapshot snapshot = await firestoreFriendtList
          .where('followed', isEqualTo: uid)
          .where('follower', isEqualTo: auth.currentUser!.uid)
          .get();
      // // bulk edit //print(snapshot);
      // // bulk edit //print(snapshot.docs);
      // // bulk edit //print(snapshot.size);
      if (snapshot.size == 0 && snapshot.docs.isEmpty) {
        DocumentReference ref = await firestoreFriendtList.add({
          'followed': uid,
          'follower': auth.currentUser!.uid,
          'dateTime': FieldValue.serverTimestamp()
        });
        // bulk edit //print(ref.id);
      }
    }
  }

  @override
  Future<void> unfollowFriend({String? uid}) async {
    if (uid != null && auth.currentUser!.uid != null) {
      QuerySnapshot snapshot = await firestoreFriendtList
          .where('followed', isEqualTo: uid)
          .where('follower', isEqualTo: auth.currentUser!.uid)
          .get();
      // // bulk edit //print(snapshot);
      // // bulk edit //print(snapshot.docs);
      // // bulk edit //print(snapshot.size);
      if (snapshot.size > 0 && snapshot.docs.isNotEmpty) {
        await firestoreFriendtList.doc(snapshot.docs.first.id).delete();
      }
    }
  }

  @override
  Future<String> uploadVideoFile(
      {String? filePath,
      String? folderName,
      Function? onUploadProgress}) async {
    final file = new File(filePath!);
    final basename = p.basename(filePath);

    final Reference ref =
        FirebaseStorage.instance.ref().child(folderName!).child(basename);
    UploadTask uploadTask = ref.putFile(file);
    uploadTask.snapshotEvents
        .listen(onUploadProgress as void Function(TaskSnapshot)?);
    TaskSnapshot taskSnapshot = await uploadTask;
    
    String videoUrl = await taskSnapshot.ref.getDownloadURL();
    return videoUrl;
  }

  Future<String> uploadFile({File? file, String? path}) async {
    //Get the file from the image picker and store it
    // bulk edit //print('fonksiyona girdi');
    //Create a reference to the location you want to upload to in firebase
    String filename = file!.path.split('/').last;
    Reference reference = _storage.ref().child(path! + '/' + filename);
    // bulk edit //print('referansa girdi');

    //Upload the file to firebase
    UploadTask uploadTask = reference.putFile(file);
    // bulk edit //print('uplaod taska girdi');
    var storageTaskSnapshot = await uploadTask;
    var downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }
}

// @override
// Future<bool> checkUserExist({String email}) async {
//   var db = FirebaseDatabase.instance.reference().child("user_list");
//   List authMethods = [];
//   authMethods = await auth.fetchSignInMethodsForEmail(email: email);
//   return authMethods.isNotEmpty ? true : false;
// }

// @override
// Future<String> getUserDatabaseId({String email}) async {
//   var db = FirebaseDatabase.instance.reference().child("user_list");
//   Map<dynamic, dynamic> values;
//   var result =
//       await db.orderByChild('email').equalTo(email).once().then((value) {
//     values = value.value;
//   });
//   if (values == null) {
//     result = await db
//         .orderByChild('new_email')
//         .equalTo(email)
//         .once()
//         .then((value) async {
//       values = value.value;
//     });
//   }
//   return values.keys.first;
// }

// @override
// Future<void> saveUserDatabase(
//     UserObject user, String password, String name, String surname) async {
//   var ref = Firestore.instance.document('user_list/' + user.id);

//   await ref.setData({
//     'email': user.email,
//     'name': name,
//     'last_name': surname,
//   });
// }
