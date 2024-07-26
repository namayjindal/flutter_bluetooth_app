import Foundation
import CoreBluetooth

@objc public class BluetoothScanner: NSObject, CBCentralManagerDelegate {
    private var centralManager: CBCentralManager!
    private var flutterResult: FlutterResult?
    
    @objc public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @objc public func startScanning(result: @escaping FlutterResult) {
        flutterResult = result
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            result(FlutterError(code: "BLUETOOTH_OFF", message: "Bluetooth is not powered on", details: nil))
        }
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let deviceInfo: [String: Any] = [
            "name": peripheral.name ?? "Unknown",
            "id": peripheral.identifier.uuidString
        ]
        flutterResult?(deviceInfo)
    }
}