import 'package:flutter/material.dart';
import 'dart:io';

class Solution extends StatefulWidget {
  Solution({Key key, this.pickedImage, this.text, this.solution})
      : super(key: key);
  final File pickedImage;
  final String text;
  final String solution;
  @override
  _SolutionState createState() => _SolutionState();
}

class _SolutionState extends State<Solution> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Container(
            height: 200.0,
            width: 200.0,
            decoration: BoxDecoration(
                image: DecorationImage(
              image: FileImage(widget.pickedImage),
            )),
          ),
        ),
        SizedBox(height: 40),
        Center(
            child: Text(
          widget.solution,
          style: TextStyle(fontSize: 20.0),
        ))
      ],
    ));
  }
}
