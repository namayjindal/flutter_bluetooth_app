import Foundation
import CoreBluetooth

@objc public class BluetoothScanner: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    private var centralManager: CBCentralManager!
    private var discoveredPeripherals: [CBPeripheral] = []
    private var flutterResult: FlutterResult?
    private var connectResult: FlutterResult?
    
    @objc public override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    @objc public func startScanning(result: @escaping FlutterResult) {
        flutterResult = result
        discoveredPeripherals.removeAll()
        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
                self?.stopScanningAndReturnResults()
            }
        } else {
            result(FlutterError(code: "BLUETOOTH_OFF", message: "Bluetooth is not powered on", details: nil))
        }
    }
    
    private func stopScanningAndReturnResults() {
        centralManager.stopScan()
        let devices = discoveredPeripherals.map { peripheral -> [String: String] in
            return [
                "name": peripheral.name ?? "Unknown",
                "id": peripheral.identifier.uuidString
            ]
        }
        flutterResult?(devices)
    }
    
    @objc public func connectToDevice(withId id: String, result: @escaping FlutterResult) {
        connectResult = result
        guard let peripheral = discoveredPeripherals.first(where: { $0.identifier.uuidString == id }) else {
            result(FlutterError(code: "DEVICE_NOT_FOUND", message: "Device not found", details: nil))
            return
        }
        centralManager.connect(peripheral, options: nil)
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectResult?(["status": "connected", "id": peripheral.identifier.uuidString])
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        connectResult?(FlutterError(code: "CONNECTION_FAILED", message: error?.localizedDescription ?? "Failed to connect", details: nil))
    }
}