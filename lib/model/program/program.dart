import './programPhase.dart';
import '../../helper/tools_helper.dart';
import '../../model/program/equipment.dart';

class Program {
  String? programId;
  String? programName;
  int? programDuration;
  double? programStar;
  String? programImage;
  String? programVideo;
  String? categoryId;
  String? categoryName;
  int? programDaysPerWeek;
  int? programHoursPerDay;
  String? programLevelId;
  String? programLevelName;
  String? dietDescription;
  String? programDescription;
  bool? isFeatured;
  late bool isAddOn;
  DateTime? createdDate;
  List<ProgramPhase> phaseList = [];
  List<Equipment> equipmentList = [];
  DateTime? startDate;
  DateTime? endDate;
  double avgRate = 5.0;
  int userRate = 0;
  bool isBookMarked = false;
  Program();

  Program.fromMysqlDatabase(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      programId = json['program_id'];
      programName = json['program_name'];
      programDuration = int.parse(json['program_duration']);
      categoryId = json['program_category'];
      categoryName = json['program_category_name'];
      programDescription = json['program_desc'];
      // programStar = json['tutorial_helper_title'];

      if (json['program_image'] != '') {
        programImage = Tools.urlConverter(json['program_image']);
      }
      programDaysPerWeek = int.parse(json['program_days_per_week']);
      if (json['isFeatured'] == '1') {
        isFeatured = true;
      } else {
        isFeatured = false;
      }
      programLevelId = json['program_level'];
      programLevelName = json['program_level_name'];

      if (json['isAddOn'] == '1') {
        isAddOn = true;
      } else {
        isAddOn = false;
      }
      createdDate = DateTime.parse(json['created_date']);
      programVideo = json['program_video_url'];
      programHoursPerDay = int.parse(json['program_hours_per_day']);
      dietDescription = json['diet_description'];
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }

  @override
  String toString() => 'Tutorial { Tutorialname: $programName }';
}
