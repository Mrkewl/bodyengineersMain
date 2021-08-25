class Running {
  double? distance; //meter
  Duration? duration;

  Running();

  Map<String, dynamic> toJson() => {
        'distance': distance,
        'duration': duration,
      };

  Running.fromLocalJson(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      if (json['distanceInMeters'] != null) {
        distance = json['distanceInMeters'];
      }
      if (json['durationInSeconds'] != null) {
        duration = Duration(seconds: json['durationInSeconds']);
      }
    } catch (e, trace) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }
}
