import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../model/program/program.dart';
import '../../../model/program/program_model.dart';
import '../../../screen/program_library/widgets/program_item.dart';
import '../../../translations.dart';

// ignore: must_be_immutable
class SearchProgram extends StatefulWidget {
  Function? isSearchCallback;
  List? programList;
  SearchProgram({this.isSearchCallback, this.programList});
  @override
  _SearchProgramState createState() => _SearchProgramState();
}

class _SearchProgramState extends State<SearchProgram> {
  bool isSearch = false;

  List<Program>? programList = [];
  List<Program> searchProgramList = [];

  TextEditingController searchController = TextEditingController();

  void changeSearch(String value) {
    if (searchController.text != '') {
      setState(() {
        searchProgramList = programList!
            .where((element) =>
                element.programName!
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()) ||
                element.categoryName!
                    .toLowerCase()
                    .contains(searchController.text.toLowerCase()))
            .toList();
        isSearch = true;
      });
    } else {
      setState(() {
        searchProgramList = [];
        isSearch = false;
      });
    }
    widget.isSearchCallback!(isSearch);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.programList != null) {
      programList = widget.programList as List<Program>?;
    } else {
      programList =
          Provider.of<ProgramModel>(context, listen: false).programList;
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.05,
                  child: TextField(
                    controller: searchController,
                    onChanged: changeSearch,
                    textAlignVertical: TextAlignVertical.bottom,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color.fromRGBO(86, 177, 191, 1),
                      ),
                      hintText: allTranslations.text('search')!,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(86, 177, 191, 1),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/filter_page');
                  },
                  child: Icon(
                    Icons.filter_list,
                    size: MediaQuery.of(context).size.width * 0.08,
                    color: Color.fromRGBO(8, 112, 138, 1),
                  ),
                ),
              ],
            ),
          ),
          if (isSearch && searchProgramList.isEmpty)
            Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 3),
                child: Text('There is no program match your search')),
          if (isSearch)
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: searchProgramList.length,
              itemBuilder: (context, index) => ProgramItem(
                programId: searchProgramList[index].programId,
                title: searchProgramList[index].programName,
                image: searchProgramList[index].programImage,
                duration: searchProgramList[index].programDuration,
                avgRating: searchProgramList[index].avgRate,
                program: searchProgramList[index],
              ),
            )
        ],
      ),
    );
  }
}
