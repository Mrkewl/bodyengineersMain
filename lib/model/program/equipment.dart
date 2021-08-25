class Equipment {
  String? equipmentId;
  String? equipmentName;

  Equipment.fromMysqlDatabase(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      equipmentId = json['equipment_id'];
      equipmentName = json['equipment_name'];
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }

  Equipment.fromSqflite(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      equipmentId = json['equipmentId'];
      equipmentName = json['equipmentName'];
      // bulk edit //print(muscleId);
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }

  Map<String, dynamic> toJson() => {
        'equipmentId': equipmentId,
        'equipmentName': equipmentName,
      };
  @override
  String toString() =>
      'equipment { equipmentName: $equipmentName, equipmentId : $equipmentId }';
}
