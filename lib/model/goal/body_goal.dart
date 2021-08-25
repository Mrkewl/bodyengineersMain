class BodyGoal {
  String? name;
  double? goal;
  bool? isCompleted = false;
  bool? isLoose = false;
  double? initial;
  BodyGoal();

  BodyGoal.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    goal = double.parse(json['goal'].toString());
    initial = double.parse(json['initial'].toString());
    if (json['isCompleted'] != null) {
      isCompleted = json['isCompleted'];
    }
    if (json['isLoose'] != null) {
      isLoose = json['isLoose'];
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'goal': goal,
        'initial': initial,
        'isCompleted': isCompleted,
        'isLoose': isLoose,
      };
}
