import '../../model/planner/measurement.dart';

class BodystatsDay {
  String? id;
  DateTime? dateTime;
  bool? isCompleted = false;
  List<Measurement> measurements = [];
  String? programId;
  bool isInitialBodyStat = false;

  BodystatsDay();

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateTime': dateTime!.toIso8601String(),
        'isCompleted': isCompleted,
        'measurements': measurements,
      };

  BodystatsDay.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      dateTime = DateTime.parse(json['dateTime']);
      if (json['isCompleted'] != null) {
        isCompleted = json['isCompleted'];
      }
      if (json['measurements'] != null) {
        for (var item in json['measurements']) {
          measurements.add(Measurement.fromLocalJson(item));
        }
      }
    } catch (e, trace) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }

  String calculateCaliperBodyFat(int? gender, int? age) {
    int result = 0;

    if (gender == 1) {
      double? abdomen = 0.0;
      double? chest = 0.0;
      double? thighs = 0.0;

      if (measurements.where((element) => element.name == 'Abdomen').isNotEmpty)
        abdomen = measurements
            .where((element) => element.name == 'Abdomen')
            .first
            .value;

      if (measurements.where((element) => element.name == 'Chest C').isNotEmpty)
        chest = measurements
            .where((element) => element.name == 'Chest C')
            .first
            .value;

      if (measurements.where((element) => element.name == 'Thighs').isNotEmpty)
        thighs = measurements
            .where((element) => element.name == 'Thighs')
            .first
            .value;

      double sum = abdomen! + chest! + thighs!;

      result = (1.10938 -
              (0.0008267 * sum) +
              (0.0000016 * (sum * sum)) -
              (0.0002574 * age!))
          .round();
    } else {
      double? triceps = 0.0;
      double? suprailiac = 0.0;
      double? thighs = 0.0;

      if (measurements.where((element) => element.name == 'Triceps').isNotEmpty)
        triceps = measurements
            .where((element) => element.name == 'Triceps')
            .first
            .value;

      if (measurements
          .where((element) => element.name == 'Suprailiac')
          .isNotEmpty)
        suprailiac = measurements
            .where((element) => element.name == 'Suprailiac')
            .first
            .value;

      if (measurements.where((element) => element.name == 'Thighs').isNotEmpty)
        thighs = measurements
            .where((element) => element.name == 'Thighs')
            .first
            .value;

      double sum = triceps! + suprailiac! + thighs!;

      result = (1.0994921 -
              (0.0009929 * sum) +
              (0.0000023 * (sum * sum)) -
              (0.0001392 * age!))
          .round();
    }
    result = ((495 / result) - 450).round();
    return result.toString();
  }

  @override
  String toString() => 'BodyStast { name: $dateTime }';
}
