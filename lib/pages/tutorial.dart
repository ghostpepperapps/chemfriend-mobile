import 'package:flutter/material.dart';

class Tutorial extends StatefulWidget {
  Tutorial({Key key}) : super(key: key);
  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          controller: _scrollController,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
              child: Column(
                children: <Widget>[
                  Text(
                    "Tutorial",
                    style: TextStyle(fontSize: 18.0),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Thank you for trying Chemfriend! In order to use the app, enter any chemical equation into the text field, with or without products, then press the red arrow. For example, these formats are both valid:\n",
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "• C6H12O6(s) + O2(g)",
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "• H2(g) + O2(g) => H2O(l)\n",
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "Be sure to use the buttons to help enter your equation (for example, instead of typing \"=>\" using the keyboard use the → button):",
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.left,
                  ),
                  Image(image: AssetImage('assets/InputButtons.png')),
                  Text(
                    "Finally, tap the info button that appears to the left of the equations in order to find out how the equation was solved:\n",
                    style: TextStyle(fontSize: 14.0),
                  ),
                  Image(image: AssetImage('assets/InfoButton.png')),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            child: Icon(Icons.cancel)));
  }
}
