import 'package:animated_digit/animated_digit.dart';
import 'package:chem_tech_gravity_app/core/utils/constants.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/spacing.dart';

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

  String _getModeName(String flag1) {
    switch (flag1) {
      case '1':
        return 'Run Time Mode';
      case '2':
        return 'Count Mode';
      case '3':
        return 'Shade Mode';
      case '4':
        return 'Pendulum Mode';
      default:
        return 'Unknown Mode';
    }
  }

  Widget _buildItem(String label, String value) {
    final doubleVal = double.tryParse(value) ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        AnimatedDigitWidget(
          value: doubleVal ?? 0.0,
          textStyle: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          fractionDigits: ((doubleVal ?? 0.0) % 1 == 0) ? 0 : 2,
        ),


      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = flag1.text;
    final modeName = _getModeName(mode);
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Space.h20,
          Text(
            "Mode Selected: $modeName",
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          Space.h20,
          Card(

            color: kSecondaryColor,
            elevation: 6,
            margin: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: (mode == '4')
                  ? _buildItem("Oscillate", v1.text)
                  : (mode == '2')
                  ? _buildItem("Counter", v1.text)
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItem("T1", v1.text),
                  Space.h20,
                  _buildItem("T2", v2.text),
                  Space.h20,
                  _buildItem("∆T", v3.text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
