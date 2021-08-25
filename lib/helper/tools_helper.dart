import '../model/planner/bodystatsDay.dart';
import '../model/planner/measurement.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tools {
  static String urlConverter(url) {
    return 'https://www.bodyengineersapp.xyz/' + url;
  }

  static String? convertKgtoLbs(kg) {
    return (kg * 2.20462262).toStringAsFixed(0);
  }

  static String? convertLbstoKg(lbs) {
    // bulk edit //print('lbs ==>' + lbs.toString());
    return (lbs / 2.20462262).toStringAsFixed(0);
  }

  static Future<String?> convertWeight(weight) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var preferedUnit = prefs.get('unit') ?? prefs.get('database_unit');
    var databaseUnit = prefs.get('database_unit');
    return databaseUnit == 1 && preferedUnit == 2
        ? Tools.convertKgtoLbs(weight)
        : databaseUnit == 2 && preferedUnit == 1
            ? Tools.convertLbstoKg(weight)
            : weight.toString();
  }

  static double calculateLeanMuscleMass({int? bodyWeight, double? bodyFat}) {
    return bodyWeight != null && bodyFat != null
        ? bodyWeight * (100 - bodyFat) / 100
        : 0;
  }

  static List<Measurement> filterMeasurementFromBodystatDay(
      {String? measurementName,
      required List<BodystatsDay?> bodystatsDayList}) {
    List<Measurement> measurementList = bodystatsDayList
        .map((e) => e!.measurements
                .where((element) => element.name == measurementName)
                .map((e2) {
              e2.dateTime = e.dateTime;
              return e2;
            }).toList())
        .toList()
        .reduce((a, b) {
      a.addAll(b);
      return a;
    });
    measurementList.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
    return measurementList;
  }

  static Future<String?> convertedWeightForDatabase(weight) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var preferedUnit = prefs.getInt('unit') ?? prefs.getInt('database_unit');
    var databaseUnit = prefs.getInt('database_unit');
    return databaseUnit == 1 && preferedUnit == 2
        ? Tools.convertLbstoKg(weight)
        : databaseUnit == 2 && preferedUnit == 1
            ? Tools.convertKgtoLbs(weight)
            : weight.toString();
  }

  static String? convertCmtoInch(cm) {
    return (cm / 2.54).toStringAsFixed(0);
  }

  static String? convertInchtoCm(inch) {
    // bulk edit //print('lbs ==>' + inch.toString());
    return (inch * 2.54).toStringAsFixed(0);
  }

  static Future<String?> convertedLengthForDatabase(length) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var preferedUnit = prefs.getInt('unit') ?? prefs.getInt('database_unit');
    var databaseUnit = prefs.getInt('database_unit');
    length = int.parse(length);
    return databaseUnit == 1 && preferedUnit == 2
        ? Tools.convertInchtoCm(length)
        : databaseUnit == 2 && preferedUnit == 1
            ? Tools.convertCmtoInch(length)
            : length.toString();
  }

  static Future<String?> convertLength(length) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var preferedUnit = prefs.get('unit') ?? prefs.get('database_unit');
    var databaseUnit = prefs.get('database_unit');
    // bulk edit //print('length ==>' + length);
    length = int.parse(length);
    return databaseUnit == 1 && preferedUnit == 2
        ? Tools.convertCmtoInch(length)
        : databaseUnit == 2 && preferedUnit == 1
            ? Tools.convertInchtoCm(length)
            : length.toString();
  }

  static bool isSameDate(date1, date2) {
    return date2.year == date1.year &&
        date2.month == date1.month &&
        date2.day == date1.day;
  }

  static int leanMuscleMassPoint({double? leanMuscleMass, int? gender}) {
    int result = 0;
    if (leanMuscleMass != null) {
      if (gender == 1) {
        // FEMALE
        if (leanMuscleMass < 12) {
          result = 20;
        } else if (leanMuscleMass > 12 && leanMuscleMass <= 15) {
          result = 30;
        } else if (leanMuscleMass > 16 && leanMuscleMass <= 30) {
          result = 40;
        } else if (leanMuscleMass > 31 && leanMuscleMass <= 36) {
          result = 15;
        } else {
          ///>36
          result = 5;
        }
      } else {
        if (leanMuscleMass < 5) {
          result = 15;
        } else if (leanMuscleMass > 5 && leanMuscleMass <= 10) {
          result = 30;
        } else if (leanMuscleMass > 11 && leanMuscleMass <= 25) {
          result = 40;
        } else if (leanMuscleMass > 26 && leanMuscleMass <= 31) {
          result = 15;
        } else {
          ///>31
          result = 5;
        }
      }
    }

    return result;
  }

  static int bodyfatPoint({required double bodyFat}) {
    int result = 0;
    if (bodyFat < 12) {
      result = 30;
    } else if (bodyFat > 12 && bodyFat <= 15) {
      result = 40;
    } else if (bodyFat > 16 && bodyFat <= 30) {
      result = 30;
    } else if (bodyFat > 31 && bodyFat <= 36) {
      result = 16;
    } else {
      ///>36
      result = 8;
    }
    return result;
  }

  static String convertUrltoVideoId({required String url}) {
    List splittedUrl = [];
    String videoId = '';
    if (url.contains('watch?v=')) {
      splittedUrl = url.split('watch?v=');
    }
    if (splittedUrl.length > 1) {
      videoId = splittedUrl[1];
    }
    return videoId;
  }

  static String getYoutubeThumb({required String url}) {
    var videoId = convertUrltoVideoId(url: url);
    String result = 'http://i3.ytimg.com/vi/' + videoId + '/0.jpg';
    // String result = 'http://i3.ytimg.com/vi/' + videoId + '/maxresdefault.jpg';
    return result;
  }
}
