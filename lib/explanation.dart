import 'package:flutter/material.dart';
import 'package:chemfriend/chemistry/chemistry.dart';

class Explanation extends StatefulWidget {
  Explanation({Key key, this.equation}) : super(key: key);
  final Equation equation;
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
              child: Column(
                children: <Widget>[
                  Text(
                    "Type",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(widget.equation.typeSteps.join('\n') + '\n'),
                  Text(
                    "Product(s)",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(widget.equation.productSteps.join('\n') + '\n'),
                  Text(
                    "Balancing",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(widget.equation.balanceSteps.join('\n'))
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back)));
  }
}
