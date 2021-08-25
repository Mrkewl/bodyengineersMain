import '../../model/achievement/achievement.dart';
import '../../model/user/user_stats.dart';
import '../../model/user/user_privacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserObject {
  String? uid;
  String? email;
  String? fullname;
  String? avatar;
  String? authmethod;
  bool? isGeneralInfoFilled = false;
  int? gender;
  DateTime? birthday;
  String? country;
  int? countryId;
  String? region;
  int? regionId;
  late String unitOfMeasurement;
  String? bio;
  int? unitOfMeasurementId;
  double? bodyWeightInKilo;
  int? length;
  double? bodyFatPercentage;
  late DateTime registerDate;
  List<UserObject?>friendList = [];
  String? leanMuscleMass;
  List<String?>? userPrograms;
  List<Achievement>? userAchievement;
  UserStats? userStats;
  UserPrivacy userPrivacy = UserPrivacy();
  UserObject();

  UserObject.fromMysqlDatabase(Map<String, dynamic> json) {
    try {
      // // bulk edit //print(json);
      uid = json['user_uid'];
      fullname = json['user_fullname'];
      avatar = json['user_avatar'] != '' ? json['user_avatar'] : null;
      email = json['user_email'];
      authmethod = json['user_authmethod'];
      isGeneralInfoFilled = json['general_info'];
      if (isGeneralInfoFilled!) {
        gender = int.parse(json['user_gender'].toString());
        birthday = DateTime.parse(json['user_birthday']);
        countryId = int.parse(json['country_id'].toString());
        regionId = int.parse(json['region_id'].toString());
        bio = json['user_bio'];
        unitOfMeasurementId = int.parse(json['unit_of_measerument'].toString());
        if (unitOfMeasurementId != null) {
          getUnitOfMeasurement();
        }
        bodyWeightInKilo = double.parse(json['user_kilo'].toString());
        length = int.parse(json['user_length'].toString());
        if (json['user_bmi'] != null && json['user_bmi'] != '0')
          bodyFatPercentage = double.parse(json['user_bmi'].toString());
        registerDate = json['register_date'] != null
            ? DateTime.tryParse(json['register_date']) ?? DateTime.now()
            : DateTime.now();
      }
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }

  Future<void> getUnitOfMeasurement() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    unitOfMeasurementId = prefs.getInt('unit') ?? unitOfMeasurementId;
  }

  Future<void> changeUnitOfMeasurement(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('unit', value);
    unitOfMeasurementId = value;
  }

  Map<String, dynamic> toBasicJson() {
    return {
      "user_uid": uid,
      "user_fullname": fullname,
      "user_avatar": avatar,
      "user_authmethod": authmethod,
    };
  }

  getLeanMuscleMass() {
    String result = (bodyWeightInKilo! * (100 - bodyFatPercentage!) / 100).round().toString();
    result += unitOfMeasurementId == 1 ? 'kg' : 'ibs';
    return result;
  }

  // UserObject.fromFirebase(Map<dynamic, dynamic> json) {
  //   try {
  //     id = json['id'];
  //     firstName = json['name'];
  //     lastName = json['last_name'];
  //     email = json['email'];
  //     if (json['profile_img'] != null) {
  //       profileAvatar = json['profile_img'];
  //     }
  //     if (json['address'] != null) {
  //       address = json['address'];
  //     }
  //   } catch (e) {
  //     // bulk edit //print(e.toString());
  //   }
  // }
  @override
  String toString() => 'UserObject { UserObjectname: $uid }';
}
