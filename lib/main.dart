import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothScannerPage(),
    );
  }
}

class BluetoothScannerPage extends StatefulWidget {
  @override
  _BluetoothScannerPageState createState() => _BluetoothScannerPageState();
}

class _BluetoothScannerPageState extends State<BluetoothScannerPage> {
  static const platform = MethodChannel('com.namay/bluetooth');
  List<Map<String, String>> devices = [];
  bool isScanning = false;

  Future<void> startScanning() async {
    setState(() {
      isScanning = true;
      devices.clear();
    });

    try {
      final List<dynamic> result = await platform.invokeMethod('startScanning');
      setState(() {
        devices = result.map((device) => Map<String, String>.from(device)).toList();
        isScanning = false;
      });
    } on PlatformException catch (e) {
      print("Failed to scan: '${e.message}'.");
      setState(() {
        isScanning = false;
      });
    }
  }

  Future<void> connectToDevice(String deviceId) async {
    try {
      final result = await platform.invokeMethod('connectToDevice', {'id': deviceId});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to device: ${result['id']}')),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bluetooth Scanner')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: isScanning ? null : startScanning,
            child: Text(isScanning ? 'Scanning...' : 'Scan'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device['name'] ?? 'Unknown Device'),
                  subtitle: Text(device['id'] ?? 'No ID'),
                  onTap: () => connectToDevice(device['id'] ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}