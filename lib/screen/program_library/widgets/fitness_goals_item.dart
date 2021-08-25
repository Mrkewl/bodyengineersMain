import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:paulonia_cache_image/paulonia_cache_image.dart';

class FitnessGoalItem extends StatelessWidget {
  final String? title;
  final String? image;

  FitnessGoalItem({this.title, this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.22,
            decoration: BoxDecoration(
                        boxShadow: [
                  BoxShadow(
                      blurRadius: 2,
                      spreadRadius: 2,
                      offset: Offset(1, 2),
                      color: Color(0xffd6d6d6))
                      //(0xffd6d6d6)
                ],
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                alignment: Alignment(0,-1),
                  image: PCacheImage(image!,
                      enableInMemory: true, enableCache: true,),
                  fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
              child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
                decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(10),
            )),
          )),
          Positioned(
            top: 10,
            left: 10,
            child: Text(
              title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
