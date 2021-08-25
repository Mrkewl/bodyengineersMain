import './workout.dart';

class ProgramDay {
  String? id;
  String? name;
  int? countDay;
  List<Workout> workoutList = [];
  bool isDayCompleted = false;
  DateTime? dateTime;
  String? uid;
  String? programId;
  String? phaseNumber;
  String? weekNumber;
  bool isSelected = false; //only add workout page
  bool? isBodyStatsDay = false;
  String? notes = '';
  bool? isAddonDay;
  DateTime? registerDate;
  ProgramDay();
  ProgramDay.fromMysqlDatabase(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      name = json['name'];
      countDay = json['countDay'];
      for (var workout in json['exercise_list']) {
        workoutList.add(Workout.fromMysqlDatabase(workout));
      }
      if (workoutList.isNotEmpty) {
        workoutList.sort((a, b) => a.order!.compareTo(b.order!));
      }
      if (json['isBodyStats'] != null) {
        isBodyStatsDay = json['isBodyStats'];
      }
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }

  equalizeUserSets() {
    workoutList.forEach((element) {
      element.equalizeSets();
    });
  }

  checkCompleted() {
    workoutList.removeWhere((element) => element.sets! <= 0);
    workoutList.forEach((element) {
      element.checkDone(); // it is checking workout completed
    });
    isDayCompleted = true;
    // if (workoutList.where((workout) => workout.isItDone == false).isEmpty) {
    //   isDayCompleted = true;
    // } else {
    //   isDayCompleted = false;
    // }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'countDay': countDay,
        'workoutList': workoutList,
        'dateTime': dateTime!.toIso8601String(),
        'registerDate':
            registerDate != null ? registerDate!.toIso8601String() : null,
        'uid': uid,
        'programId': programId,
        'isDayCompleted': isDayCompleted,
        'phaseNumber': phaseNumber,
        'weekNumber': weekNumber,
        'isBodyStatsDay': isBodyStatsDay,
        'notes': notes,
        'isAddonDay': isAddonDay,
      };

  ProgramDay.fromLocalJson(Map<String, dynamic> json) {
    try {
      name = json['name'].toString();
      countDay = json['countDay'];
      for (var workout in json['workoutList']) {
        workoutList.add(Workout.fromLocalJson(workout));
      }
      dateTime = DateTime.parse(json['dateTime']);
      if (json['registerDate'] != null)
        registerDate = DateTime.parse(json['registerDate']);
      uid = json['uid'];
      programId = json['programId'];
      if (json['isDayCompleted'] != null) {
        isDayCompleted = json['isDayCompleted'];
      }
      weekNumber = json['weekNumber'];
      phaseNumber = json['phaseNumber'];
      isBodyStatsDay = json['isBodyStatsDay'];
      isAddonDay = json['isAddonDay'];
  
      notes = json['notes'];
    } catch (e) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }

  @override
  String toString() => 'ProgramDay { name: $name }';
}
