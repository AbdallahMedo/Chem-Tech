import 'package:flutter/cupertino.dart';

class Space {
  static const Widget h50 = SizedBox(height: 50);
  static const Widget h10 = SizedBox(height: 10);
  static const Widget h20 = SizedBox(height: 20);
  static const Widget h16 = SizedBox(height: 16);
  static const Widget h12 = SizedBox(height: 12);
  static const Widget h30 = SizedBox(height: 30);
  static const Widget h8 = SizedBox(height: 8);
  static const Widget w8 = SizedBox(width: 8);
  static const Widget w12 = SizedBox(width: 12);
  static const Widget w10 = SizedBox(width: 10);
  static const Widget w20 = SizedBox(width: 20);

  static Widget h(double height) => SizedBox(height: height);
  static Widget w(double width) => SizedBox(width: width);
}
