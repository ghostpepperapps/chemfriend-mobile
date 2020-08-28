import 'package:flutter/material.dart';

import 'tutorial.dart';
import '../main.dart';
import '../custom_header.dart';

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
                    "About Chemfriend",
                    style: TextStyle(fontSize: 18.0),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Chemfriend is an app for high school students studying chemistry. Currently, it is able to solve chemical equations taught in the Alberta Science 10 PreAP curriculum.",
                    style: TextStyle(fontSize: 14.0),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 18),
                  ListTile(
                      leading: Icon(Icons.create),
                      title:
                          Text("Created by Saptarshi Bhattacherya in 2020")),
                  ListTile(
                      leading: Icon(Icons.email),
                      title: Text("ghostpepperappswb@gmail.com")),
                  ListTile(
                      leading: Icon(Icons.view_carousel),
                      title: Text("v1.0.0"))
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
              leading: Icon(Icons.school),
              title: Text('Tutorial'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Tutorial()),
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
