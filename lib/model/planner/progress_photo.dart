class ProgressPhoto {
  String? back;
  String? front;
  String? side;
  DateTime? dateTime;
  Map<String, dynamic> toJson() => {
        'back': back,
        'front': front,
        'side': side,
        'dateTime': dateTime!.toIso8601String(),
      };
  ProgressPhoto();

  ProgressPhoto.fromSqfliteJson(Map<String, dynamic> json) {
    try {
      back = json['back'].toString();
      front = json['front'].toString();
      side = json['side'].toString();
      dateTime = DateTime.parse(json['dateTime']);
    } catch (e) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }
}
