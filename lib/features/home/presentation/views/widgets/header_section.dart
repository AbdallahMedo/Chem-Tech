import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back to',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
          const Text(
            'Photo Gate',
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.withOpacity(0.2),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tap Find Devices to start scanning for nearby Bluetooth devices',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
