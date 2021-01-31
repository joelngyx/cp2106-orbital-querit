import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hexcolor/hexcolor.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white70,
  filled: true,
  enabledBorder: OutlineInputBorder(
    // only applied when this field is not in focus
    borderSide: BorderSide(color: Colors.grey, width: 2),
  ),
  focusedBorder: OutlineInputBorder(
    // applied when field is in focus)
    borderSide: BorderSide(color: Colors.deepPurple, width: 2),
  ),
);

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: SpinKitChasingDots(
          color: Hexcolor('#A593B4'),
          size: 50.0,
        ),
      ),
    );
  }
}
