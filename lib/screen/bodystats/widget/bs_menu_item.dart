import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BsMenuItem extends StatelessWidget {
  final bool? isFilled;
  final String? title;
  final String? icon;

  BsMenuItem({this.isFilled, this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 15.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: isFilled!
              ? Color.fromRGBO(8, 112, 138, 1)
              : Color.fromRGBO(86, 177, 191, 1),
                  boxShadow: [
                      BoxShadow(
                          blurRadius: 3,
                          spreadRadius: 1,
                          offset: Offset(1, 2),
                          color: Color(0xffd6d6d6))
                    ],),
      height: MediaQuery.of(context).size.height * 0.095,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0)),
            color: Colors.white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  height: 30,
                  width: 30,
                  child: SvgPicture.asset(
                    icon!,
                  ),
                ),
              ),
              Text(
                title!,
                style: TextStyle(
                  fontSize: 20,
                  color: Color.fromRGBO(44, 44, 44, 1),
                ),
              ),
            ],
          )),
    );
  }
}
