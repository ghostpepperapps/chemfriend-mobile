import 'dart:io';
import 'package:flutter/material.dart';

class Solution extends StatefulWidget {
  Solution({Key key, this.solution}) : super(key: key);
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
        SizedBox(height: 40),
        Center(
            child: Text(
          widget.solution,
          style: TextStyle(fontSize: 20.0),
        )),
        SizedBox(height: 40),
        Center(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
          ),
        )
      ],
    ));
  }
}
