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
      home: MyHomePage(title: 'ChemFriend v0.1'),
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
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('ChemFriend v.0.0.0.8')),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[Input(onPressed: _pushSolution)]));
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
          builder: (context) => Solution(solution: solution, type: type)),
    );
  }
}
