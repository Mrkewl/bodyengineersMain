import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SqfliteHelper {
  final FirebaseAuth auth = FirebaseAuth.instance;
  static final _databaseName = "bodyengineers_10062021.db";

  /// Planner Table
  static final id = '_id';
  static final json = 'json';
  static final uid = 'uid';

  static final userDataTable = 'user_data';

  static final plannerTable = 'planner';
  static final plannerId = '_id';
  static final plannerProgramId = 'program_id';
  static final plannerCalendarJson = 'json';
  static final plannerUid = 'uid';
  static final plannerRegisterDate = 'register_date';
  static final plannerisActive = 'isActive';
  static final plannerisAddon = 'isAddon';

  /// Bodystats  Table
  static final bodystatsTable = 'bodystats';
  static final bodystatsId = '_id';
  static final bodystatsJson = 'json';
  static final bodystatsUid = 'uid';
  static final bodystatsDate = 'date';

  /// Exercise History Table
  static final exerciseHistoryTable = 'exercise_history';
  static final exerciseHistoryId = '_id';
  static final exerciseHistoryJson = 'json';
  static final exerciseHistoryUid = 'uid';
  static final exerciseHistoryDate = 'date';

  /// Goals History Table
  static final goalsTable = 'goals';
  static final goalsId = '_id';
  static final goalsJson = 'json';
  static final goalsUid = 'uid';
  static final goalsDate = 'date';

  /// Progress Photo History Table
  static final progressPhotoHistoryTable = 'progressPhotoHistory';
  static final progressPhotoId = '_id';
  static final progressPhotoJson = 'json';
  static final progressPhotoUid = 'uid';
  static final progressPhotoDate = 'date';

  /// Custom Exercise Table
  static final customExerciseTable = 'customExercise';
  static final customExId = '_id';
  static final customExJson = 'json';
  static final customExUid = 'uid';
  static final customExDate = 'date';

  SqfliteHelper._privateConstructor();
  static final SqfliteHelper instance = SqfliteHelper._privateConstructor();

  // Initialization script split into seperate statements
  // List migrationScripts = [
  //   // '''
  //   // CREATE TABLE IF NOT EXIST $plannerTable($plannerId INTEGER PRIMARY KEY, $plannerProgramId TEXT NOT NULL, $plannerDate TEXT NOT NULL,$plannerExerciseId TEXT NOT NULL,$plannerRep INTEGER NOT NULL,$plannerSets INTEGER NOT NULL,$plannerRpe INTEGER NOT NULL)

  //   // ''', //  Warning!! Only one single line use for version change
  // ];

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await initDatabase();
    return _database;
  }

  // _initDatabase() async {
  //   Directory documentsDirectory = await getApplicationDocumentsDirectory();
  //   String path = join(documentsDirectory.path, _databaseName);
  //   return await openDatabase(path,
  //       version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  // }

  Map<int, String> migrationScripts = {
    1: '''CREATE TABLE $plannerTable
      (
        $plannerId INTEGER PRIMARY KEY, 
        $plannerCalendarJson TEXT NOT NULL, 
        $plannerisActive INTEGER NOT NULL,
        $plannerisAddon INTEGER NOT NULL, 
        $plannerProgramId TEXT NOT NULL, 
        $plannerUid TEXT NOT NULL, 
        $plannerRegisterDate TEXT NOT NULL
        )
      ''',
    2: '''CREATE TABLE $bodystatsTable
      (
        $bodystatsId INTEGER PRIMARY KEY, 
        $bodystatsJson TEXT NOT NULL, 
        $bodystatsUid TEXT NOT NULL, 
        $bodystatsDate TEXT NOT NULL
        )
      ''',
    3: '''CREATE TABLE $exerciseHistoryTable
      (
        $exerciseHistoryId INTEGER PRIMARY KEY, 
        $exerciseHistoryJson TEXT NOT NULL, 
        $exerciseHistoryUid TEXT NOT NULL, 
        $exerciseHistoryDate TEXT NOT NULL
        )
      ''',
    4: '''CREATE TABLE $goalsTable
      (
        $goalsId INTEGER PRIMARY KEY, 
        $goalsJson TEXT NOT NULL, 
        $goalsUid TEXT NOT NULL, 
        $goalsDate TEXT NOT NULL
        )
      ''',
    5: '''CREATE TABLE $progressPhotoHistoryTable
      (
        $progressPhotoId INTEGER PRIMARY KEY, 
        $progressPhotoJson TEXT NOT NULL, 
        $progressPhotoUid TEXT NOT NULL, 
        $progressPhotoDate TEXT NOT NULL
        )
      ''',
    6: '''CREATE TABLE $customExerciseTable
      (
        $customExId INTEGER PRIMARY KEY, 
        $customExJson TEXT NOT NULL, 
        $customExUid TEXT NOT NULL, 
        $customExDate TEXT NOT NULL
        )
      ''',
    7: '''CREATE TABLE $userDataTable
      (
        $id INTEGER PRIMARY KEY, 
        $json TEXT NOT NULL, 
        $uid TEXT NOT NULL 
        )
      ''',
  };

  Future initDatabase() async {
    // count the number of scripts to define the version of the database
    int nbrMigrationScripts = migrationScripts.length;
    var db = await openDatabase(
      join(await getDatabasesPath(), _databaseName),
      version: nbrMigrationScripts,
      // if the database does not exist, onCreate executes all the sql requests of the "migrationScripts" map
      onCreate: (Database db, int version) async {
        for (int i = 1; i <= nbrMigrationScripts; i++) {
          await db.execute(migrationScripts[i]!);
        }
      },

      /// if the database exists but the version of the database is different
      /// from the version defined in parameter, onUpgrade will execute all sql requests greater than the old version
      onUpgrade: (db, oldVersion, newVersion) async {
        for (int i = oldVersion + 1; i <= newVersion; i++) {
          await db.execute(migrationScripts[i]!);
        }
      },
    );
    return db;
  }

  Future<int?> plannerInsert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    if (db != null) return await db.insert(plannerTable, row);
  }

  Future<List<Map<String, dynamic>>?> plannerQueryAllRows() async {
    Database? db = await instance.database;
    if (auth.currentUser != null) {
      String uid = auth.currentUser!.uid;
      int count = Sqflite.firstIntValue(
          await db!.rawQuery(('SELECT COUNT(*) FROM $plannerTable')))!;
      if (count > 0) {
        return await db.query(plannerTable, where: 'uid = ?', whereArgs: [uid]);
      } else {
        // return await db.rawQuery('SELECT * FROM $plannerTable');
      }
    }
  }

  Future plannerDeleteAll() async {
    Database? db = await instance.database;
    if (auth.currentUser != null) {
      String uid = auth.currentUser!.uid;
      return await db!
          .delete(plannerTable, where: '$plannerUid = ?', whereArgs: [uid]);
    }
  }

  Future<int?> plannerUpdate(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    String? programId = row[plannerProgramId];
    String uid = auth.currentUser!.uid;
    try {
      if (db != null)
        return await db.rawUpdate(
            'UPDATE $plannerTable SET $plannerCalendarJson = ? WHERE $plannerUid = "$uid" AND $plannerProgramId = "$programId"',
            [row[plannerCalendarJson]]);
    } catch (e) {
      // bulk edit //print('Error ****');
      // bulk edit //print(e.toString());
    }
  }

  Future<int?> bodystatsInsert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    if (db != null) return await db.insert(bodystatsTable, row);
  }

  Future<List<Map<String, dynamic>>?> bodystatsQueryAllRows() async {
    Database? db = await instance.database;
    if (auth.currentUser != null) {
      String uid = auth.currentUser!.uid;
      int count = Sqflite.firstIntValue(
          await db!.rawQuery(('SELECT COUNT(*) FROM $bodystatsTable')))!;
      if (count > 0) {
        return await db
            .query(bodystatsTable, where: 'uid = ?', whereArgs: [uid]);
      }
    }
  }

  Future bodystatsDeleteAll() async {
    Database? db = await instance.database;
    if (auth.currentUser != null) {
      String uid = auth.currentUser!.uid;
      return await db!
          .delete(bodystatsTable, where: '$bodystatsUid = ?', whereArgs: [uid]);
    }
    // return await db.delete(bodystatsTable);
  }

  Future<int?> bodystatsUpdate(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    String? bodystatId = row[bodystatsId];
    String? uid = row['uid'];
    try {
      return await db!.rawUpdate(
          'UPDATE $bodystatsTable SET $bodystatsJson = ? WHERE $bodystatsUid = "$uid"',
          [row[bodystatsJson]]);
    } catch (e) {
      // bulk edit //print('Error ****');
      // bulk edit //print(e.toString());
    }
  }

  Future<int?> exerciseHistoryInsert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    if (db != null) return await db.insert(exerciseHistoryTable, row);
  }

  Future<List<Map<String, dynamic>>?> exerciseHistoryQueryAllRows() async {
    Database? db = await instance.database;
    if (auth.currentUser != null) {
      String uid = auth.currentUser!.uid;
      int count = Sqflite.firstIntValue(
          await db!.rawQuery(('SELECT COUNT(*) FROM $exerciseHistoryTable')))!;
      if (count > 0) {
        return await db
            .query(exerciseHistoryTable, where: 'uid = ?', whereArgs: [uid]);
      } else {
        // return await db.rawQuery('SELECT * FROM $bodystatsTable');
      }
    }
  }

  Future exerciseHistoryDeleteAll() async {
    Database? db = await instance.database;
    if (db != null) return await db.delete(exerciseHistoryTable);
    // return await db.delete(plannerTable, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int?> exerciseHistoryUpdate(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    String? uid = row['uid'];
    try {
      return await db!.rawUpdate(
          'UPDATE $exerciseHistoryTable SET $exerciseHistoryJson = ? WHERE $exerciseHistoryUid = "$uid"',
          [row[exerciseHistoryJson]]);
    } catch (e) {
      // bulk edit //print('Error ****');
      // bulk edit //print(e.toString());
    }
  }

  Future<int?> goalsInsert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    if (db != null) return await db.insert(goalsTable, row);
  }

  Future<List<Map<String, dynamic>>?> goalsQueryAllRows() async {
    Database? db = await instance.database;
    if (auth.currentUser != null) {
      String uid = auth.currentUser!.uid;
      int count = Sqflite.firstIntValue(
          await db!.rawQuery(('SELECT COUNT(*) FROM $goalsTable')))!;
      if (count > 0) {
        return await db.query(goalsTable, where: 'uid = ?', whereArgs: [uid]);
      } else {
        // return await db.rawQuery('SELECT * FROM $bodystatsTable');
      }
    }
  }

  Future goalsDeleteAll() async {
    Database? db = await instance.database;
    if (db != null) return await db.delete(goalsTable);
    // return await db.delete(plannerTable, where: '$columnId = ?', whereArgs: [id]);
  }

  // ignore: missing_return
  Future<int?> goalsUpdate(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    String? uid = row['uid'];
    try {
      return await db!.rawUpdate(
          'UPDATE $goalsTable SET $goalsJson = ? WHERE $goalsUid = "$uid"',
          [row[exerciseHistoryJson]]);
    } catch (e) {
      // bulk edit //print('Error ****');
      // bulk edit //print(e.toString());
    }
  }

  Future<int> progresPhotoHistoryInsert(Map<String, dynamic> row) async {
    Database? db = await (instance.database);
    return await db!.insert(progressPhotoHistoryTable, row);
  }

  // ignore: missing_return
  Future<List<Map<String, dynamic>>?> progresPhotoHistoryQueryAllRows() async {
    Database? db = await instance.database;
    if (auth.currentUser != null) {
      String uid = auth.currentUser!.uid;
      int count = Sqflite.firstIntValue(await db!
          .rawQuery(('SELECT COUNT(*) FROM $progressPhotoHistoryTable')))!;
      if (count > 0) {
        return await db.query(progressPhotoHistoryTable,
            where: 'uid = ?', whereArgs: [uid]);
      } else {
        // return await db.rawQuery('SELECT * FROM $bodystatsTable');
      }
    }
  }

  Future progresPhotoHistoryDeleteAll() async {
    Database? db = await (instance.database);

    return await db!.delete(progressPhotoHistoryTable);
    // return await db.delete(plannerTable, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int?> progresPhotoHistoryUpdate(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    String? uid = row['uid'];
    try {
      return await db!.rawUpdate(
          'UPDATE $progressPhotoHistoryTable SET $progressPhotoJson = ? WHERE $progressPhotoUid = "$uid"',
          [row[progressPhotoJson]]);
    } catch (e) {
      // bulk edit //print('Error ****');
      // bulk edit //print(e.toString());
    }
  }

  Future<int> customExerciseInsert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(customExerciseTable, row);
  }

  Future<List<Map<String, dynamic>>?> customExerciseQueryAllRows() async {
    Database? db = await instance.database;
    if (auth.currentUser != null) {
      String uid = auth.currentUser!.uid;
      int count = Sqflite.firstIntValue(
          await db!.rawQuery(('SELECT COUNT(*) FROM $customExerciseTable')))!;
      if (count > 0) {
        return await db
            .query(customExerciseTable, where: 'uid = ?', whereArgs: [uid]);
      } else {
        // return await db.rawQuery('SELECT * FROM $bodystatsTable');
      }
    }
  }

  Future customExerciseDeleteAll() async {
    Database? db = await instance.database;

    return await db!.delete(customExerciseTable);
    // return await db.delete(plannerTable, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int?> customExerciseUpdate(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    String? uid = row['uid'];
    try {
      return await db!.rawUpdate(
          'UPDATE $customExerciseTable SET $customExJson = ? WHERE $customExUid = "$uid"',
          [row[customExJson]]);
    } catch (e) {
      // bulk edit //print('Error ****');
      // bulk edit //print(e.toString());
    }
  }

  Future<int> userDataInsert(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(userDataTable, row);
  }

  Future<List<Map<String, dynamic>>?> userDataQueryAllRows() async {
    Database? db = await instance.database;
    if (auth.currentUser != null) {
      String uid = auth.currentUser!.uid;
      int? count = Sqflite.firstIntValue(
          await db!.rawQuery(('SELECT COUNT(*) FROM $userDataTable')));
      if (count != null) {
        if (count > 0) {
          return await db
              .query(userDataTable, where: 'uid = ?', whereArgs: [uid]);
        } else {
          // return await db.rawQuery('SELECT * FROM $languageTable');
        }
      }
    }
  }

  Future userDataTableDeleteAll() async {
    Database? db = await instance.database;

    return await db!.delete(userDataTable);
    // return await db.delete(languageTable, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> userDataTableUpdate(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    String userUid = auth.currentUser!.uid;
    try {
      return await db!.rawUpdate(
          'UPDATE $userDataTable SET $json = ? WHERE $uid = "$userUid"',
          [row[json]]);
    } catch (e) {
      print('Error ****');
      print(e.toString());
      return 0;
    }
  }
}
