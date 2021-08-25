class Achievement {
  int? id;
  String? name;
  String? image;
  String? description;
  String? category;
  int? categoryId;
  int gender = 0; //1 => female , 2 => male
  dynamic goal = 0; //1 => female , 2 => male
  bool isCompleted = false;
  DateTime? completedDate;
  late String goalDesc;
  Function? isCompletedFunction;
  Achievement();

  Map<String, dynamic> toJson() => {
        'name': name,
        'image': image,
        'description': description,
        'isCompleted': isCompleted,
      };

  setCategory(int? category) {
    categoryId = category;
    if ([1, 2, 3, 9, 2, 12].contains(categoryId)) {
      // bulk edit //print(goalDesc);
      goal = int.parse(goalDesc);
    }
    if ([4, 5, 6, 7, 8, 10].contains(categoryId)) {
      goal = double.parse(goalDesc);
    }
    if ([11].contains(categoryId)) {
      goal = {'km': 2.4, 'duration': 10};
    }
  }

  Achievement.fromLocalJson(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      id = json['id'];
      name = json['name'].toString();
      goalDesc = json['goal'].toString();

      switch (json['gender']) {
        case 'Unisex':
          gender = 0;
          break;
        case 'Female':
          gender = 1;
          break;
        case 'Male':
          gender = 2;
          break;
      }

      image = json['image'].toString();
      description = json['description'].toString();
      category = json['category'].toString();
    } catch (e, trace) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }

  void checkCompleted(Map<String, dynamic> data, Function callback) {
    switch (categoryId) {
      case 1:
        //it need total completed workout number
        if (data['total_workout_number'] != null) {
          if (data['total_workout_number'] >= goal) {
            isCompleted = true;
            callback(this);
          }
        }
        break;
      case 2:
        //it need total completed program
        if (data['total_completed_program'] != null) {
          if (data['total_completed_program'] >= goal) {
            isCompleted = true;
            callback(this);
          }
        }
        break;
      case 3:
        //it need total completed workout number for week
        if (data['total_workout_number_for_week'] != null) {
          if (data['total_workout_number_for_week'] >= goal) {
            isCompleted = true;
            callback(this);
          }
        }
        break;
      case 4:
        //it need total weight BenchPress and Current Body Weight
        if (data['bench_press_weight'] != null &&
            data['current_weight'] != null) {
          // bulk edit //print(goal);
          double benchWeight =
              double.parse(data['bench_press_weight'].toString());
          // bulk edit //print(benchWeight);
          double currentWeight =
              double.parse(data['current_weight'].toString());
          // bulk edit //print(currentWeight);
          double result = benchWeight / currentWeight;

          // bulk edit //print(result);
          if (result >= goal) {
            isCompleted = true;
            callback(this);
          }
        }
        break;
      case 5:
        //it need total weight DeadliftWeight and Current Body Weight
        if (data['deadlift_weight'] != null && data['current_weight'] != null) {
          // bulk edit //print(goal);
          double deadLiftWeight =
              double.parse(data['deadlift_weight'].toString());
          // bulk edit //print(deadLiftWeight);
          double currentWeight =
              double.parse(data['current_weight'].toString());
          // bulk edit //print(currentWeight);
          double result = deadLiftWeight / currentWeight;

          // bulk edit //print(result);
          if (result >= goal) {
            isCompleted = true;
            callback(this);
          }
        }
        break;
      case 6:
        //it need total weight Squat and Current Body Weight
        if (data['squat_weight'] != null && data['current_weight'] != null) {
          // bulk edit //print(goal);
          double squatWeight = double.parse(data['squat_weight'].toString());
          // bulk edit //print(squatWeight);
          double currentWeight =
              double.parse(data['current_weight'].toString());
          // bulk edit //print(currentWeight);
          double result = squatWeight / currentWeight;

          // bulk edit //print(result);
          if (result >= goal) {
            isCompleted = true;
            callback(this);
          }
        }
        break;
      case 7:

        /// loose bodyweight
        break;
      case 8:

        /// gain bodyweight
        break;

      case 9:
        break;

      case 10:
        //it need old bodyfat and new bodyfat
        if (data['old_bodyfat'] != null && data['new_bodyfat'] != null) {
          // bulk edit //print(goal);
          double oldBodyfat = double.parse(data['old_bodyfat'].toString());
          // bulk edit //print(oldBodyfat);
          double newBodyfat = double.parse(data['new_bodyfat'].toString());
          // bulk edit //print(newBodyfat);
          double result = oldBodyfat - newBodyfat;

          // bulk edit //print(result);
          if (result >= goal) {
            isCompleted = true;
            callback(this);
          }
        }
        break;
      case 11:
        //it need total weight km and duration
        if (data['km'] != null && data['duration'] != null) {
          if (data['km'] >= 2.4 && data['duration'] <= 10) {
            isCompleted = true;

            callback(this);
          }
        }
        break;
      case 12:
        if (data['km'] != null && data['duration'] == null) {
          if (data['km'] >= goal) {
            isCompleted = true;
            callback(this);
          }
        }
        break;
    }
  }
}
