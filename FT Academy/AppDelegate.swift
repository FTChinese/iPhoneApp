//
//  AppDelegate.swift
//  FT Academy
//
//  Created by Zhang Oliver on 14/12/25.
//  Copyright (c) 2014年 Zhang Oliver. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {
    
    var window: UIWindow?
    //let notificationHandler = NotificationHandler()
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // admob tracking for activision
        
        //SKPaymentQueue.default().add(self)
        if UIDevice.current.userInterfaceIdiom == .pad {
            ACTConversionReporter.report(withConversionID: "937693643", label: "Qe7aCL-Kx2MQy6OQvwM", value: "1.00", isRepeatable: false)
        } else {
            ACTConversionReporter.report(withConversionID: "937693643", label: "TvNTCJmOiGMQy6OQvwM", value: "1.00", isRepeatable: false)
        }
        
        
        //WXApi.registerApp(wechatAppId, withDescription: "FT中文网")
        WXApi.registerApp(wechatAppId)
        
        if WXApi.isWXAppSupport() == true {
            supportedSocialPlatforms.append("wechat")
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
        
        //         let action1 = UIMutableUserNotificationAction()
        //         action1.identifier = "ACTION_1"
        //         action1.title = "first action"
        //         action1.activationMode = UIUserNotificationActivationMode.background
        //         action1.isDestructive = false
        //         action1.isAuthenticationRequired = true
        //
        //         let action2 = UIMutableUserNotificationAction()
        //         action2.identifier = "ACTION_2"
        //         action2.title = "second action"
        //         action2.activationMode = UIUserNotificationActivationMode.foreground
        //         action2.isDestructive = false
        //         action2.isAuthenticationRequired = true
        //
        //         let category1 = UIMutableUserNotificationCategory()
        //         category1.identifier = "CATEGORY_1"
        //         category1.setActions([action1], for: UIUserNotificationActionContext.minimal)
        //         category1.setActions([action1, action2], for: UIUserNotificationActionContext.default)
        //
        //         let categories = NSSet(objects: category1)
        //
        //
        //         let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: categories as? Set<UIUserNotificationCategory>)
        
        
        
        
        // MARK: - Register for remote notification
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            //registerNotificationCategory()
            //UNUserNotificationCenter.current().delegate = notificationHandler
            application.registerForRemoteNotifications()
        } else {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        
        
        
        //        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        //        UIApplication.shared.registerUserNotificationSettings(settings)
        //        UIApplication.shared.registerForRemoteNotifications()
        
        
        // if launched from a tap on a notification
        if let launchOptions = launchOptions {
            if let userInfo = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
                let action = userInfo["action"] as? String
                let id = userInfo["id"] as? String
                guard let aps = userInfo["aps"] as? NSDictionary else {
                    return false
                }
                let title = (aps["alert"] as? NSDictionary)?["title"] as? String
                if let rootViewController = self.window?.rootViewController as? ViewController {
                    rootViewController.happyUser.canTryRequestReview = false
                    rootViewController.openNotification(action, id: id, title: title)
                }
            }
        }
        //NSNotificationCenter.defaultCenter().addObserver(self, selector:"checkForReachability:", name: kReachabilityChangedNotification, object: nil);
        
        return true
    }
    
    
//    private func registerNotificationCategory() {
//        if #available(iOS 10.0, *) {
//            let saySomethingCategory: UNNotificationCategory = {
//                // 1
//                let inputAction = UNTextInputNotificationAction(
//                    identifier: "action.input",
//                    title: "Input",
//                    options: [.foreground],
//                    textInputButtonTitle: "Send",
//                    textInputPlaceholder: "What do you want to say...")
//                
//                // 2
//                let goodbyeAction = UNNotificationAction(
//                    identifier: "action.goodbye",
//                    title: "Goodbye",
//                    options: [.foreground])
//                
//                let cancelAction = UNNotificationAction(
//                    identifier: "action.cancel",
//                    title: "Cancel",
//                    options: [.destructive])
//                
//                // 3
//                return UNNotificationCategory(identifier:"saySomethingCategory", actions: [inputAction, goodbyeAction, cancelAction], intentIdentifiers: [], options: [.customDismissAction])
//            }()
//            UNUserNotificationCenter.current().setNotificationCategories([saySomethingCategory])
//        } else {
//            // Fallback on earlier versions
//        }
//    }
    
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        saveDeviceInfo()
        print(postString)
        sendDeviceToken()
        print("send device token: \(deviceTokenString)")
    }
    
    func saveDeviceInfo() {
        let bundleID = Bundle.main.bundleIdentifier ?? ""
        let appNumber: String
        switch bundleID {
        case "com.ft.ftchinese.ipad":
            appNumber = "1"
        case "com.ft.ftchinese.mobile":
            appNumber = "2"
        default:
            appNumber = "0"
        }
        let timeZone = TimeZone.current.abbreviation() ?? ""
        let status = "start"
        let preference = ""
        let deviceType: String
        if UIDevice.current.userInterfaceIdiom == .pad {
            deviceType = "pad"
        } else {
            deviceType = "phone"
        }
        postString = "d=\(deviceTokenString)&t=\(timeZone)&s=\(status)&p=\(preference)&dt=\(deviceType)&a=\(appNumber)"
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)")
    }
    
    /*
     func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
     print(notification.userInfo!["action"]!)
     }
     
     
     func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
     print(notification.userInfo!["action"])
     switch(identifier!) {
     case "ACTION_1":
     print("ACTION_1")
     case "ACTION_2":
     print("ACTION_2")
     default:
     print("other")
     break
     }
     }
     */
    
    // TODO: - If a user is already using the app, there should be better ways to show the message, such as a scroll down from top
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        if let aps = userInfo["aps"] as? NSDictionary {
            let title: String = (aps["alert"] as? [String:String])?["title"] ?? "为您推荐"
            //let lead: String = (aps["alert"] as? [String:String])?["body"] ?? ""
            if let notiAction = userInfo["action"], let id = userInfo["id"] {
                if let rootViewController = self.window?.rootViewController as? ViewController {
                    if application.applicationState == .inactive || application.applicationState == .background{
                        rootViewController.openNotification(notiAction as? String, id: id as? String, title: title)
                    } else {
                        //                        let alert = UIAlertController(title: title, message: lead, preferredStyle: UIAlertControllerStyle.alert)
                        //                        alert.addAction(UIAlertAction(title: "去看看", style: .default, handler: { (action: UIAlertAction) in
                        //                            rootViewController.openNotification(notiAction as? String, id: id as? String, title: title)
                        //                        }))
                        //                        alert.addAction(UIAlertAction(title: "不感兴趣", style: UIAlertActionStyle.default, handler: nil))
                        //                        rootViewController.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        UIApplication.shared.applicationIconBadgeNumber = 0
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if let rootViewController = self.window?.rootViewController as? ViewController {
            rootViewController.getUserId()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //print ("application did become active")
        UIApplication.shared.applicationIconBadgeNumber = 0
        if let rootViewController = self.window?.rootViewController as? ViewController {
            rootViewController.checkBlankPage()
        }
        // send deviceToken only once
        sendDeviceToken()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    // tap on status bar to scroll back to top
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let events = event?.allTouches {
            let touch = events.first
            if let location = touch?.location(in: self.window) {
                let statusBarFrame = UIApplication.shared.statusBarFrame
                if statusBarFrame.contains(location) {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "statusBarSelected"), object: nil)
                }
            }
        }
    }
    
    
    
    
    
    // MARK: - WeChat authorized login
    
    // MARK: - wechat developer appid
    private let wechatAppId = "wxc1bc20ee7478536a"
    private let wechatAppSecret = "14999fe35546acc84ecdddab197ed0fd"
    private let accessTokenPrefix = "https://api.weixin.qq.com/sns/oauth2/access_token?"
    private let wechatUserInfoPrefix = "https://api.weixin.qq.com/sns/userinfo?"
    
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func onReq(_ req: BaseReq!) {
        // do optional stuff
    }
    
    func onResp(_ resp: BaseResp!) {
        if let authResp = resp as? SendAuthResp {
            if let wechatAuthCode = authResp.code {
                let wechatAccessTokenLink = accessTokenPrefix + "appid=" + wechatAppId + "&secret=" + wechatAppSecret + "&code=" + wechatAuthCode + "&grant_type=authorization_code"
                if let url = URL(string: wechatAccessTokenLink) {
                    getDataFromUrl(url) { (data, response, error)  in
                        DispatchQueue.main.async { () -> Void in
                            guard let data = data , error == nil else { return }
                            do {
                                let JSON = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue: 0))
                                guard let JSONDictionary = JSON as? NSDictionary else  {
                                    print ("WeChat Return Value is Wrong")
                                    return
                                }
                                guard let accessToken = JSONDictionary["access_token"] as? String else {
                                    print ("WeChat Access Token is not a string")
                                    return
                                }
                                guard let openId = JSONDictionary["openid"] as? String else {
                                    print ("WeChat Open Id is not a string")
                                    return
                                }
                                let userInfoUrlString = "\(self.wechatUserInfoPrefix)access_token=\(accessToken)&openid=\(openId)"
                                if let userInfoUrl = URL(string: userInfoUrlString) {
                                    getDataFromUrl(userInfoUrl) { (data, response, error)  in
                                        DispatchQueue.main.async { () -> Void in
                                            guard let data = data , error == nil else { return }
                                            if let JSONString = String(data: data, encoding: .utf8) {
                                                if let rootViewController = self.window?.rootViewController as? ViewController {
                                                    let jsCode = "socialLogin('wechat', '\(JSONString)');"
                                                    print(jsCode)
                                                    rootViewController.webView.evaluateJavaScript(jsCode) { (result, error) in
                                                        if result != nil {
                                                            print (result ?? "unprintable JS result")
                                                        }
                                                        if error != nil {
                                                            print (error ?? "unprintable error")
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } catch let JSONError as NSError {
                                print("\(JSONError)")
                            }
                        }
                    }
                }
            } else {
            }
        } else {
        }
    }
    // code related to wechat authorization end
    
    // MARK: - API Tutorial 4
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        //let config = URLSessionConfiguration.background(withIdentifier: identifier)
        //let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        // TODO: - https://developer.apple.com/reference/uikit/uiapplicationdelegate/1622941-application?language=objc
        // TODO: - identifier can be used to store the file name or product id
        print ("handle events for background url session with the identifier \(identifier)")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let action = url.host
        let id = url.path.replacingOccurrences(of: "/", with: "")
        let title = url.query?.replacingOccurrences(of: "title=", with: "")
        if let rootViewController = self.window?.rootViewController as? ViewController {
            rootViewController.happyUser.canTryRequestReview = false
            rootViewController.openNotification(action, id: id, title: title)
        }
        return true
    }
    
}


class NotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .sound])
        
        // 如果不想显示某个通知，可以直接用空 options 调用 completionHandler:
        // completionHandler([])
    }
}
