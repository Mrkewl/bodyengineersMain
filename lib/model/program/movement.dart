class Movement {
  String? movementId;
  String? movementName;

  Movement.fromMysqlDatabase(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      movementId = json['movement_id'];
      movementName = json['movement_name'];
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }

  Movement.fromSqflite(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      movementId = json['movementId'];
      movementName = json['movementName'];
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }

  Map<String, dynamic> toJson() => {
        'movementId': movementId,
        'movementName': movementName,
      };

  @override
  String toString() => 'movement { movementName: $movementName }';
}
