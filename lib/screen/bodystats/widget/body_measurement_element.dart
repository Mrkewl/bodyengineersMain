import '../../../model/planner/measurement.dart';
import 'package:flutter/material.dart';

class BodyMeasurementElement extends StatelessWidget {
  String? measurementUnit;
  Function? changeCallback;
  String? name;
  List<Measurement>? listMeasurement;
  Measurement measurement = Measurement();
  bool? isEdit;
  BodyMeasurementElement({
    this.measurementUnit,
    this.changeCallback,
    this.name,
    this.listMeasurement,
    this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    measurement.name = name;
    measurement.isImperial = measurementUnit == 'cm' ? false : true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$name:'),
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
                      contentPadding: isEdit!
                          ? EdgeInsets.symmetric(vertical: 2, horizontal: 3)
                          : EdgeInsets.all(0.0),
                      isDense: true,
                      border: isEdit!
                          ? OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black))
                          : InputBorder.none,
                    ),
                    readOnly: !isEdit!,
                  ),
                ),
                Text(measurementUnit ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
