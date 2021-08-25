import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../be_theme.dart';
import '../../model/program/program_model.dart';
import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../../model/planner/planner_model.dart';
import '../../translations.dart';

class ProgramLibrary extends StatefulWidget {
  @override
  _ProgramLibraryState createState() => _ProgramLibraryState();
}

class _ProgramLibraryState extends State<ProgramLibrary> {
  MyTheme theme = MyTheme();

  overwritePopup(BuildContext context, UserObject? user) {
    AlertDialog alert = AlertDialog(
      title: Text(allTranslations.text('create_new_program')!),
      content: Text(allTranslations.text('already_program')!),
      actions: [
        FlatButton(
          child: Text(
            allTranslations.text('cancel')!,
            style:
                TextStyle(color: Color.fromRGBO(8, 112, 138, 1), fontSize: 16),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        FlatButton(
          child: Text(
            allTranslations.text('yes_overwrite')!,
            style:
                TextStyle(color: Color.fromRGBO(8, 112, 138, 1), fontSize: 16),
          ),
          onPressed: () async {
            // await Provider.of<ProgramModel>(context, listen: false)
            //     .cleanAllProgram();
            // await Provider.of<PlannerModel>(context, listen: false)
            //     .cleanAllProgram();
            // Navigator.pop(context);
            await Navigator.pushNamed(context, '/create_new_program');
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showBluePrintAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(15),
          actionsPadding: EdgeInsets.all(0),
          content: Text(
              "BodyEngineers Blueprint feature is currently under Development."),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  showProgramLibraryAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(15),
          actionsPadding: EdgeInsets.all(0),
          content: Text(
              "Program Library contains many workout programs to get you started on your fitness journey."),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  comingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            allTranslations.text('coming_soon')!,
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  @override
  void initState() {
    print('Program Library Page is Created =>' +
        DateTime.now().second.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;

    return SingleChildScrollView(
      child: Container(
        color: theme.currentTheme() == ThemeMode.dark
            ? Colors.grey[850]
            : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  // Provider.of<ProgramModel>(context, listen: false)
                  //     .fetchProgram();
                  Navigator.pushNamed(context, '/bookmarks');
                },
                child: Card(
                  shadowColor: Color(0xffd6d6d6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 7,
                  color: theme.currentTheme() == ThemeMode.dark
                      ? Colors.grey[50]
                      : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        Text(
                          allTranslations.text('bookmark')!,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.chevron_right,
                            color: Colors.black54,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 7),
              GestureDetector(
                onTap: () async {
                  if (Provider.of<PlannerModel>(context, listen: false)
                      .programDayList
                      .isNotEmpty) {
                    overwritePopup(context, user);
                  } else {
                    Navigator.pushNamed(context, '/create_new_program');
                  }
                },
                child: Card(
                  shadowColor: Color(0xffd6d6d6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: theme.currentTheme() == ThemeMode.dark
                      ? Colors.grey[50]
                      : Colors.white,
                  elevation: 7,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        Text(
                          allTranslations.text('create_own_program')!,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.chevron_right,
                            color: Colors.black54,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 7),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.5),
                child: GestureDetector(
                  onTap: () => comingSoonDialog(context),
                  child: Container(
                    padding: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: theme.currentTheme() == ThemeMode.dark
                          ? Colors.grey[50]
                          : Colors.white,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Spacer(),
                            Text(
                              'Body Engineer Blueprint',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                  onTap: () =>
                                      showBluePrintAlertDialog(context),
                                  child: Icon(Icons.info_outline)),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            allTranslations.text('blueprint_desc')!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                  offset: Offset(1, 2),
                                  color: Color(0xffd6d6d6))
                            ],
                          ),
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                              topRight: Radius.circular(8),
                              topLeft: Radius.circular(8),
                            ),
                            child: Image(
                              image: AssetImage(
                                  'assets/images/program_library/blueprint.jpg'),
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  // Provider.of<ProgramModel>(context, listen: false)
                  //     .fetchProgram();
                  Navigator.pushNamed(context, '/program_categories');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.5),
                  child: Container(
                    padding: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: theme.currentTheme() == ThemeMode.dark
                          ? Colors.grey[50]
                          : Colors.white,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Spacer(),
                            Text(
                              allTranslations.text('program_library')!,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: GestureDetector(
                                  onTap: () =>
                                      showProgramLibraryAlertDialog(context),
                                  child: Icon(Icons.info_outline)),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            allTranslations.text('program_library_desc')!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                  offset: Offset(1, 2),
                                  color: Color(0xffd6d6d6))
                            ],
                          ),
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                              topRight: Radius.circular(8),
                              topLeft: Radius.circular(8),
                            ),
                            child: Image(
                              image: AssetImage(
                                  'assets/images/program_library/programlibrary.jpg'),
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
