import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  Input({Key key, this.onPressed}) : super(key: key);

  /// This function is called every time the arrow button is pressed.
  final Function onPressed;
  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Enter an equation and press the big button:'),
          Center(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.done,
            ),
          ),
          SizedBox(height: 25),
          Center(
              child: ButtonBar(
                  alignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                addButton(' + ', '+'),
                addButton(' => ', '→'),
                addButton('(', '('),
                addButton(')', ')'),
              ])),
          Center(
              child: ButtonBar(
            alignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              addButton('(s)', "(s)"),
              addButton('(l)', "(l)"),
              addButton('(g)', "(g)"),
              addButton('(aq)', "(aq)"),
            ],
          )),
          SizedBox(height: 25),
          Center(
              child: SizedBox(
            width: 150,
            height: 150,
            child: FloatingActionButton(
              heroTag: '_onPressed',
              child: Icon(Icons.forward),
              onPressed: () {
                widget.onPressed(context, _controller.text);
              },
            ),
          ))
        ]);
  }

  /// Returns a button that adds [append] to the end of [_controller]'s text
  /// and has the label [display].
  Widget addButton(String append, String display) {
    return RaisedButton(
        padding: EdgeInsets.all(8.0),
        onPressed: () => _addText(append),
        child: Text(display));
  }

  /// Adds [append] to [_controller]'s text and moves the cursor to the end.
  void _addText(String append) {
    int prevOffset = _controller.selection.baseOffset;
    _controller.text = _controller.text.substring(0, prevOffset) +
        append +
        _controller.text.substring(prevOffset);
    _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: prevOffset + append.length));
  }
}
