import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import './widgets/program_library_item.dart';
import './widgets/search_program.dart';
import '../../model/program/programCategory.dart';
import '../../model/program/program_model.dart';

class ProgramLibraryCategories extends StatefulWidget {
  @override
  _ProgramLibraryCategoriesState createState() =>
      _ProgramLibraryCategoriesState();
}

class _ProgramLibraryCategoriesState extends State<ProgramLibraryCategories> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  List<ProgramCategory> categoryList = [];
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
    categoryList = Provider.of<ProgramModel>(context, listen: true)
        .programCategoryList
        .where((element) => element.categoryParentId == '0')
        .toList();
    return Scaffold(
      key: _key,
      drawer: buildProfileDrawer(context, user),
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SearchProgram(
              isSearchCallback: searchCallback,
            ),
            if (!isSearch)
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  return index == 0
                      ? Container(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/fitness_goals',
                                      arguments: {
                                        'programCategory': categoryList[index]
                                      });
                                },
                                child: ProgramLibraryItem(
                                  title: 'BROWSE BY ' +
                                      categoryList[index].categoryName!
                                          .toUpperCase(),
                                  image: categoryList[index].categoryImg,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, '/fitness_featured');
                                },
                                child: ProgramLibraryItem(
                                  title: 'BROWSE BY FEATURED WORKOUT',
                                  image:
                                      'https://dotnetsharing.files.wordpress.com/2019/02/running.jpg',
                                ),
                              ),
                            ],
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/fitness_goals',
                                arguments: {
                                  'programCategory': categoryList[index]
                                });
                          },
                          child: ProgramLibraryItem(
                            title: 'BROWSE BY ' +
                                categoryList[index].categoryName!
                                    .toUpperCase(),
                            image: categoryList[index].categoryImg,
                          ),
                        );
                },
              ),
          ],
        ),
      ),
    );
  }
}
