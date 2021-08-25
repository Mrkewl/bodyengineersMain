class UserPrivacy {
  bool totalWorkoutsPrivate = false;
  bool totalCardioPrivate = false;
  bool totalDistancePrivate = false;
  bool totalWeightPrivate = false;
  bool maxDeadliftPrivate = false;
  bool maxSquatPrivate = false;
  bool maxBenchPrivate = false;
  bool maxSprintPrivate = false;
  bool bodyFatPrivate = false;

  bool isPrivate = false;
  Map<String, dynamic> toBasicJson() {
    return {
      "totalWorkoutsPrivate": totalWorkoutsPrivate,
      "totalCardioPrivate": totalCardioPrivate,
      "totalDistancePrivate": totalDistancePrivate,
      "totalWeightPrivate": totalWeightPrivate,
      "maxDeadliftPrivate": maxDeadliftPrivate,
      "maxSquatPrivate": maxSquatPrivate,
      "maxBenchPrivate": maxBenchPrivate,
      "maxSprintPrivate": maxSprintPrivate,
      "bodyFatPrivate": bodyFatPrivate,
    };
  }

  UserPrivacy();
  UserPrivacy.fromJson(Map<String?, dynamic> json) {
    try {
      // // bulk edit //print(json);
      totalWorkoutsPrivate = json['totalWorkoutsPrivate'] == '1';
      totalDistancePrivate = json['totalDistancePrivate'] == '1';
      totalWeightPrivate = json['totalWeightPrivate'] == '1';
      maxDeadliftPrivate = json['maxDeadliftPrivate'] == '1';
      maxSquatPrivate = json['maxSquatPrivate'] == '1';
      maxBenchPrivate = json['maxBenchPrivate'] == '1';
      maxSprintPrivate = json['maxSprintPrivate'] == '1';
      bodyFatPrivate = json['bodyFatPrivate'] == '1';
      //isPrivate = json['isPrivate'];
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }
}
