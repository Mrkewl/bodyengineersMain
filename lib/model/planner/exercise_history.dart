class ExerciseHistoryElement {
  DateTime? dateTime;
  int? exerciseId;
  int? rep;
  double? weight;
  int? workoutId;
  String? name;

  ExerciseHistoryElement.fromSqfliteJson(Map<String, dynamic> json) {
    dateTime = DateTime.parse(json['dateTime'].toString());
    exerciseId = int.parse(json['exerciseId'].toString());
    workoutId = int.parse(json['workoutId'].toString());
    rep = json['rep'];
    weight = double.parse(json['weight'].toString());
    name = json['name'];
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'dateTime': dateTime!.toIso8601String(),
        'rep': rep,
        'weight': weight,
        'workoutId': workoutId,
        'name': name,
      };
}
