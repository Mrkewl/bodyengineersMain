class ProgramLevel {
  String? levelId;
  String? levelName;
  bool isSelected = false;

  ProgramLevel.fromMysqlDatabase(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      levelId = json['program_level_id'];
      levelName = json['program_level_name'];
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }

  @override
  String toString() => 'ProgramLevel { levelName: $levelName }';
}
