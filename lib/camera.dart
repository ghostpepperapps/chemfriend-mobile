import 'dart:io';
import 'package:flutter/material.dart';


class Solution extends StatefulWidget {
	Solution({Key key, this.pickedImage, this.text}) : super(key: key);
	final File pickedImage;
	final String text;
	@override
	_SolutionState createState() => _SolutionState();
}

class _SolutionState extends State<Solution> {

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
								image: FileImage(widget.pickedImage), fit: BoxFit.cover
							)
						),
					),
				),
				SizedBox(height: 40),
				Center(
					child: Text(
						widget.text,
						style: TextStyle(fontSize: 30.0),
					)
				),
			],
		)
	);
  }
}