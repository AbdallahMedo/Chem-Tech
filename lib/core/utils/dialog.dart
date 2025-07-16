import 'package:flutter/material.dart';

/// Shows a generic alert dialog
final List<Widget>buttons=[];
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


