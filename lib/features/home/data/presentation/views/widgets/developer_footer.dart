import 'package:flutter/material.dart';

class DeveloperFooter extends StatelessWidget {
  const DeveloperFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[400],
      padding: const EdgeInsets.all(8.0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Developed by Chem-Tech programming team',
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
