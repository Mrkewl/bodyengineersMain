import '../../../model/program/program.dart';
import '../../../model/program/program_model.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../../translations.dart';

// ignore: must_be_immutable
class ProgramItem extends StatefulWidget {
  final String? programId;
  final int? duration;
  final String? title;
  final String? image;
  final double? avgRating;
  Program? program;

  ProgramItem(
      {this.programId,
      this.title,
      this.duration,
      this.image,
      this.avgRating,
      this.program});

  @override
  _ProgramItemState createState() => _ProgramItemState();
}

class _ProgramItemState extends State<ProgramItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/program_overview',
              arguments: {'programId': widget.programId});
        },
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.image!,
              imageBuilder: (context, imageProvider) => Container(
                height: MediaQuery.of(context).size.height * 0.25,
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
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.25,
                  child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Positioned.fill(
                child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                  decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(15),
              )),
            )),
            Positioned(
              top: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    allTranslations.text('duration')! + ':',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    widget.duration.toString() +
                        ' ' +
                        allTranslations.text('weeks')!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () {
                  Provider.of<ProgramModel>(context, listen: false)
                      .bookmarkProgram(widget.program!.programId);
                },
                child: Icon(
                  widget.program!.isBookMarked
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color:
                      widget.program!.isBookMarked ? Colors.red : Colors.grey,
                  size: 30,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.45,
                child: Text(
                  widget.title!,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
                bottom: 10,
                right: 10,
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: widget.program!.avgRate > 0
                          ? Color.fromRGBO(86, 177, 191, 1)
                          : Colors.grey,
                      size: MediaQuery.of(context).size.width * 0.04,
                    ),
                    Icon(
                      Icons.star,
                      color: widget.program!.avgRate > 1
                          ? Color.fromRGBO(86, 177, 191, 1)
                          : Colors.grey,
                      size: MediaQuery.of(context).size.width * 0.04,
                    ),
                    Icon(
                      Icons.star,
                      color: widget.program!.avgRate > 2
                          ? Color.fromRGBO(86, 177, 191, 1)
                          : Colors.grey,
                      size: MediaQuery.of(context).size.width * 0.04,
                    ),
                    Icon(
                      Icons.star,
                      color: widget.program!.avgRate > 3
                          ? Color.fromRGBO(86, 177, 191, 1)
                          : Colors.grey,
                      size: MediaQuery.of(context).size.width * 0.04,
                    ),
                    Icon(
                      Icons.star,
                      color: widget.program!.avgRate > 4
                          ? Color.fromRGBO(86, 177, 191, 1)
                          : Colors.grey,
                      size: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
