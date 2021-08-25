import '../../model/program/programDay.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../model/user/user.dart';
import '../../model/user/user_model.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';

// ignore: must_be_immutable
class WorkoutLogNotes extends StatelessWidget {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  Function? callback;
  ProgramDay? programDay;
  @override
  Widget build(BuildContext context) {
    UserObject? user = Provider.of<UserModel>(context, listen: true).user;
    Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    programDay = args['programDay'];
    callback = args['callback'];
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
                   boxShadow: [
                      BoxShadow(
                          blurRadius: 3,
                          spreadRadius: 1,
                          offset: Offset(1, 2),
                          color: Color(0xffd6d6d6))
                    ],
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancel')),
                      Text('Notes'),
                      GestureDetector(
                          onTap: () {
                            callback!();
                            Navigator.pop(context);
                          },
                          child: Text('Save')),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: TextFormField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(15),
                    ),
                    autofocus: true,
                    minLines: 15,
                    maxLines: 25,
                    initialValue: programDay!.notes,
                    onChanged: (value) {
                      programDay!.notes = value;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
