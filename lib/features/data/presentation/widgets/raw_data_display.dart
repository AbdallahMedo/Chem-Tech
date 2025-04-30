import 'package:flutter/material.dart';
import '../../models/data_struct.dart';

class RawDataDisplay extends StatelessWidget {
  final DataStruct receivedData;

  const RawDataDisplay({super.key, required this.receivedData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Raw 16-byte Data:", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text(
          receivedData
              .toBytes()
              .map((b) => b.toRadixString(16).padLeft(2, '0'))
              .join(' ')
              .toUpperCase(),
          style: const TextStyle(fontFamily: 'monospace'),
        ),
      ],
    );
  }
}
