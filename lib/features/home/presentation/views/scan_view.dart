import 'package:chem_tech_gravity_app/features/home/presentation/views/widgets/developer_footer.dart';
import 'package:chem_tech_gravity_app/features/home/presentation/views/widgets/device_list.dart';
import 'package:chem_tech_gravity_app/features/home/presentation/views/widgets/scan_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/utils/toast.dart';
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
    showAlertDialog(
      context: context,
      title: 'Warning',
      message: 'Bluetooth must be turned on to scan for devices.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScanCubit(),
      child: WillPopScope(
        onWillPop: () async {
          final now = DateTime.now();
          if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
            _lastPressedAt = now;
            showToast(message: "Press back again to exit");
            return false;
          }
          return true; // Allow the pop action (exit app)
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('Bluetooth Devices'),
            centerTitle: true,
            backgroundColor: Colors.white,
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
                return const Center(child: CircularProgressIndicator(color: kSecondaryColor));
              } else if (state is ScanSuccess && state.devices.isNotEmpty) {
                return DeviceList(devices: state.devices);
              } else if (state is ScanSuccess && state.devices.isEmpty) {
                return const Center(child: Text("No devices found"));
              } else {
                return ScanButton(onTap: () => _startScan(context));
              }
            },
          ),
          bottomNavigationBar: const DeveloperFooter(),
        ),
      ),
    );
  }
}
