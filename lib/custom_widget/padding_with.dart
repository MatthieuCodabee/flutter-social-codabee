import 'package:flutter/material.dart';

class PaddingWith extends Padding {

  PaddingWith({
    required Widget child,
    double top: 20,
    double bottom: 20,
    double left: 20,
    double right: 20
}) : super(
    child: child,
    padding: EdgeInsets.only(
      top: top,
      bottom: bottom,
      right: right,
      left: left
    )
  );
}