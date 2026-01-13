import UIKit
import Flutter
import Foundation
import home_widget
import workmanager_apple
import BackgroundTasks
import os

private let appGroupId = "group.dmytrowidget"

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // Register plugins first to ensure they are available for all other operations.
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
        
        // This prevents the iOS crash on launch when identifier is declared in Info.plist.
        if #available(iOS 13.0, *) {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "weatherfit_background_update", using: nil) { task in
                task.setTaskCompleted(success: true)
            }
        }
        
        // Hey iOS, I’d like you to run my background fetch task at least every
        // 4 hours.
        UIApplication.shared.setMinimumBackgroundFetchInterval(60 * 60 * 4)
        
        //This ensures that plugins used in your background task (e.g.,
        // shared_preferences, path_provider, etc.) are properly registered when the
        // background isolate starts.
        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            GeneratedPluginRegistrant.register(with: registry)
        }
        
        if #available(iOS 17, *) {
            HomeWidgetBackgroundWorker.setPluginRegistrantCallback { registry in
                GeneratedPluginRegistrant.register(with: registry)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
