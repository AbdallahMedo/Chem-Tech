import 'package:chem_tech_gravity_app/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast({
  required String message,
  ToastGravity gravity = ToastGravity.BOTTOM,
  Color backgroundColor = kSecondaryColor,
  Color textColor = Colors.white,
}) {
  Fluttertoast.showToast(
    msg: message,
    gravity: gravity,
    backgroundColor: backgroundColor,
    textColor: textColor,
  );
}