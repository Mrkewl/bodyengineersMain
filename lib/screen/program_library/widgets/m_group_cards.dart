import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MuscleGroupCard extends StatelessWidget {
  String? title;
  int? value;

  MuscleGroupCard({this.title, this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Text('$title: '),
            Text('$value Sets'),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class MovementGroupCard extends StatelessWidget {
  String? title;
  int? value;

  MovementGroupCard({this.title, this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            Text('$title: '),
            Text('$value Exercises'),
          ],
        ),
      ),
    );
  }
}
