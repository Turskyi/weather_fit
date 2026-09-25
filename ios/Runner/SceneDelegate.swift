import UIKit
import Flutter

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        if window == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let rootViewController = storyboard.instantiateInitialViewController() {
                let newWindow = UIWindow(windowScene: windowScene)
                newWindow.rootViewController = rootViewController
                self.window = newWindow
                newWindow.makeKeyAndVisible()
            }
        }

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window = window
            appDelegate.setupMethodChannelIfNeeded()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
