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
  List<Map<String, dynamic>> devices = [];

  Future<void> startScanning() async {
    try {
      final dynamic result = await platform.invokeMethod('startScanning');
      if (result is Map) {
        setState(() {
          devices.add(Map<String, dynamic>.from(result));
        });
      }
    } on PlatformException catch (e) {
      print("Failed to scan: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bluetooth Scanner')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: startScanning,
            child: Text('Scan'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device['name'] ?? 'Unknown Device'),
                  subtitle: Text(device['id'] ?? 'No ID'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}