import 'package:chem_tech_gravity_app/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../models/data_struct.dart';
import '../widgets/device_app_bar.dart';
import '../widgets/raw_data_display.dart';
import '../widgets/data_form.dart';
import '../widgets/data_mode_display.dart';

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

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  Future<void> connectToDevice() async {
    try {
      await widget.device.connect(autoConnect: false);
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
        if (characteristic.properties.write) {
          rxChar = characteristic;
        }
        if (characteristic.properties.notify) {
          txChar = characteristic;
          await txChar!.setNotifyValue(true);
          txChar!.lastValueStream.listen((value) {
            if (value.length == 16) {
              setState(() {
                receivedData = DataStruct.fromBytes(value);
                flag1Controller.text = receivedData.flag1.toString();
                flag2Controller.text = receivedData.flag2.toString();
                value1Controller.text = receivedData.value1.toString();
                value2Controller.text = receivedData.value2.toString();
                value3Controller.text = receivedData.value3.toString();
              });
            }
          });
        }
      }
    }
  }

  Future<void> sendData() async {
    if (rxChar == null) {
      showToast("No writable characteristic found");
      return;
    }

    final inputs = [
      flag1Controller.text,
      flag2Controller.text,
      value1Controller.text,
      value2Controller.text,
      value3Controller.text,
    ];

    if (inputs.any((e) => e.isEmpty)) {
      showToast("Please fill in all fields");
      return;
    }

    try {
      final dataStruct = DataStruct(
        flag1: int.parse(flag1Controller.text),
        flag2: int.parse(flag2Controller.text),
        value1: int.parse(value1Controller.text),
        value2: int.parse(value2Controller.text),
        value3: int.parse(value3Controller.text),
      );

      final bytes = dataStruct.toBytes();

      debugPrint("Sending: ${bytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join(' ').toUpperCase()}");

      await rxChar!.write(bytes, withoutResponse: false);
      showToast("Data sent successfully!");
    } catch (e) {
      debugPrint("Send failed: $e");
      showToast("Failed to send: $e");
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: kSecondaryColor,
      textColor: Colors.white,
    );
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
    final isEditingDisabled = receivedData.flag2 == 1;

    return Scaffold(
      appBar: buildDeviceAppBar(context, deviceName),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            RawDataDisplay(receivedData: receivedData),
            DataForm(
              flag1: flag1Controller,
              flag2: flag2Controller,
              v1: value1Controller,
              v2: value2Controller,
              v3: value3Controller,
              isEditingDisabled: isEditingDisabled,
              onSendPressed: sendData,
            ),
            DataModeDisplay(flag2: receivedData.flag2),
          ],
        ),
      ),
    );
  }
}
