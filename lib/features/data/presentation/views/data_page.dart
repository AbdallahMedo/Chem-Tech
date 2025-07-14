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

class DataPage extends StatefulWidget {
  final BluetoothDevice device;

  const DataPage({Key? key, required this.device}) : super(key: key);

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  BluetoothCharacteristic? rxChar;
  BluetoothCharacteristic? txChar;

  DataStruct receivedData = DataStruct(flag1: 0, flag2: 0, value1: 0, value2: 0, value3: 0);
  final flag1Controller = TextEditingController();
  final flag2Controller = TextEditingController();
  final value1Controller = TextEditingController();
  final value2Controller = TextEditingController();
  final value3Controller = TextEditingController();

  bool isReceiving = false;

  BluetoothDevice? currentConnectedDevice;

  @override
  void initState() {
    super.initState();
    _listenToBluetoothAdapterState();
    connectToDevice();
    _listenForDisconnection();
  }

  void _listenToBluetoothAdapterState() {
    FlutterBluePlus.adapterState.listen((state) {
      if (state == BluetoothAdapterState.off) {
        showAlertDialog(
          context: context,
          title: 'Bluetooth is Off',
          message: 'Please enable Bluetooth to continue using the app.',
          onConfirm: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ScanView()));
          },
        );
      }
    });
  }

  Future<bool> isAlreadyConnected(BluetoothDevice device) async {
    final state = await device.state.first;
    return state == BluetoothDeviceState.connected;
  }

  Future<void> connectToDeviceIfNotConnected(BuildContext context, BluetoothDevice newDevice) async {
    final bool alreadyConnected = currentConnectedDevice != null && await isAlreadyConnected(currentConnectedDevice!);
    if (alreadyConnected && currentConnectedDevice!.id != newDevice.id) {
      showAlertDialog(
        context: context,
        title: 'Already Connected',
        message: 'You are already connected to another device. Please disconnect it before connecting to a new one.',
        onConfirm: () {
          Navigator.of(context).pop();
        },
      );
    } else {
      try {
        await newDevice.connect(autoConnect: false);
        setState(() {
          currentConnectedDevice = newDevice;
        });
        showToast(message: "Connected to ${newDevice.name}");
      } catch (e) {
        debugPrint("Failed to connect: $e");
        showToast(message: "Connection failed.");
      }
    }
  }

  Future<void> connectToDevice() async {
    try {
      await widget.device.connect(autoConnect: false);
      setState(() {
        currentConnectedDevice = widget.device;
      });
    } catch (e) {
      if (!e.toString().contains('already connected')) {
        debugPrint('Connection error: $e');
        return;
      }
    }

    await Future.delayed(const Duration(seconds: 2));
    List<BluetoothService> services = await widget.device.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write) rxChar = characteristic;
        if (characteristic.properties.notify) {
          txChar = characteristic;
          await txChar!.setNotifyValue(true);
          txChar!.lastValueStream.listen((value) async {
            if (value.length == 16) {
              final data = DataStruct.fromBytes(value);
              setState(() {
                receivedData = data;
                flag1Controller.text = data.flag1.toString();
                flag2Controller.text = data.flag2.toString();
                value1Controller.text = data.value1.toString();
                value2Controller.text = data.value2.toString();
                value3Controller.text = (data.value3 * 0.001).toStringAsFixed(2);
              });

              if (!isReceiving && data.flag1 >= 1 && data.flag1 <= 4) {
                isReceiving = true;
                debugPrint("Data reception started for mode ${data.flag1}.");
                if ((data.flag1 == 1 || data.flag1 == 3) && data.flag2 == 1) {
                  debugPrint("Device is already in Start Mode — live mode active.");
                }
              }
            }
          });
        }
      }
    }

    /// 🟢 Send first mode automatically instead of showing dialog
    final setup = DataStruct(flag1: 1, flag2: 2, value1: 0, value2: 0, value3: 0);
    await rxChar?.write(setup.toBytes(), withoutResponse: false);
    await Future.delayed(const Duration(milliseconds: 200));
    await rxChar?.write(setup.toBytes(), withoutResponse: false);
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
      final bytes = dataStruct.toBytes();
      await rxChar!.write(bytes, withoutResponse: false);
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
      debugPrint("Sent flag2 = $flag2Value");
    } catch (e) {
      debugPrint("Error sending flag2: $e");
    }
  }

  void handleModeAction() async {
    final f1 = receivedData.flag1;
    final f2 = receivedData.flag2;

    if (f1 == 1 || f1 == 3) {
      final nextFlag2 = f2 == 1 ? 2 : 1;
      await sendFlag2(nextFlag2);
      if (nextFlag2 == 1) {
        setState(() {
          receivedData = receivedData.copyWith(value1: 0, value2: 0, value3: 0);
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
        receivedData = receivedData.copyWith(value1: 0, value2: 0, value3: 0);
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

  void _listenForDisconnection() {
    widget.device.state.listen((state) {
      if (state == BluetoothDeviceState.disconnected) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showToast(message: 'The Bluetooth device has been disconnected. Please try again.');
        });
      }
    });
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
  Widget build(BuildContext context) {
    final deviceName = widget.device.name.isNotEmpty ? widget.device.name : widget.device.id.toString();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(deviceName),
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu),
            );
          },
        ),
      ),
      drawer: Drawer(
        width: 300,
        backgroundColor: kPrimaryColor,
        child: Column(
          children: [
            DrawerHeader(
              child: Center(
                child: Image.asset(AssetsData.splashImage, height: 300, width: 300)
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildCardDrawerItem(Icons.play_circle_fill, "Run Time Mode", 1),
                  _buildCardDrawerItem(Icons.plus_one, "Count Mode", 2),
                  _buildCardDrawerItem(Icons.wb_shade, "Shade Mode", 3),
                  _buildCardDrawerItem(Icons.sync, "Pendulum Mode", 4),
                ],
              ),
            ),
            const Divider(color: Colors.white30),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Powered By © 2025 ChemTech',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),

      body: OrientationBuilder(
        builder: (context, orientation) {
          return LayoutBuilder(
            builder: (context, constraints) {
              bool isLandscape = orientation == Orientation.landscape;

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: isLandscape
                        ? Row(
                      children: [
                        Expanded(
                          child: DataForm(
                            flag1: flag1Controller,
                            flag2: flag2Controller,
                            v1: value1Controller,
                            v2: value2Controller,
                            v3: value3Controller,
                            isEditingDisabled: receivedData.flag1 == 1,
                            onSendPressed: sendData,
                          ),
                        ),
                        Space.w20,
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: (receivedData.flag1 >= 1 && receivedData.flag1 <= 4) ? handleModeAction : null,
                              icon: Icon(
                                (receivedData.flag1 == 1 || receivedData.flag1 == 3)
                                    ? (receivedData.flag2 == 1 ? Icons.stop : Icons.play_arrow)
                                    : Icons.refresh,
                                color: Colors.white,
                              ),
                              label: Text(
                                (receivedData.flag1 == 1 || receivedData.flag1 == 3)
                                    ? (receivedData.flag2 == 1 ? "Stop" : "Start")
                                    : "Reset",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kSecondaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                        : ListView(
                      children: [
                        DataForm(
                          flag1: flag1Controller,
                          flag2: flag2Controller,
                          v1: value1Controller,
                          v2: value2Controller,
                          v3: value3Controller,
                          isEditingDisabled: receivedData.flag1 == 1,
                          onSendPressed: sendData,
                        ),
                        Space.h20,
                        ElevatedButton.icon(
                          onPressed: (receivedData.flag1 >= 1 && receivedData.flag1 <= 4) ? handleModeAction : null,
                          icon: Icon(
                            (receivedData.flag1 == 1 || receivedData.flag1 == 3)
                                ? (receivedData.flag2 == 1 ? Icons.stop : Icons.play_arrow)
                                : Icons.refresh,
                            color: Colors.white,
                          ),
                          label: Text(
                            (receivedData.flag1 == 1 || receivedData.flag1 == 3)
                                ? (receivedData.flag2 == 1 ? "Stop" : "Start")
                                : "Reset",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSecondaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCardDrawerItem(IconData icon, String title, int mode) {
    return Card(
      color: kSecondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, size: 30, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          _changeMode(mode);
        },
      ),
    );
  }

}
