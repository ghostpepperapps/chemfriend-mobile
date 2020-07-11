import 'package:chemfriend/chemistry/chemistry.dart';
import 'package:flutter/material.dart';

import 'solution.dart';
import 'input.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChemFriend',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'ChemFriend v0.0.0.8'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        appBar: AppBar(title: Text(widget.title)),
        body: ListView(controller: _scrollController, children: <Widget>[
          SizedBox(height: 40),
          Input(
            onPressed: _pushSolution,
            scrollController: _scrollController,
          )
        ]));
  }

  void _pushSolution(BuildContext context, String text) async {
    Equation e;
    e = Equation(text);
    e.balance();
    String solution = e.toString();
    String type = typeToString[e.getType()];
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              Solution(equation: e, solution: solution, type: type)),
    );
  }
}
