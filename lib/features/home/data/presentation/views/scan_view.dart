import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' as getx;
import '../../../../../core/utils/constants.dart';
import '../../../../data/presentation/views/data_page.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';

class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  bool hasScanned = false; // Track if user scanned at least once
  DateTime? _lastPressedAt; // To track back press

  // Start scanning method
  void _startScan(BuildContext context) {
    context.read<ScanCubit>().startScan();
  }

  // Show dialog when Bluetooth is off
  void _showBluetoothOffDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: const Text('Bluetooth must be turned on to scan for devices.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScanCubit(),
      child: WillPopScope(
        onWillPop: () async {
          // Handle back button press
          if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > Duration(seconds: 2)) {
            _lastPressedAt = DateTime.now();
            // Show "Press back again to exit" Toast
            Fluttertoast.showToast(
              msg: "Press back again to exit",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: kSecondaryColor,
              textColor: Colors.white,
            );
            return false; // Don't exit yet
          }
          return true; // Exit the app
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Bluetooth Devices'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            actions: [
              if (hasScanned)
                IconButton(
                  onPressed: () {
                    _startScan(context); // Start scanning again when refresh is pressed
                  },
                  icon: const Icon(Icons.refresh, color: kSecondaryColor),
                ),
            ],
          ),
          body: BlocConsumer<ScanCubit, ScanState>(
            listener: (context, state) {
              // Update scanned state based on the result
              if (state is ScanSuccess || state is ScanFailure) {
                setState(() {
                  hasScanned = true; // User has scanned at least once
                });
              }

              // Show Bluetooth off dialog if scanning fails
              if (state is ScanFailure) {
                _showBluetoothOffDialog(context);
              }
            },
            builder: (context, state) {
              // Show loading state
              if (state is ScanLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: kSecondaryColor),
                );
              }
              // Show success state and list of devices
              else if (state is ScanSuccess) {
                if (state.devices.isEmpty) {
                  return const Center(child: Text("No devices found"));
                }
                return ListView.builder(
                  itemCount: state.devices.length,
                  itemBuilder: (context, index) {
                    final device = state.devices[index].device;
                    return ListTile(
                      leading: const Icon(Icons.bluetooth, color: kSecondaryColor),
                      title: Text(device.name.isEmpty ? "Unknown" : device.name),
                      subtitle: Text(device.id.id),
                      onTap: () {
                        getx.Get.to(() => DataPage(device: device)); // Navigate to DataPage
                      },
                    );
                  },
                );
              }
              // Show scan button if no scan has been initiated
              else {
                return Center(
                  child: GestureDetector(
                    onTap: () {
                      _startScan(context); // Start scanning
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kSecondaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Scan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          // Footer container with text and logo
          bottomNavigationBar: Container(
            color: Colors.grey[400], // Grey background
            padding: const EdgeInsets.all(8.0),
            child:const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text
                 Text(
                  'Developed by Chem-Tech programming team',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
