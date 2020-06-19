import 'package:chemfriend/chemistry/chemistry.dart';

import 'solution.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChemFriend',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Center(
              child: SizedBox(
            width: 200,
            height: 200,
            child: FloatingActionButton(
              heroTag: '_pushSolution',
              child: SizedBox(
                width: 150,
                height: 150,
                child: Icon(Icons.camera),
              ),
              onPressed: () {
                _pushSolution(context, controller.text);
              },
            ),
          )),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.done,
          ),
        ]));
  }

  void _pushSolution(BuildContext context, String text) async {
    Equation e;
    e = Equation(text);
    /* try {
      e = Equation(text);
    } on Error {
      e = Equation('C6H12O2(s) + O2(g)');
    } */
    e.balance();
    String solution = e.toString();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Solution(
                solution: solution,
              )),
    );
  }
}
