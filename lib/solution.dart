import 'package:flutter/material.dart';
import 'package:chemfriend/chemistry/chemistry.dart';

import 'input.dart';

class Solution extends StatefulWidget {
  Solution({Key key, this.solution, this.type}) : super(key: key);
  String solution;
  String type;
  @override
  _SolutionState createState() => _SolutionState();
}

class _SolutionState extends State<Solution> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
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
          'Type: ${widget.type}',
          style: TextStyle(fontSize: 25.0, fontStyle: FontStyle.italic),
        )),
        SizedBox(height: 20),
        Center(
            child: Text(widget.solution, style: TextStyle(fontSize: 20.0))),
        SizedBox(height: 40),
        Input(
          onPressed: _reloadSolution,
        )
      ],
    ));
  }

  void _reloadSolution(BuildContext context, String text) async {
    Equation e;
    e = Equation(text);
    e.balance();
    setState(() {
      widget.solution = e.toString();
      widget.type = typeToString[e.getType()];
    });
  }
}
