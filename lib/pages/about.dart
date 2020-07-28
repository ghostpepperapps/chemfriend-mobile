import 'package:flutter/material.dart';

class About extends StatefulWidget {
  About({Key key}) : super(key: key);
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
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
                    "About Chemfriend",
                    style: TextStyle(fontSize: 18.0),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Chemfriend is an app created by Saptarshi Bhattacherya for high school students studying chemistry. Currently, it is able to solve chemical equations taught in the Alberta Science 10 PreAP curriculum.",
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.left,
                  ),
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
