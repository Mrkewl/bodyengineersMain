import './movement.dart';
import './equipment.dart';
import './muscle.dart';

List<String> cardioExerciseList = ['Running'];

class Exercise {
  String? exerciseId;
  String? exerciseName;
  String? exerciseVideo;
  String? exerciseInstructions;
  List<Muscle> muscleGroup = [];
  List<Movement> movementGroup = [];
  List<Equipment> equipmentGroup = [];
  bool isSelected = false;
  bool? isCardio = false;
  bool? isVideoLocal = false;
  bool? isCustom = false;
  String? exerciseIcon;
  Exercise();
  Exercise.fromMysqlDatabase(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      exerciseId = json['exercise_id'];
      exerciseName = json['exercise_name'];
      if (cardioExerciseList.contains(exerciseName)) {
        isCardio = true;
        exerciseIcon = 'assets/images/workout/running.png';
      } else {
        exerciseVideo = json['exercise_url'];
        exerciseInstructions = json['exercise_instructions'];
        for (var muscle in json['muscle_group']) {
          muscleGroup.add(Muscle.fromMysqlDatabase(muscle));
        }
        for (var movement in json['movement_group']) {
          movementGroup.add(Movement.fromMysqlDatabase(movement));
        }
        for (var equipment in json['equipment_group']) {
          equipmentGroup.add(Equipment.fromMysqlDatabase(equipment));
        }
      }
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }
  Exercise.fromSqflite(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      exerciseId = json['exerciseId'];
      exerciseName = json['exerciseName'];
      isVideoLocal = json['isVideoLocal'];
      isCustom = json['isCustom'];
      isCardio = json['isCardio'];
      if (cardioExerciseList.contains(exerciseName)) {
        isCardio = true;
        exerciseIcon = 'assets/images/workout/running.png';
      } else {
        exerciseVideo = json['exerciseVideo'];
        exerciseInstructions = json['exerciseInstructions'];
        for (var muscle in json['muscleGroup']) {
          muscleGroup.add(Muscle.fromSqflite(muscle));
        }
        for (var movement in json['movementGroup']) {
          movementGroup.add(Movement.fromSqflite(movement));
        }
        for (var equipment in json['equipmentGroup']) {
          equipmentGroup.add(Equipment.fromSqflite(equipment));
        }
      }
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'exerciseVideo': exerciseVideo,
        'exerciseInstructions': exerciseInstructions,
        'muscleGroup': muscleGroup,
        'movementGroup': movementGroup,
        'equipmentGroup': equipmentGroup,
        'isSelected': isSelected,
        'isCardio': isCardio,
        'isVideoLocal': isVideoLocal,
        'isCustom': isCustom,
        'exerciseIcon': exerciseIcon,
      };


      List<String?> getListofMuscleMovement(){
        List<String?> result = [];
        result.addAll(muscleGroup.map((e) => e.muscleName).toList());
        result.addAll(movementGroup.map((e) => e.movementName).toList());
        return result;
      }

  @override
  String toString() => 'Exercise { exerciseName: $exerciseName }';
}
