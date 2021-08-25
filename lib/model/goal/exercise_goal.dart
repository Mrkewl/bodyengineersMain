class ExerciseGoal {
  String? exerciseId;
  int? kg;
  int? rep;
  bool? isCompleted = false;
  ExerciseGoal();

  ExerciseGoal.fromJson(Map<String, dynamic> json) {
    exerciseId = json['exerciseId'];
    kg = int.parse(json['kg'].toString());
    rep = int.parse(json['rep'].toString());
    if (json['isCompleted'] != null) {
      isCompleted = json['isCompleted'];
    }
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'kg': kg,
        'rep': rep,
        'isCompleted': isCompleted,
      };
}
