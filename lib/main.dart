import 'package:flutter/material.dart';
import 'camera.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FloatingActionButton(
          heroTag: '_pushCamera',
          child: Icon(Icons.camera),
          onPressed: () {_pushCamera(context);},
        ),
      ),
    );
  }
  void _pushCamera(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Camera()),
    );
  }
}
