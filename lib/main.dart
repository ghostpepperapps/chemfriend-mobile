import 'dart:io';
import 'package:chemfriend/chemistry/chemistry.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/solution.dart';
import 'pages/about.dart';
import 'pages/tutorial.dart';
import 'input.dart';
import 'custom_header.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chemfriend',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Chemfriend'),
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
  File _pickedImage;
  VisionText _visionText;
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
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView(controller: _scrollController, children: <Widget>[
        SizedBox(height: 40),
        Input(
          onPressed: _pushSolution,
          scrollController: _scrollController,
          placeholder: "E.g. C6H12O6(s) + O2(g)",
          buttonSideLength: 115,
        )
      ]),
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

  void _pushSolution(BuildContext context, String inputText) async {
    Equation e;
    if (inputText == '') {
      this._pickedImage =
          await ImagePicker.pickImage(source: ImageSource.camera);
      await _cropImage();
      await _getText();
      e = Equation(_visionText.text);
    } else {
      e = Equation(inputText);
    }
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

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: _pickedImage.path,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Image',
        ));
    this._pickedImage = croppedFile;
  }

  Future _getText() async {
    FirebaseVisionImage fvImage = FirebaseVisionImage.fromFile(_pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    _visionText = await recognizeText.processImage(fvImage);
  }
}
