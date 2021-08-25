import '../../model/planner/planner_model.dart';
import '../../model/user/user_model.dart';
import 'package:flutter/material.dart';
import '../../model/planner/bodystatsDay.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart' as intl;
import '../common_appbar.dart';
import '../common_drawer.dart';
import '../../model/user/user.dart';

class CaliperBodyHistory extends StatefulWidget {
  @override
  _CaliperBodyHistoryState createState() => _CaliperBodyHistoryState();
}

class _CaliperBodyHistoryState extends State<CaliperBodyHistory> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  UserObject? user;
  int? age;
  int? gender;
  bodystatsDayCallback(BodystatsDay bodystatsDayCallbackElement) {
    setState(() {
      Provider.of<PlannerModel>(context, listen: false)
          .addBodyStatsDay(bodystatsDay: bodystatsDayCallbackElement);
    });
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context, listen: false).user;
    age = DateTime.now().year - user!.birthday!.year;
    gender = user!.gender;
    List<BodystatsDay?> bodystatDay =
        Provider.of<PlannerModel>(context, listen: true)
            .bodystatsDayList
            .where((bDay) => bDay!.measurements
                .where((measure) =>
                    measure.name == 'Abdomen' ||
                    measure.name == 'Chest C' ||
                    measure.name == 'Thighs' ||
                    measure.name == 'Triceps' ||
                    measure.name == 'Suprailiac' ||
                    measure.name == 'Thighs')
                .isNotEmpty)
            .toList();

    bodystatDay.sort((a, b) => a!.dateTime!.compareTo(b!.dateTime!));
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
                      'Caliper Body Fat History',
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
                itemCount: bodystatDay.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/caliper_bodyfat',
                          arguments: {
                            'bodystatsDayCallback': bodystatsDayCallback,
                            'bodystatsDay': bodystatDay[index]
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
                              .format(bodystatDay[index]!.dateTime!)),
                          Text(intl.DateFormat('yMd')
                              .format(bodystatDay[index]!.dateTime!)),
                          Text(bodystatDay[index]!
                                  .calculateCaliperBodyFat(gender, age) +
                              '%'),
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
