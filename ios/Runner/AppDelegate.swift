import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    SwiftBluetoothPlugin.register(with: self.registrar(forPlugin: "SwiftBluetoothPlugin")!)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}