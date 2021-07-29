//
//  AppDelegate.swift
//  ddmonitor
//
//  Created by Cong Hu on 2021/3/16.
//

import UIKit

var _2333 = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainVC: ViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        UserDefaults.standard.setValue(nil, forKey: "2333")
        
        if let _23 = UserDefaults.standard.object(forKey: "2333") as? Bool {
            _2333 = true
            print("2333")
            
            if !_23 {
                UserDefaults.standard.setValue(["47377","8792912","21652717","47867"], forKey: "uplist")
                UserDefaults.standard.setValue(true, forKey: "2333")
                
                for i in 0..<9 {
                    UserDefaults.standard.setValue(nil, forKey: "roomId\(i)")
                }
            }
        }
//        else{
//            UserDefaults.standard.setValue(nil, forKey: "uplist")
//        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.backgroundColor = .systemBackground
        mainVC = ViewController()
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("lifecycle DidBecomeActive")
        UIApplication.shared.isIdleTimerDisabled = true
        for p in mainVC.ddLayout.players {
            p.player?.play()
        }

        // 读取剪贴板
        if let clip = UIPasteboard.general.string {
            print(clip)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("lifecycle DidEnterBackground")
        UIApplication.shared.isIdleTimerDisabled = false
    }

    // MARK: UISceneSession Lifecycle

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }


}

