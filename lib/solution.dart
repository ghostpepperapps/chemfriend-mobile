import 'package:flutter/material.dart';
import 'package:chemfriend/chemistry/chemistry.dart';

import 'input.dart';
import 'explanation.dart';

class Solution extends StatefulWidget {
  Solution({Key key, this.equation, this.solution, this.type})
      : super(key: key);
  Equation equation;
  String solution;
  String type;
  @override
  _SolutionState createState() => _SolutionState();
}

class _SolutionState extends State<Solution> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
      controller: _scrollController,
      children: <Widget>[
        SizedBox(height: 20),
        Center(
            child: Text(
          'Type: ${widget.type}',
          style: TextStyle(fontSize: 25.0, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        )),
        SizedBox(height: 20),
        Center(
            child: Row(children: <Widget>[
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: FloatingActionButton(
                heroTag: '_pushExplanation',
                child: Icon(Icons.info),
                mini: true,
                backgroundColor: Colors.green,
                onPressed: () {
                  _pushExplanation(context);
                  _textController.text = '';
                },
              ),
            ),
          ),
          Expanded(
              flex: 8,
              child: Padding(
                  padding: EdgeInsets.all(3.0),
                  child: Text(widget.solution,
                      style: TextStyle(fontSize: 20.0),
                      textAlign: TextAlign.center))),
        ])),
        SizedBox(height: 20),
        SizedBox(height: 20),
        Input(
          onPressed: _reloadSolution,
          scrollController: _scrollController,
        )
      ],
    ));
  }

  void _reloadSolution(BuildContext context, String text) async {
    Equation e;
    e = Equation(text);
    e.balance();
    setState(() {
      widget.equation = e;
      widget.solution = e.toString();
      widget.type = typeToString[e.type];
    });
  }

  void _pushExplanation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Explanation(equation: widget.equation)),
    );
  }
}
