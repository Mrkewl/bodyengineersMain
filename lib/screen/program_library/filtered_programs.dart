import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import './widgets/program_item.dart';
import '../../model/program/program.dart';
import '../../model/program/program_model.dart';
import '../../screen/program_library/widgets/search_program.dart';

class FilteredPrograms extends StatefulWidget {
  @override
  _FilteredProgramsState createState() => _FilteredProgramsState();
}

class _FilteredProgramsState extends State<FilteredPrograms> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  List<Program>? programList;
  bool isSearch = false;
  Map<String, dynamic>? args;

  // ignore: missing_return
  Function? searchCallback(bool callbackIsSearch) {
    setState(() {
      isSearch = callbackIsSearch;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    setState(() {
      args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    });
    setState(() {
      programList = Provider.of<ProgramModel>(context, listen: false)
          .programList
          .where((element) {
        bool result = true;
        if (args!['categoryId'] != null && args!['levelId'] != null) {
          result = element.categoryId == args!['categoryId'] &&
              element.programLevelId == args!['levelId'] &&
              element.programDaysPerWeek! >= args!['min'] &&
              element.programDaysPerWeek! <= args!['max'] &&
              element.programDuration! < args!['duration'];
        } else {
          if (args!['categoryId'] != null) {
            result = element.categoryId == args!['categoryId'] &&
                element.programDaysPerWeek! >= args!['min'] &&
                element.programDaysPerWeek! <= args!['max'] &&
                element.programDuration! < args!['duration'];
          }
          if (args!['levelId'] != null) {
            result = element.programLevelId == args!['levelId'] &&
                element.programDaysPerWeek! >= args!['min'] &&
                element.programDaysPerWeek! <= args!['max'] &&
                element.programDuration! < args!['duration'];
          }
          if (args!['categoryId'] == null && args!['levelId'] == null) {
            result = element.programDaysPerWeek! >= args!['min'] &&
                element.programDaysPerWeek! <= args!['max'] &&
                element.programDuration! < args!['duration'];
          }
        }
        return result;
      }).toList();
    });
    return Scaffold(
      key: _key,
      drawer: buildProfileDrawer(context, user),
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchProgram(
              isSearchCallback: searchCallback,
              programList: programList,
            ),
            if (programList != null && programList!.isEmpty && !isSearch)
              Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 3),
                  child: Text('There is no program match your filter')),
            if (programList != null && !isSearch)
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: programList!.length,
                  itemBuilder: (context, index) => ProgramItem(
                        programId: programList![index].programId,
                        title: programList![index].programName,
                        duration: programList![index].programDuration,
                        image: programList![index].programImage,
                        program: programList![index],
                      ))
          ],
        ),
      ),
    );
  }
}
