import 'package:flutter/material.dart';

class Input extends StatefulWidget {
  Input({Key key, this.onPressed, this.scrollController}) : super(key: key);

  /// This function is called every time the arrow button is pressed.
  final Function onPressed;

  /// This is ths scroll controller for the page of the input.
  final ScrollController scrollController;
  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  final _textController = TextEditingController();
  final _key = GlobalKey();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Enter an equation and press the big red button:', key: _key),
          Center(
            child: TextField(
              controller: _textController,
              textInputAction: TextInputAction.done,
              onTap: _scrollToStart,
              style: TextStyle(
                fontSize: 20.0,
              ),
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
            width: 100,
            height: 100,
            child: FloatingActionButton(
              heroTag: '_onPressed',
              child: Icon(Icons.forward),
              onPressed: () {
                widget.onPressed(context, _textController.text);
                _textController.text = '';
              },
            ),
          ))
        ]);
  }

  /// Returns a button that adds [append] to the end of [_textController]'s text
  /// and has the label [display].
  Widget addButton(String append, String display) {
    return RaisedButton(
        padding: EdgeInsets.all(8.0),
        onPressed: () => _addText(append),
        child: Text(display));
  }

  /// Adds [append] to [_textController]'s text and moves the cursor to the end.
  void _addText(String append) {
    int prevOffset = _textController.selection.baseOffset;
    _textController.text = _textController.text.substring(0, prevOffset) +
        append +
        _textController.text.substring(prevOffset);
    _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: prevOffset + append.length));
  }

  /// Scrolls to the start of the equation input.
  void _scrollToStart() async {
    RenderBox box = _key.currentContext.findRenderObject();
    Offset position = box.localToGlobal(Offset.zero);
    await Future.delayed(const Duration(milliseconds: 500), () {});
    widget.scrollController.animateTo(position.dy - 20,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }
}
