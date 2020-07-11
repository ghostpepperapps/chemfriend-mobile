import 'package:flutter/material.dart';

class Explanation extends StatefulWidget {
  Explanation({Key key, this.explanation}) : super(key: key);
  String explanation;
  @override
  _ExplanationState createState() => _ExplanationState();
}

class _ExplanationState extends State<Explanation> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          controller: _scrollController,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(widget.explanation)),
            SizedBox(
              height: 80,
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back)));
  }
}
