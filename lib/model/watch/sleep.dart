class Sleep {
  Duration? totalSleepTime;
  Duration? sleepTiming;
  Duration? deepSleep;
  Duration? lightSleep;
  Duration? remSleep;
  Duration? awake;

  Sleep();

  Map<String, dynamic> toJson() => {
        'totalSleepTime': totalSleepTime,
        'sleepTiming': sleepTiming,
        'deepSleep': deepSleep,
        'lightSleep': lightSleep,
        'remSleep': remSleep,
        'awake': awake,
      };

  Sleep.fromLocalJson(Map<String, dynamic> json) {
    try {
      totalSleepTime = json['totalSleepTime'];
      sleepTiming = json['sleepTiming'];
      deepSleep = json['deepSleep'];
      lightSleep = json['lightSleep'];
      remSleep = json['remSleep'];
      awake = json['awake'];
    } catch (e, trace) {
      // bulk edit //print(e.toString());
      // bulk edit //print(trace.toString());
    }
  }
}
