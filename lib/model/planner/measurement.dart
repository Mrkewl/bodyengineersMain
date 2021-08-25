class Measurement {
  String? name;
  bool? isImperial;
  double? value = 0.0;
  DateTime? dateTime;
  Measurement();
  Map<String, dynamic> toJson() => {
        'name': name,
        'isImperial': isImperial,
        'value': value,
      };

  Measurement.fromLocalJson(Map<String, dynamic> json) {
    try {
      name = json['name'].toString();
      if (json['isImperial'] != null) {
        isImperial = json['isImperial'];
      }
      value = json['value'];
    } catch (e, trace) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }
}
