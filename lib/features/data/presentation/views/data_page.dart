import 'package:chem_tech_gravity_app/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';  // Import Toast package
import '../../../home/data/presentation/cubit/scan_cubit.dart';
import '../../../home/data/presentation/cubit/scan_state.dart';
import '../../models/data_struct.dart';

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

  late final ScanCubit scanCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scanCubit = context.read<ScanCubit>();
  }

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  Future<void> connectToDevice() async {
    try {
      await widget.device.connect(autoConnect: false);
    } catch (e) {
      if (e.toString().contains('already connected')) {
        // ignore
      } else {
        debugPrint('Connection error: $e');
        return;
      }
    }

    await Future.delayed(const Duration(seconds: 2));

    String deviceName = widget.device.name.isNotEmpty
        ? widget.device.name
        : "Unknown Device";

    debugPrint("Connected to device: $deviceName");

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
      Fluttertoast.showToast(
        msg: "No writable characteristic found",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: kSecondaryColor, // Custom color
        textColor: Colors.white,
      );
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
      Fluttertoast.showToast(
        msg: "Please fill in all fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: kSecondaryColor, // Custom color
        textColor: Colors.white,
      );
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

      Fluttertoast.showToast(
        msg: "Data sent successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: kSecondaryColor, // Custom color
        textColor: Colors.white,
      );
    } catch (e) {
      debugPrint("Send failed: $e");
      Fluttertoast.showToast(
        msg: "Failed to send: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: kSecondaryColor, // Custom color
        textColor: Colors.white,
      );
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
  Widget build(BuildContext context) {
    bool isEditingDisabled = receivedData.flag2 == 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name.isNotEmpty
            ? widget.device.name
            : widget.device.id.toString()),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: [
          BlocBuilder<ScanCubit, ScanState>(builder: (context, state) {
            if (state is ScanLoading) {
              return const CircularProgressIndicator();
            } else if (state is ScanSuccess) {
              if (state.devices.isEmpty) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<ScanCubit>().startScan();
                  },
                );
              }
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text("Raw 16-byte Data:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              receivedData.toBytes().map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ').toUpperCase(),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            const Text("Edit Data:", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextField(controller: flag1Controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Flag 1")),
            TextField(controller: flag2Controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Flag 2")),
            TextField(
              controller: value1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Value 1"),
              enabled: !isEditingDisabled,
            ),
            TextField(
              controller: value2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Value 2"),
              enabled: !isEditingDisabled,
            ),
            TextField(
              controller: value3Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Value 3"),
              enabled: !isEditingDisabled,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendData,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: kSecondaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: const Text("Send 16-byte Packet"),
            ),
            if (receivedData.flag2 == 1)
              const Text('Mode 1 Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            if (receivedData.flag2 == 2)
              const Text('Mode 2 Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            if (receivedData.flag2 == 3)
              const Text('Mode 3 Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            if (receivedData.flag2 == 4)
              const Text('Mode 4 Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
