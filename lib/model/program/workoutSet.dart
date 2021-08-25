class WorkoutSet {
  int? rep = 0;
  double kg = 0.0;
  double? volume;
  String? name;
  WorkoutSet();

  WorkoutSet.fromLocalJson(Map<String, dynamic> json) {
    rep = json['rep'];
    kg = double.parse(json['kg'].toString());
  }

  Map<String, dynamic> toJson() => {
        'rep': rep,
        'kg': kg,
      };

  double? getVolume() {
    if (volume == null) {
      volume = (rep! * kg).toDouble();
    }
    return volume;
  }
}
