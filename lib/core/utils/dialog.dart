// core/utils/dialog_utils.dart
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Shows a generic alert dialog
Future<void> showAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'OK',
  VoidCallback? onConfirm,
}) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onConfirm != null) onConfirm();
          },
          child: Text(confirmText),
        ),
      ],
    ),
  );
}


