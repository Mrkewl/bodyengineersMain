import 'package:flutter/material.dart';

import '../../../model/program/programPhase.dart';
import '../../../translations.dart';

// ignore: must_be_immutable
class ProgramPhaseDetailItem extends StatelessWidget {
  String? phaseNo;
  ProgramPhase? programPhase;
  Function? clickCallBack;
  ProgramPhaseDetailItem({this.phaseNo, this.programPhase, this.clickCallBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Color.fromRGBO(8, 112, 138, 1),
      ),
      margin: EdgeInsets.all(10),
      child: ExpansionTile(
        backgroundColor: Color.fromRGBO(8, 112, 138, 1),
        trailing: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.white,
        ),
        title: Text(
          allTranslations.text('phase')! + ' ' + phaseNo!,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        children: <Widget>[
          ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: programPhase!.programWeek.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: GestureDetector(
                    onTap: () {
                      clickCallBack!((int.parse(phaseNo!) - 1), index);
                      // Navigator.pushNamed(context, '/week_detail');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: Center(
                          child: Text(allTranslations.text('week')! +
                              ' ' +
                              (index + 1).toString())),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
