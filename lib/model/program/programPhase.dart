import '../../model/program/programWeek.dart';

class ProgramPhase {
  String? phaseNumber;
  String? programId;
  String? phaseDescription;
  List<ProgramWeek> programWeek = [];
  ProgramPhase.fromMysqlDatabase(Map<String, dynamic> json) {
    try {
      // bulk edit //print(json);
      // bulk edit //print('^^^^^JSON^^^^^');
      programId = json['program_id'];
      phaseNumber = json['phase_number'];
      phaseDescription = json['phase_description'];

      for (var item in json['week_list']) {
        programWeek.add(ProgramWeek.fromMysqlDatabase(item));
      }
    } catch (e) {
      // bulk edit //print(e.toString());
    }
  }
  ProgramPhase();

  @override
  String toString() => 'ProgramPhase { phaseNumber: $phaseNumber }';
}
