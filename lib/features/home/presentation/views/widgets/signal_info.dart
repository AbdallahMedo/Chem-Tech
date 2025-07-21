import 'package:flutter/material.dart';

class SignalInfoColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final Color? iconColor;

  const SignalInfoColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: iconColor ?? Colors.deepPurple),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}