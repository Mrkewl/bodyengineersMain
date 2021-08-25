import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import './widgets/fitness_goals_item.dart';
import '../../model/program/program.dart';
import '../../model/program/programCategory.dart';
import '../../model/program/program_model.dart';
import '../../screen/program_library/widgets/program_item.dart';
import '../../screen/program_library/widgets/search_program.dart';

class FitnessGoals extends StatefulWidget {
  @override
  _FitnessGoalsState createState() => _FitnessGoalsState();
}

class _FitnessGoalsState extends State<FitnessGoals> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  ProgramCategory? programCategory;
  List<Program>? programList;
  List<ProgramCategory> subCategoriesprogramList = [];
  bool isSearch = false;

  // ignore: missing_return
  Function? searchCallback(bool callbackIsSearch) {
    setState(() {
      isSearch = callbackIsSearch;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    programCategory = args['programCategory'];
    if (programCategory != null && programList == null) {
      programList = Provider.of<ProgramModel>(context, listen: true)
          .programList
          .where((element) => element.categoryId == programCategory!.categoryId)
          .toList();
      subCategoriesprogramList =
          Provider.of<ProgramModel>(context, listen: false)
              .programCategoryList
              .where((element) =>
                  element.categoryParentId == programCategory!.categoryId)
              .toList();
    }

    return Scaffold(
      key: _key,
      drawer: buildProfileDrawer(context, user),
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!programCategory!.showSubCategory)
              SearchProgram(
                  isSearchCallback: searchCallback, programList: programList),
            if (!isSearch)
              programCategory!.showSubCategory
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) =>
                          subCategoriesprogramList[index].categoryImg != null
                              ? GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/fitness_goals', arguments: {
                                    'programCategory':
                                        subCategoriesprogramList[index]
                                  }),
                                  child: FitnessGoalItem(
                                    title: subCategoriesprogramList[index]
                                        .categoryName,
                                    image: subCategoriesprogramList[index]
                                        .categoryImg,
                                  ),
                                )
                              : Container(),
                      itemCount: subCategoriesprogramList.length,
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) =>
                          programList![index].programImage != null
                              ? ProgramItem(
                                  programId: programList![index].programId,
                                  title: programList![index].programName,
                                  image: programList![index].programImage,
                                  duration: programList![index].programDuration,
                                  avgRating: programList![index].avgRate,
                                  program: programList![index])
                              : Container(),
                      itemCount: programList!.length,
                    ),
          ],
        ),
      ),
    );
  }
}
