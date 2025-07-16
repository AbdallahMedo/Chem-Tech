import 'package:animated_digit/animated_digit.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

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

  IconData _getModeIcon(String flag1) {
    switch (flag1) {
      case '1':
        return Icons.play_circle_fill;
      case '2':
        return Icons.plus_one;
      case '3':
        return Icons.wb_shade;
      case '4':
        return Icons.sync;
      default:
        return Icons.help_outline;
    }
  }

  Color _getModeColor(String flag1) {
    switch (flag1) {
      case '1':
        return Colors.green;
      case '2':
        return Colors.blue;
      case '3':
        return Colors.orange;
      case '4':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildItem(String label, String value) {
    final doubleVal = double.tryParse(value) ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        AnimatedDigitWidget(
          value: doubleVal,
          textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          duration: const Duration(milliseconds: 500),
          fractionDigits: doubleVal % 1 == 0 ? 0 : 2,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = flag1.text;
    final modeName = _getModeName(mode);
    final modeIcon = _getModeIcon(mode);
    final modeColor = _getModeColor(mode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.blueGrey.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getModeColor(mode),
                  radius: 24,
                  child: Icon(modeIcon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      children: [
                        const TextSpan(
                          text: 'Mode Selected: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: modeName,
                          style: TextStyle(color: modeColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          color: modeColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
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
                const SizedBox(height: 16),
                _buildItem("T2", v2.text),
                const SizedBox(height: 16),
                _buildItem("ΔT", v3.text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
