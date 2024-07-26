import Flutter
import UIKit

public class SwiftBluetoothPlugin: NSObject, FlutterPlugin {
    private let bluetoothScanner = BluetoothScanner()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.namay/bluetooth", binaryMessenger: registrar.messenger())
        let instance = SwiftBluetoothPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startScanning":
            bluetoothScanner.startScanning(result: result)
        case "connectToDevice":
            if let args = call.arguments as? [String: Any],
               let deviceId = args["id"] as? String {
                bluetoothScanner.connectToDevice(withId: deviceId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid device ID", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}