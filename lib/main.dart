import 'dart:io';
import 'package:chemfriend/chemistry/chemistry.dart';

import 'solution.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

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
	File _pickedImage;
	VisionText _visionText;
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Center(
				child: SizedBox(
					width: 200,
					height: 200,
					child: FloatingActionButton(
						heroTag: '_pushCamera',
						child: SizedBox(
							width: 150,
							height: 150,
							child: Icon(Icons.camera),
						),
						onPressed: () {_pushCamera(context);},
					),
				),
			),
		);
	}

	void _pushCamera(BuildContext context) async {
		this._pickedImage = await ImagePicker.pickImage(source: ImageSource.camera);
		await _cropImage();
		await _getText();

    Equation e;
    try {
      e = Equation(_visionText.text);
    } on Error {
      e = Equation('C6H12O2 + O2');
    }
    e.solve();
    String solution = e.toString();
		Navigator.push(
			context,
			MaterialPageRoute(builder: (context) => Solution(
        pickedImage: this._pickedImage,
        text: _visionText.text,
        solution: solution,
      )),
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
			)
		);
		this._pickedImage = croppedFile;
	}

	Future _getText() async {
		FirebaseVisionImage fvImage = FirebaseVisionImage.fromFile(_pickedImage);
		TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
		_visionText = await recognizeText.processImage(fvImage);
	}

}
