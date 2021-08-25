class AchievementCategory {
  int? id;
  String? name;

  AchievementCategory();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  AchievementCategory.fromLocalJson(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      id = json['category_id'];
      name = json['category_name'].toString();
    } catch (e, trace) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }
}
