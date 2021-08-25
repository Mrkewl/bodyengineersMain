import './user_privacy.dart';

class UserStats {
  String? uid;
  int totalWorkouts = 0;
  int totalCardio = 0;
  int totalWeight = 0;
  double? maxDeadlift = 0;
  double? maxSquat = 0;
  double maxBench = 0;
  double? bodyFat = 0.0;
  bool isPrivate = false;
  UserPrivacy userPrivacy = UserPrivacy();
  Map<String, dynamic> toBasicJson() {
    return {
      "totalWorkouts": totalWorkouts,
      "totalCardio": totalCardio,
      "totalWeight": totalWeight,
      "maxDeadlift": maxDeadlift,
      "maxSquat": maxSquat,
      "maxBench": maxBench,
      "bodyFat": bodyFat,
    };
  }

  UserStats();
  UserStats.fromJson(Map<String, dynamic> json) {
    try {
      // // bulk edit //print(json);
      uid = json['user_uid'];
      totalWorkouts = json['totalWorkouts'] != null
          ? int.parse(json['totalWorkouts'].toString())
          : 0;

      totalWeight = json['totalWeight'] != null
          ? int.parse(json['totalWeight'].toString())
          : 0;
      maxDeadlift = json['maxDeadlift'] != null
          ? double.parse(json['maxDeadlift'].toString())
          : 0;
      maxSquat = json['maxSquat'] != null
          ? double.parse(json['maxSquat'].toString())
          : 0;
      maxBench = json['maxBench'] != null
          ? double.parse(json['maxBench'].toString())
          : 0;

      bodyFat = double.tryParse(json['bodyFat'].toString());
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }
}
