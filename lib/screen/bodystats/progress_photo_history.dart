import '../../model/planner/planner_model.dart';
import '../../model/planner/progress_photo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import '../../translations.dart';
import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user.dart';

class ProgressPhotoHistory extends StatefulWidget {
  @override
  _ProgressPhotoHistoryState createState() => _ProgressPhotoHistoryState();
}

class _ProgressPhotoHistoryState extends State<ProgressPhotoHistory> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  UserObject? user;

  @override
  Widget build(BuildContext context) {
    List<ProgressPhoto?> progressPhotoList =
        Provider.of<PlannerModel>(context, listen: true).progressPhotoList
          ..sort((a, b) => a!.dateTime!.compareTo(b!.dateTime!));
    return Scaffold(
      key: _key,
      appBar: setAppBar(_key) as PreferredSizeWidget?,
      drawer: buildProfileDrawer(context, user),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.chevron_left,
                          size: 30,
                        ),
                      ),
                    ),
                    Text(
                      allTranslations.text('progress_photo_history')!,
                      style: TextStyle(fontSize: 20),
                    ),
                    GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.info_outline,
                          size: 25,
                        )),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: progressPhotoList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/progress_photo',
                          arguments: {
                            'datetime': progressPhotoList[index]!.dateTime
                          });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 7),
                      padding: EdgeInsets.all(15),
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(intl.DateFormat('EEEE')
                              .format(progressPhotoList[index]!.dateTime!)),
                          Spacer(),
                          Text(intl.DateFormat('yMMMMd')
                              .format(progressPhotoList[index]!.dateTime!)),
                          Spacer(),
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
