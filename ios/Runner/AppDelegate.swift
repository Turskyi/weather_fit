import UIKit
import Flutter
import Foundation

private let appGroupId = "group.dmytrowidget"
@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "weatherfit.shared/container", binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler { call, result in
            if call.method == "getAppleAppGroupDirectory" {
                
                if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) {
                    
                    result(containerURL.path)
                } else {
                    
                    result(FlutterError(code: "UNAVAILABLE", message: "App Group container not available", details: nil))
                }
            } else {
                
                result(FlutterMethodNotImplemented)
            }
        }
        
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
}
