import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart' as getx;
import '../../../../../../core/utils/constants.dart';
import '../../../../../data/presentation/views/data_page.dart';

class DeviceList extends StatelessWidget {
  final List<ScanResult> devices;

  const DeviceList({super.key, required this.devices});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index].device;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
            color: kSecondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: const Icon(Icons.bluetooth, color: Colors.white),
            title: Text(
              device.name.isNotEmpty ? device.name : "Unknown Device",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            subtitle: Text(device.id.id, style: const TextStyle(color: Colors.white70)),
            onTap: () => getx.Get.to(() => DataPage(device: device)),
          ),
        );
      },
    );
  }
}
