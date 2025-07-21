import 'package:app_settings/app_settings.dart';
import 'package:chem_tech_gravity_app/features/home/presentation/views/widgets/developer_footer.dart';
import 'package:chem_tech_gravity_app/features/home/presentation/views/widgets/device_list.dart';
import 'package:chem_tech_gravity_app/features/home/presentation/views/widgets/scan_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../../../core/utils/constants.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';

class ScanView extends StatefulWidget {
  const ScanView({super.key});

  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView> {
  bool hasScanned = false;
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    initPermissions();
  }

  Future<void> initPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void _startScan(BuildContext context) {
    context.read<ScanCubit>().startScan();
  }

  void _showBluetoothOffDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Bluetooth is Off',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Please enable Bluetooth to scan for devices.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              AppSettings.openAppSettings(type: AppSettingsType.bluetooth);

              Navigator.of(context).pop();
            },
            child: const Text('Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanCubit(),
      child: WillPopScope(
        onWillPop: () async {
          if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > const Duration(seconds: 2)) {
            _lastPressedAt = DateTime.now();
            Fluttertoast.showToast(
              msg: "Press back again to exit",
              backgroundColor: kSecondaryColor,
              textColor: Colors.white,
              gravity: ToastGravity.BOTTOM,
            );
            return false;
          }
          return true;
        },
        child: Scaffold(
          backgroundColor: Colors.grey[200],
          appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: const Text(
              'Bluetooth Devices',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              if (hasScanned)
                IconButton(
                  icon: const Icon(Icons.refresh, color: kSecondaryColor),
                  onPressed: () async {
                    final state = await FlutterBluePlus.adapterState.first;
                    if (state != BluetoothAdapterState.on) {
                      _showBluetoothOffDialog(context);
                    } else {
                      _startScan(context);
                    }
                  },
                ),
            ],
          ),
          body: BlocConsumer<ScanCubit, ScanState>(
            listener: (context, state) {
              if (state is ScanSuccess || state is ScanFailure) {
                setState(() => hasScanned = true);
              }
              if (state is ScanFailure) {
                _showBluetoothOffDialog(context);
              }
            },
            builder: (context, state) {
              if (state is ScanLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: kSecondaryColor),
                );
              } else if (state is ScanSuccess && state.devices.isNotEmpty) {
                return DeviceList(
                  devices: state.devices,
                  isScanning: false,
                  onRefresh: () => _startScan(context),
                );
              } else if (state is ScanSuccess && state.devices.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bluetooth_disabled, size: 80, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text("No devices found", style: TextStyle(fontSize: 18)),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _startScan(context),
                        icon: const Icon(Icons.refresh,color: Colors.white,),
                        label: const Text("Retry",style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSecondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Card(
                    elevation: 8,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    color: Colors.white,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        border: Border.all(color: Color(0xFFB0BEC5)), // Optional subtle border
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Tap below to start scanning",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ScanButton(
                            onTap: () => _startScan(context),
                            isScanning: state is ScanLoading,
                            foundDevices: state is ScanSuccess ? state.devices.length : 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                );

              }
            },
          ),
          bottomNavigationBar: const DeveloperFooter(),
        ),
      ),
    );
  }
}
