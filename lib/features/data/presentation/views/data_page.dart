import 'package:chem_tech_gravity_app/core/utils/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/utils/spacing.dart';
import '../../../../core/utils/toast.dart';
import '../../../home/presentation/views/scan_view.dart';
import '../../models/data_struct.dart';
import '../widgets/data_form.dart';
import '../widgets/shimmer_form.dart';

class DataPage extends StatefulWidget {
  final BluetoothDevice device;

  const DataPage({Key? key, required this.device}) : super(key: key);

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  BluetoothCharacteristic? rxChar;
  BluetoothCharacteristic? txChar;
  bool _dataReceived = false;
  int _animationIndex = 0;
  BluetoothConnectionState _currentConnectionState = BluetoothConnectionState.disconnected;

  DataStruct receivedData =
  DataStruct(flag1: 0, flag2: 0, value1: 0, value2: 0, value3: 0);

  final flag1Controller = TextEditingController();
  final flag2Controller = TextEditingController();
  final value1Controller = TextEditingController();
  final value2Controller = TextEditingController();
  final value3Controller = TextEditingController();

  bool _adapterDialogShown = false;
  bool _disconnectionDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToConnectionStates();
    });
    connectToDevice();
  }

  void _listenToConnectionStates() {
    FlutterBluePlus.adapterState.listen((adapterState) {
      debugPrint('🔌 Bluetooth adapter state: $adapterState');

      if (!mounted) return;

      if (adapterState == BluetoothAdapterState.off) {
        _adapterDialogShown = true;
        _disconnectionDialogShown = true;

        if (!_adapterDialogShown) {
          _adapterDialogShown = true;
          _showConnectionDialog(
            title: 'Bluetooth is Off',
            message: 'Please enable Bluetooth to continue.',
          );
        }
      }
      else if (adapterState == BluetoothAdapterState.on) {
        _adapterDialogShown = false;
        _disconnectionDialogShown = false;
      }
    });

    widget.device.connectionState.listen((deviceState) async {
      debugPrint("📴 Device connection state: $deviceState");

      if (!mounted) return;

      setState(() {
        _currentConnectionState = deviceState;
      });

      if (FlutterBluePlus.adapterStateNow == BluetoothAdapterState.off) {
        return;
      }

      if (deviceState == BluetoothConnectionState.connected) {
        _disconnectionDialogShown = false;
      }
      else if (deviceState == BluetoothConnectionState.disconnected &&
          !_disconnectionDialogShown) {
        _disconnectionDialogShown = true;

        await Future.delayed(const Duration(milliseconds: 300));

        if (!mounted) return;

        _showConnectionDialog(
          title: 'Device Disconnected',
          message: 'The Bluetooth device has been disconnected.',
        );
      }
    });
  }
  void _showConnectionDialog({required String title, required String message}) {
    showAlertDialog(
      context: context,
      title: title,
      message: message,
      onConfirm: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ScanView()),
              (route) => false,
        );
      },
    );
  }
  Future<void> connectToDevice() async {
    try {
      await widget.device.connect(autoConnect: false, timeout: const Duration(seconds: 15));

      if (!mounted) return;

      await Future.delayed(const Duration(seconds: 2));
      List<BluetoothService> services = await widget.device.discoverServices();

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) rxChar = characteristic;
          if (characteristic.properties.notify) {
            txChar = characteristic;
            await txChar!.setNotifyValue(true);
            txChar!.lastValueStream.listen((value) {
              debugPrint("Raw value received: $value");
              if (value.length == 16) {
                final data = DataStruct.fromBytes(value);
                debugPrint("Parsed: flag1=${data.flag1}, flag2=${data.flag2}");

                setState(() {
                  receivedData = data;
                  _dataReceived = true;
                  flag1Controller.text = data.flag1.toString();
                  flag2Controller.text = data.flag2.toString();
                  value1Controller.text = data.value1.toString();
                  value2Controller.text = data.value2.toString();
                  value3Controller.text =
                      (data.value3 * 0.001).toStringAsFixed(2);
                });
              } else {
                debugPrint("Received data with unexpected length: ${value.length}");
              }
            });
          }
        }
      }

      if (rxChar != null) {
        await rxChar!.write(
          DataStruct(flag1: 0, flag2: 0, value1: 0, value2: 0, value3: 0).toBytes(),
          withoutResponse: false,
        );
        debugPrint("Sent trigger data to request initial device response.");
      }
    } catch (e) {
      debugPrint('Connection error: $e');
      if (mounted && !_disconnectionDialogShown) {
        _showDisconnectionDialog();
      }
    }
  }
  void _showDisconnectionDialog() {
    _disconnectionDialogShown = true;
    showAlertDialog(
      context: context,
      title: 'Connection Failed',
      message: 'Could not connect to the device.',
      onConfirm: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ScanView()),
              (route) => false,
        );
      },
    );
  }
  Future<void> sendData() async {
    if (rxChar == null) {
      showToast(message: "No writable characteristic found");
      return;
    }

    try {
      final dataStruct = DataStruct(
        flag1: int.parse(flag1Controller.text),
        flag2: int.parse(flag2Controller.text),
        value1: int.parse(value1Controller.text),
        value2: int.parse(value2Controller.text),
        value3: (double.parse(value3Controller.text) * 1000).round(),
      );
      await rxChar!.write(dataStruct.toBytes(), withoutResponse: false);
    } catch (e) {
      showToast(message: "Failed to send: $e");
    }
  }

  Future<void> sendFlag2(int flag2Value) async {
    if (rxChar == null) return;

    try {
      final updatedStruct = DataStruct(
        flag1: receivedData.flag1,
        flag2: flag2Value,
        value1: receivedData.value1,
        value2: receivedData.value2,
        value3: receivedData.value3,
      );
      await rxChar!.write(updatedStruct.toBytes(), withoutResponse: false);
    } catch (e) {
      debugPrint("Error sending flag2: $e");
    }
  }

  void _handleModeAction() async {
    final f1 = receivedData.flag1;
    final f2 = receivedData.flag2;

    if (f1 == 1 || f1 == 3) {
      final nextFlag2 = f2 == 1 ? 2 : 1;
      await sendFlag2(nextFlag2);
      if (nextFlag2 == 1) {
        setState(() {
          receivedData =
              receivedData.copyWith(value1: 0, value2: 0, value3: 0);
          value1Controller.text = '0';
          value2Controller.text = '0';
          value3Controller.text = '0.00';
        });
      }
    } else if (f1 == 2 || f1 == 4) {
      await sendFlag2(2);
      await Future.delayed(const Duration(milliseconds: 200));
      await sendFlag2(1);
      setState(() {
        receivedData =
            receivedData.copyWith(value1: 0, value2: 0, value3: 0);
        value1Controller.text = '0';
        value2Controller.text = '0';
        value3Controller.text = '0.00';
      });
    }
  }

  void _changeMode(int mode) async {
    flag1Controller.text = mode.toString();
    flag2Controller.text = '2';
    await sendData();
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

  @override
  void dispose() {
    widget.device.disconnect();
    flag1Controller.dispose();
    flag2Controller.dispose();
    value1Controller.dispose();
    value2Controller.dispose();
    value3Controller.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final deviceName = widget.device.name.isNotEmpty
        ? widget.device.name
        : widget.device.id.toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(deviceName),
      ),
      drawer: Drawer(
        width: 300,
        backgroundColor: kPrimaryColor,
        child: Column(
          children: [
            DrawerHeader(
              child: Center(
                child:
                Image.asset(AssetsData.splashImage, height: 300, width: 300),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildCardDrawerItem(
                      Icons.play_circle_fill, "Run Time Mode", 1),
                  _buildCardDrawerItem(Icons.plus_one, "Count Mode", 2),
                  _buildCardDrawerItem(Icons.wb_shade, "Shade Mode", 3),
                  _buildCardDrawerItem(Icons.sync, "Pendulum Mode", 4),
                ],
              ),
            ),
            const Divider(color: Colors.white30),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('Powered By © 2025 ChemTech',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: _currentConnectionState == BluetoothConnectionState.connected
                ? Colors.green.shade50
                : Colors.red.shade50,
            child: ListTile(
              leading: Icon(
                _currentConnectionState == BluetoothConnectionState.connected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                color: _currentConnectionState == BluetoothConnectionState.connected
                    ? Colors.green
                    : Colors.red,
                size: 28,
              ),
              title: Text(
                  _currentConnectionState == BluetoothConnectionState.connected
                      ? "Connected to: $deviceName"
                      : "Disconnected from: $deviceName",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  _currentConnectionState == BluetoothConnectionState.connected
                      ? "Device is ready for commands"
                      : "Device is not connected"),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            switchInCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              final index = _animationIndex % 3;
              if (index == 0) {
                return SlideTransition(
                  position: Tween<Offset>(
                      begin: const Offset(-1.0, 0.0), end: Offset.zero)
                      .animate(animation),
                  child: child,
                );
              } else if (index == 1) {
                return SlideTransition(
                  position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0), end: Offset.zero)
                      .animate(animation),
                  child: child,
                );
              } else {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              }
            },
            child: _dataReceived && _currentConnectionState == BluetoothConnectionState.connected
                ? DataForm(
              key: ValueKey("data-${receivedData.flag1}"),
              flag1: flag1Controller,
              flag2: flag2Controller,
              v1: value1Controller,
              v2: value2Controller,
              v3: value3Controller,
              isEditingDisabled: receivedData.flag1 == 1,
              onSendPressed: sendData,
            )
                : const DataFormShimmer(key: ValueKey("shimmer")),
          ),
          Space.h20,
          if (_dataReceived && _currentConnectionState == BluetoothConnectionState.connected)
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    backgroundColor: _getModeColor(receivedData.flag1.toString()),
                    foregroundColor: kPrimaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (receivedData.flag1 >= 1 && receivedData.flag1 <= 4)
                      ? _handleModeAction
                      : null,
                  icon: Icon(
                    (receivedData.flag1 == 1 || receivedData.flag1 == 3)
                        ? (receivedData.flag2 == 1 ? Icons.stop : Icons.play_arrow)
                        : Icons.refresh,
                    color: kPrimaryColor,
                  ),
                  label: Text(
                    (receivedData.flag1 == 1 || receivedData.flag1 == 3)
                        ? (receivedData.flag2 == 1 ? "Stop" : "Start")
                        : "Reset",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),

              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardDrawerItem(IconData icon, String title, int mode) {
    return Card(
      color: kSecondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, size: 30, color: Colors.white),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        onTap: () {
          Navigator.pop(context);
          _changeMode(mode);
        },
      ),
    );
  }
}
