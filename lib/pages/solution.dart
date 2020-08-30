import 'package:flutter/material.dart';
import 'package:chemfriend/chemistry/chemistry.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../input.dart';
import '../custom_header.dart';
import 'explanation.dart';
import 'about.dart';
import 'tutorial.dart';

class Solution extends StatefulWidget {
  Solution({Key key, this.equation, this.solution, this.type})
      : super(key: key);
  final Equation equation;
  final String solution;
  final String type;
  @override
  _SolutionState createState() => _SolutionState();
}

class _SolutionState extends State<Solution> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  Equation equation;
  String solution;
  String type;

  @override
  void initState() {
    super.initState();
    equation = widget.equation;
    solution = widget.solution;
    type = widget.type;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chemfriend',
          style: TextStyle(fontFamily: 'open_sans'),
        ),
        centerTitle: true,
      ),
      body: ListView(
        controller: _scrollController,
        children: <Widget>[
          SizedBox(height: 20),
          Center(
              child: Text(
            'Type: $type',
            style: TextStyle(fontSize: 25.0, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          )),
          SizedBox(height: 20),
          Center(
              child: Row(children: <Widget>[
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(12.0),
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
                flex: 6,
                child: Padding(
                    padding: EdgeInsets.all(3.0),
                    child: Text(solution,
                        style: TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center))),
          ])),
          SizedBox(height: 20),
          SizedBox(height: 20),
          Input(
            onPressed: _reloadSolution,
            scrollController: _scrollController,
            placeholder: "",
            buttonSideLength: 88,
          )
        ],
      ),
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          customHeader(),
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
    );
  }

  void _reloadSolution(BuildContext context, String text) async {
    Equation e;
    try {
      e = Equation(text);
      e.balance();
      setState(() {
        equation = e;
        solution = e.toString();
        type = typeToString[e.type];
      });
    } catch (err) {
      Fluttertoast.showToast(
          msg: "Sorry, I can't solve that!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.teal[900],
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void _pushExplanation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Explanation(equation: equation)),
    );
  }
}
