import 'package:chem_tech_gravity_app/core/utils/constants.dart';
import 'package:flutter/material.dart';

class DataForm extends StatelessWidget {
  final TextEditingController flag1;
  final TextEditingController flag2;
  final TextEditingController v1;
  final TextEditingController v2;
  final TextEditingController v3;
  final bool isEditingDisabled;
  final VoidCallback onSendPressed;

  const DataForm({
    super.key,
    required this.flag1,
    required this.flag2,
    required this.v1,
    required this.v2,
    required this.v3,
    required this.isEditingDisabled,
    required this.onSendPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text("Edit Data:", style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        TextField(controller: flag1, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Flag 1")),
        TextField(controller: flag2, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Flag 2")),
        TextField(controller: v1, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Value 1"), enabled: !isEditingDisabled),
        TextField(controller: v2, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Value 2"), enabled: !isEditingDisabled),
        TextField(controller: v3, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Value 3"), enabled: !isEditingDisabled),
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSendPressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: kSecondaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: const Text("Send 16-byte Packet"),
            ),
          ),
        ),
      ],
    );
  }
}
