import 'dart:io';

import '../model/achievement/achievement.dart';
import '../model/user/user_stats.dart';

import '../model/program/exercise.dart';
import '../model/program/program.dart';
import '../model/program/programCategory.dart';
import '../model/program/programLevel.dart';
import '../model/program/programPhase.dart';
import '../model/user/user.dart';
import 'firebase.dart';
import '../model/user/user_privacy.dart';

abstract class BaseServices {
  Future<UserObject?> register(
      {required email, required password, fullname, Function? fail});
  Future<UserObject?> login({email, password, Function? fail});
  Future<Map<String, dynamic>?> setGeneralInfo({Map<String, dynamic>? data});
  Future<Map<String, dynamic>> phpGetTutorialList();
  Future<String> uploadImageToFireaseStorage({File? image, String? uploadPath});
  Future<Map<String, dynamic>?> updateUserBasicInfo(
      {Map<String, String?>? data});
  Future<void> logout();
  Future<UserObject?> googleSign({accessToken, idToken, required credential});
  Future<UserObject?> facebookSign({accessToken, idToken, required credential});
  Future<UserObject?> getUserInfo({uid});
  Future<void> forgotPassword({required email});
  Future<UserPrivacy> getUserPrivacy({String? uid});
  Future<bool?> isUserFirebaseAuth({required email});
  Future<List<ProgramCategory>> phpGetProgramCategoryList();
  Future<List<Exercise>> phpGetExerciseList();
  Future<List<ProgramLevel>> phpGetProgramLevelList();
  Future<List<dynamic>> phpGetWatchesData();
  Future<List<Program>> phpGetProgramList();
  Future<List<String?>> phpAddAchievement(Achievement achievement);
  Future<List<String?>?> phpAddUserProgram(int programId);
  Future<List<String?>> phpGetAchievements({String? uid});
  Future<List<String?>?> phpGetUserPrograms({String? uid});
  Future<void> phpTransferUserStats(UserStats? userStats);
  Future<void> phpSetPrivacy(UserPrivacy userPrivacy);
  Future<UserStats> phpGetUserStats({String? uid});
  Future<DateTime?> phpTransferLocalDataToServer(Map<String, dynamic> data);
  Future<List<ProgramPhase>> phpGetProgramCalender({String? programId});
  Future<String> uploadFile({File? file, String? path});
  Future<List<UserObject>> getAllUserBasicInfo();
  Future<void> changePassword({String? currentPass, String? newPass});
  Future<void> resetPassword();
  Future<void> followFriend({String? uid});
  Future<void> unfollowFriend({String? uid});
  Future<void> fetchNewDataFromWatches();
  Future<double> rateProgram({String? programId, double? rate});
  Future<List<Map<String, dynamic>?>> getProgramRates();
  Future<List<Map<String, dynamic>?>> getUserProgramRates();
  Future<String> uploadVideoFile(
      {String? filePath, String? folderName, Function? onUploadProgress});
}

class Services implements BaseServices {
  BaseServices serviceApi = FirebaseApi();
  static final Services _instance = Services._internal();

  factory Services() => _instance;
  Services._internal();

  @override
  Future<void> forgotPassword({required email}) async {
    return serviceApi.forgotPassword(email: email);
  }

  @override
  Future<void> fetchNewDataFromWatches() async {
    return serviceApi.fetchNewDataFromWatches();
  }

  @override
  Future<bool?> isUserFirebaseAuth({required email}) async {
    return serviceApi.isUserFirebaseAuth(email: email);
  }

  @override
  Future<UserPrivacy> getUserPrivacy({String? uid}) async {
    return serviceApi.getUserPrivacy(uid: uid);
  }

  @override
  Future<UserObject?> register(
      {required email, required password, fullname, Function? fail}) async {
    // bulk edit //print('________________');
    // bulk edit //print('Email =>' + email);
    // bulk edit //print('password =>' + password);
    UserObject? user;
    // bulk edit //print('________________');
    // return await serviceApi.register(
    //     email: email, password: password, fullname: fullname);
    user = await serviceApi.register(
        email: email, password: password, fullname: fullname, fail: fail);
    // bulk edit //print('Service Index User ->');
    // bulk edit //print(user);
    // bulk edit //print(user.uid);
    return user;
  }

  @override
  Future<UserObject?> login({email, password, Function? fail}) async {
    // bulk edit //print('________SERVICE INDEX________');
    // bulk edit //print('Email =>' + email);
    // bulk edit //print('password =>' + password);

    // bulk edit //print('________________');
    return serviceApi.login(email: email, password: password, fail: fail);
  }

  @override
  Future<Map<String, dynamic>?> setGeneralInfo({data}) async {
    return serviceApi.setGeneralInfo(data: data);
  }

  @override
  Future<UserObject?> googleSign(
      {accessToken, idToken, required credential}) async {
    return serviceApi.googleSign(
        accessToken: accessToken, idToken: idToken, credential: credential);
  }

  @override
  Future<UserObject?> facebookSign(
      {accessToken, idToken, required credential}) async {
    return serviceApi.facebookSign(
        accessToken: accessToken, idToken: idToken, credential: credential);
  }

  @override
  Future<String> uploadImageToFireaseStorage(
      {File? image, String? uploadPath}) async {
    return serviceApi.uploadImageToFireaseStorage(
        image: image, uploadPath: uploadPath);
  }

  @override
  Future<Map<String, dynamic>?> updateUserBasicInfo(
      {Map<String, String?>? data}) async {
    return serviceApi.updateUserBasicInfo(data: data);
  }

  @override
  Future<void> logout() async {
    return serviceApi.logout();
  }

  @override
  Future<Map<String, dynamic>> phpGetTutorialList() async {
    return serviceApi.phpGetTutorialList();
  }

  @override
  Future<List<String?>> phpAddAchievement(Achievement achievement) async {
    return serviceApi.phpAddAchievement(achievement);
  }

  @override
  Future<List<String?>?> phpAddUserProgram(int programId) async {
    return serviceApi.phpAddUserProgram(programId);
  }

  @override
  Future<List<String?>> phpGetAchievements({String? uid}) async {
    return serviceApi.phpGetAchievements(uid: uid);
  }

  @override
  Future<List<String?>?> phpGetUserPrograms({String? uid}) async {
    return serviceApi.phpGetUserPrograms(uid: uid);
  }

  @override
  Future<UserStats> phpGetUserStats({String? uid}) async {
    return serviceApi.phpGetUserStats(uid: uid);
  }

  @override
  Future<void> phpTransferUserStats(UserStats? userStats) async {
    return serviceApi.phpTransferUserStats(userStats);
  }

  @override
  Future<void> phpSetPrivacy(UserPrivacy userPrivacy) async {
    return serviceApi.phpSetPrivacy(userPrivacy);
  }

  @override
  Future<UserObject?> getUserInfo({uid}) async {
    return serviceApi.getUserInfo(uid: uid);
  }

  @override
  Future<double> rateProgram({String? programId, double? rate}) async {
    return serviceApi.rateProgram(programId: programId, rate: rate);
  }

  @override
  Future<List<Map<String, dynamic>?>> getProgramRates() async {
    return serviceApi.getProgramRates();
  }

  @override
  Future<List<Map<String, dynamic>?>> getUserProgramRates() async {
    return serviceApi.getUserProgramRates();
  }

  @override
  Future<List<ProgramCategory>> phpGetProgramCategoryList() async {
    return serviceApi.phpGetProgramCategoryList();
  }

  @override
  Future<List<Exercise>> phpGetExerciseList() async {
    return serviceApi.phpGetExerciseList();
  }

  @override
  Future<List<ProgramLevel>> phpGetProgramLevelList() async {
    return serviceApi.phpGetProgramLevelList();
  }

  @override
  Future<List<dynamic>> phpGetWatchesData() async {
    return serviceApi.phpGetWatchesData();
  }

  @override
  Future<List<Program>> phpGetProgramList() async {
    return serviceApi.phpGetProgramList();
  }

  @override
  Future<DateTime?> phpTransferLocalDataToServer(
      Map<String, dynamic> data) async {
    return serviceApi.phpTransferLocalDataToServer(data);
  }

  @override
  Future<List<ProgramPhase>> phpGetProgramCalender({String? programId}) async {
    return await serviceApi.phpGetProgramCalender(programId: programId);
  }

  @override
  Future<String> uploadFile({File? file, String? path}) async {
    return await serviceApi.uploadFile(file: file, path: path);
  }

  @override
  Future<List<UserObject>> getAllUserBasicInfo() async {
    return await serviceApi.getAllUserBasicInfo();
  }

  @override
  Future<void> changePassword({String? currentPass, String? newPass}) async {
    return await serviceApi.changePassword(
        currentPass: currentPass, newPass: newPass);
  }

  @override
  Future<void> resetPassword() async {
    return await serviceApi.resetPassword();
  }

  @override
  Future<void> followFriend({String? uid}) async {
    return await serviceApi.followFriend(uid: uid);
  }

  @override
  Future<void> unfollowFriend({String? uid}) async {
    return await serviceApi.unfollowFriend(uid: uid);
  }

  @override
  Future<String> uploadVideoFile(
      {String? filePath,
      String? folderName,
      Function? onUploadProgress}) async {
    return await serviceApi.uploadVideoFile(
        filePath: filePath,
        folderName: folderName,
        onUploadProgress: onUploadProgress);
  }

  // @override
  // Future<List<UserObject>> getAllUserService() async {
  //   // bulk edit //print('_______SERVİCE INDEX_________');
  //   return await serviceApi.getAllUserService();
  // }
}
