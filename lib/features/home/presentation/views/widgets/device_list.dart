import 'package:chem_tech_gravity_app/core/utils/dialog.dart';
import 'package:chem_tech_gravity_app/features/home/presentation/views/widgets/signal_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart' as getx;
import '../../../../data/presentation/widgets/bottom_navigation_bar.dart';

class DeviceList extends StatefulWidget {
  final List<ScanResult> devices;
  final bool isScanning;
  final VoidCallback onRefresh;

  const DeviceList({
    super.key,
    required this.devices,
    required this.isScanning,
    required this.onRefresh,
  });

  @override
  State<DeviceList> createState() => _DeviceListState();
}

class _DeviceListState extends State<DeviceList> {
  final Map<String, ConnectionStatus> _connectionStatuses = {};

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        widget.onRefresh();
      },
      child: Stack(
        children: [
          ListView.builder(
            itemCount: widget.devices.length,
            itemBuilder: (context, index) {
              final device = widget.devices[index].device;
              final rssi = widget.devices[index].rssi;
              final status = _connectionStatuses[device.id.id] ??
                  ConnectionStatus.disconnected;

              return _BluetoothDeviceCard(
                name: device.name.isNotEmpty ? device.name : "Unknown Device",
                mac: device.id.id,
                rssi: rssi,
                status: status,
                onTap: () => _handleDeviceTap(context, device),
              );
            },
          ),
          if (widget.isScanning)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  ///serial photo gate
  Future<void> _handleDeviceTap(
      BuildContext context, BluetoothDevice device) async {
    final deviceName = device.name.trim();

    /// Check for exact format: PhG_ct-FFFF where F is hex from 0000 to FFFF
    final regex = RegExp(r'^PhG_ct-([0-9A-Fa-f]{1,4})$');
    final match = regex.firstMatch(deviceName);

    if (match == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This is not a Photo Gate device.')),
      );
      return;
    }

    /// Convert hex to decimal and check range
    final hexPart = match.group(1)!;
    final value = int.tryParse(hexPart, radix: 16);
    if (value == null || value < 0 || value > 65535) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This is not a Photo Gate device.')),
      );
      return;
    }

    /// Proceed to connect if valid
    setState(() {
      _connectionStatuses[device.id.id] = ConnectionStatus.connecting;
    });

    try {
      BluetoothConnectionState connectionState = await device.state.first;

      if (connectionState == BluetoothConnectionState.connected) {
        setState(() {
          _connectionStatuses[device.id.id] = ConnectionStatus.connected;
        });
        _showAlreadyConnectedDialog(context);
      } else {
        await device.connect(autoConnect: false);
        setState(() {
          _connectionStatuses[device.id.id] = ConnectionStatus.connected;
        });
        getx.Get.to(() => BottomNavigationBarView(device));
      }
    } catch (e) {
      setState(() {
        _connectionStatuses[device.id.id] = ConnectionStatus.disconnected;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection failed: ${e.toString()}')),
      );
    }
  }

  void _showAlreadyConnectedDialog(BuildContext context) {
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: const Text('Connection Error'),
    //     content:
    //         const Text('This device is already connected to another device.'),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context),
    //         child: const Text('OK'),
    //       ),
    //     ],
    //   ),
    // );
    showAlertDialog(
        context: context,
        title: 'Connection Error',
        message: 'This device is already connected to another device.',
      onConfirm: () => Navigator.pop(context),
      confirmText: "OK"
    );
  }
}

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
}

class _BluetoothDeviceCard extends StatelessWidget {
  final String name;
  final String mac;
  final int rssi;
  final ConnectionStatus status;
  final VoidCallback? onTap;

  const _BluetoothDeviceCard({
    required this.name,
    required this.mac,
    required this.rssi,
    required this.status,
    this.onTap,
  });

  String calculateDistance(int rssi) {
    double txPower = -59;
    double ratio = rssi / txPower;
    double distance =
        (ratio < 1.0) ? ratio * ratio : 0.89976 * (ratio * ratio) + 0.111;
    return distance.toStringAsFixed(1);
  }

  Color _getStatusColor() {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
        return Colors.orange;
      case ConnectionStatus.disconnected:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (status) {
      case ConnectionStatus.connected:
        return "Connected";
      case ConnectionStatus.connecting:
        return "Connecting...";
      case ConnectionStatus.disconnected:
        return "Disconnected";
    }
  }

  Color _getSignalColor(int rssi) {
    if (rssi >= -60) return Colors.green;
    if (rssi >= -70) return Colors.orange;
    if (rssi >= -80) return Colors.deepOrange;
    return Colors.red;
  }

  String _getSignalStrength(int rssi) {
    if (rssi >= -60) return "Very Strong";
    if (rssi >= -70) return "Strong";
    if (rssi >= -80) return "Fair";
    return "Weak";
  }

  @override
  Widget build(BuildContext context) {
    final distance = calculateDistance(rssi);
    final statusColor = _getStatusColor();
    final statusText = _getStatusText();
    final signalColor = _getSignalColor(rssi);
    final signalStrength = _getSignalStrength(rssi);

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bluetooth,
                      color: Colors.deepPurple, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mac,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SignalInfoColumn(
                  icon: Icons.straighten,
                  label: "Distance",
                  value: "$distance m",
                  valueColor: Colors.deepPurple,
                ),
                SignalInfoColumn(
                  icon: Icons.signal_cellular_alt,
                  label: "Signal",
                  value: signalStrength,
                  valueColor: signalColor,
                  iconColor: signalColor,
                ),
                SignalInfoColumn(
                  icon: Icons.wifi_tethering,
                  label: "RSSI",
                  value: "$rssi dBm",
                  valueColor: Colors.deepPurple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
