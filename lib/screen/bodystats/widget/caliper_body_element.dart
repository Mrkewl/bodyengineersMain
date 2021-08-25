import '../../../model/planner/measurement.dart';
import 'package:flutter/material.dart';

class CaliperBodyElement extends StatelessWidget {
  String? measurementUnit;
  Function? changeCallback;
  String? name;
  String? inputKey;
  List<Measurement>? listMeasurement;
  bool? isEdit;
  Measurement measurement = Measurement();
  CaliperBodyElement({
    this.measurementUnit,
    this.changeCallback,
    this.name,
    this.listMeasurement,
    this.inputKey,
    this.isEdit,
  });
  @override
  Widget build(BuildContext context) {
    measurement.name = name;
    measurement.isImperial = measurementUnit == 'cm' ? false : true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        elevation: 7,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name == 'Chest C' ? 'Chest' : name!,
                  style: TextStyle(fontSize: 17),
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          initialValue: listMeasurement!
                                  .where((element) => element.name == name)
                                  .isNotEmpty
                              ? listMeasurement!
                                  .where((element) => element.name == name)
                                  .first
                                  .value
                                  .toString()
                              : '0.0',
                          onChanged: (value) async {
                            if (value != null && value != '') {
                              measurement.value = double.tryParse(value) ??
                                  int.tryParse(value) as double? ??
                                  0.0;
                              changeCallback!(measurement);
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(0.0),
                            isDense: true,
                            border: !isEdit! ? InputBorder.none : null,
                          ),
                          readOnly: !isEdit!,
                        ),
                      ),
                      Text(
                        measurementUnit ?? '',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}
