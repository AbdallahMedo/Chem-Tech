import 'package:flutter/material.dart';

class DataModeDisplay extends StatelessWidget {
  final int flag2;

  const DataModeDisplay({super.key, required this.flag2});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (flag2 == 1)
          const Text('Mode 1 Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        if (flag2 == 2)
          const Text('Mode 2 Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        if (flag2 == 3)
          const Text('Mode 3 Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        if (flag2 == 4)
          const Text('Mode 4 Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
