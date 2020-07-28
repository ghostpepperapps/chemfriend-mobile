import 'package:chemfriend/chemistry/chemistry.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/solution.dart';
import 'pages/about.dart';
import 'pages/tutorial.dart';
import 'input.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chemfriend',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Chemfriend v0.0.0.8'),
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

  void startup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool opened = prefs.getBool('opened');
    if (opened == null) {
      prefs.setBool('opened', true);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Tutorial()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    startup();
  }

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
      ]),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.redAccent,
              ),
              child: Text(
                'Chemfriend',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
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
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Tutorial()),
        ),
        child: Icon(Icons.info_outline),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _pushSolution(BuildContext context, String text) async {
    Equation e;
    e = Equation(text);
    e.balance();
    String solution = e.toString();
    String type = typeToString[e.type];
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              Solution(equation: e, solution: solution, type: type)),
    );
  }
}
