//
// AppDelegate.swift
//

import UIKit
import Common

typealias LaunchOptions = [UIApplication.LaunchOptionsKey: Any]

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: LaunchOptions?) -> Bool {
        window = UIWindow()
        window?.frame = UIScreen.main.bounds
        window?.rootViewController = TabBarController.instantiate()
        window?.makeKeyAndVisible()
        return true
    }
}
