import '../../../screen/program_library/widgets/search_program.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../model/program/program.dart';
import '../../model/program/program_model.dart';
import 'widgets/program_item.dart';

class Bookmarks extends StatefulWidget {
  @override
  _BookmarksState createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool isSearch = false;

  // ignore: missing_return
  Function? searchCallback(bool callbackIsSearch) {
    setState(() {
      isSearch = callbackIsSearch;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    List<Program> programList = Provider.of<ProgramModel>(context, listen: true)
        .programList
        .where((element) => element.isBookMarked == true)
        .toList();
    return Scaffold(
      key: _key,
      drawer: buildProfileDrawer(context, user),
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchProgram(
                isSearchCallback: searchCallback, programList: programList),
            if (!isSearch)
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) =>
                    programList[index].programImage != null
                        ? ProgramItem(
                            programId: programList[index].programId,
                            title: programList[index].programName,
                            image: programList[index].programImage,
                            duration: programList[index].programDuration,
                            avgRating: programList[index].avgRate,
                            program: programList[index],
                          )
                        : Container(),
                itemCount: programList.length,
              ),
          ],
        ),
      ),
    );
  }
}
