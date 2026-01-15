import UIKit
import Flutter
import Foundation
import home_widget
import workmanager_apple
import BackgroundTasks

private let appGroupId = "group.dmytrowidget"

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        GeneratedPluginRegistrant.register(with: self)

        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.turskyi.weather_fit/shared_container",
                                          binaryMessenger: controller.binaryMessenger)
        
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "getSharedContainerPath" {
                if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) {
                    result(url.path)
                } else {
                    result(FlutterError(code: "UNAVAILABLE",
                                        message: "Shared container for \(appGroupId) not found",
                                        details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        })
        
        // This ensures that plugins used in background task are properly registered.
        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }
        
        // Register the periodic task identifier as per workmanager documentation.
        // This prevents the 'No launch handler registered' crash.
        WorkmanagerPlugin.registerPeriodicTask(
            withIdentifier: "weatherfit_background_update",
            frequency: NSNumber(value: 2 * 60 * 60) // 2 hours in seconds
        )
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(60 * 60 * 4)
        
        if #available(iOS 17, *) {
            HomeWidgetBackgroundWorker.setPluginRegistrantCallback { registry in
                GeneratedPluginRegistrant.register(with: registry)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
