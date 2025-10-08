//
//  AppDelegate.swift
//  Mon
//
//  Created by 小胖 on 2020/4/6.
//  Copyright © 2020 riti. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AppTrackingTransparency

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // iOS 14+ 需先等畫面初始化完成再要求追蹤授權
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.requestTrackingPermission()
        }
        
//        MobileAds.shared.start(completionHandler: nil)
        return true
    }
    
    private func requestTrackingPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        print("✅ 使用者允許追蹤")
                        MobileAds.shared.start(completionHandler: nil)
                    case .denied, .restricted, .notDetermined:
                        // 設定非個人化廣告參數
                        let extras = Extras()
                        extras.additionalParameters = ["npa": "1"]

                        // 註冊給全域使用的 request
                        Request().register(extras)

                        MobileAds.shared.start(completionHandler: nil)
                    @unknown default:
                        break
                    }
                }
            }
        } else {
            // iOS 14 以下版本
            MobileAds.shared.start(completionHandler: nil)
        }
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

