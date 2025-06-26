import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ScanAnimationScreen extends StatefulWidget {
  const ScanAnimationScreen();

  @override
  State<ScanAnimationScreen> createState() => _ScanAnimationScreenState();
}

class _ScanAnimationScreenState extends State<ScanAnimationScreen>
    with SingleTickerProviderStateMixin {
  List<ScanResult> devices = [];
  bool scanComplete = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _startScan();
  }

  @override
  void dispose() {
    _animationController.dispose();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    devices.clear();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 3));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() => devices = results);
    });

    Timer(const Duration(seconds: 3), () async {
      FlutterBluePlus.stopScan();
      setState(() => scanComplete = true);
      _animationController.forward();

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.pop(context, devices);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff226AFC),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple background
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                ),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),

                // Icon in center
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scanComplete ? Colors.green : Colors.blueAccent,
                    ),
                    child: Icon(
                      scanComplete ? Icons.check : Icons.bluetooth,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Column(
            children: [
              Text(
                scanComplete
                    ? 'Done! Found ${devices.length} devices'
                    : 'Scanning for Devices...',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 12),
              if (!scanComplete)
                Text(
                  'Devices: ${devices.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
            ],
          ),
        ],
      ),
    );
  }
}