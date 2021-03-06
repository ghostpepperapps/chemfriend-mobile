import 'package:flutter/material.dart';

import 'about.dart';
import '../main.dart';
import '../custom_header.dart';

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
        appBar: AppBar(
          title: Text('Chemfriend'),
          centerTitle: true,
        ),
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
                    "Enter any equation in the text field, with or without products. Examples:\n",
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "• C6H12O6(s) + O2(g)",
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "• H2(g) + O2(g) => H2O(l)\n",
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "Be sure to use the buttons to help enter your equation (for example, instead of typing \"=>\" use the → button):",
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.left,
                  ),
                  Image(image: AssetImage('assets/InputButtons.png')),
                  Text(
                    "Finally, tap the info button that appears to the left of the equations to find out how the equation was solved:\n",
                    style: TextStyle(fontSize: 14.0),
                  ),
                  Image(image: AssetImage('assets/InfoButton.png')),
                ],
              ),
            ),
          ],
        ),
        drawer: Drawer(
            child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            customHeader(),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Solver'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(title: 'Chemfriend')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => About()),
                );
              },
            ),
          ],
        )),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            child: Icon(Icons.cancel)));
  }
}
