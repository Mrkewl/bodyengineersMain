import '../../helper/tools_helper.dart';

class Muscle {
  String? muscleId;
  String? muscleName;
  String? muscleImg;
  Muscle();
  Muscle.fromMysqlDatabase(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      muscleId = json['muscle_id'];
      muscleName = json['muscle_name'];
      muscleImg = Tools.urlConverter(json['muscle_image']);
      // bulk edit //print(muscleId);
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }
  Muscle.fromSqflite(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      muscleId = json['muscleId'];
      muscleName = json['muscleName'];
      muscleImg = json['muscleImg'];
      // bulk edit //print(muscleId);
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }

  Map<String, dynamic> toJson() => {
        'muscleId': muscleId,
        'muscleName': muscleName,
        'muscleImg': muscleImg,
      };

  @override
  String toString() => 'muscle { muscleName: $muscleName }';
}
