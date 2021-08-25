import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ProgramLibraryItem extends StatelessWidget {
  final String? title;
  final String? image;

  ProgramLibraryItem({this.title, this.image});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: image!,
            imageBuilder: (context, imageProvider) => Container(
              height: MediaQuery.of(context).size.height * 0.2,
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
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) => Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.2,
                child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
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
            bottom: 10,
            left: 10,
            right: 10,
            child: Text(
              title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
