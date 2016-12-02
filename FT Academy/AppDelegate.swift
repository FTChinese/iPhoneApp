//
//  AppDelegate.swift
//  FT Academy
//
//  Created by Zhang Oliver on 14/12/25.
//  Copyright (c) 2014年 Zhang Oliver. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WXApiDelegate {
    
    var window: UIWindow?
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //GoogleConversionPing.pingWithConversionId ("993907328", label: "35JGCOi9xAQQgKX32QM", value: "0", isRepeatable: false)
        
        
        // ftchinese iOS激活
        // Google iOS first open tracking snippet
        // Add this code to your application delegate's
        // application:didFinishLaunchingWithOptions: method.
        
        //[ACTConversionReporter reportWithConversionID:@"937693643" label:@"TvNTCJmOiGMQy6OQvwM" value:@"0.00" isRepeatable:NO];
        
        
        //print("launched with options! ")
        
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            ACTConversionReporter.report(withConversionID: "937693643", label: "Qe7aCL-Kx2MQy6OQvwM", value: "1.00", isRepeatable: false)
        } else {
            ACTConversionReporter.report(withConversionID: "937693643", label: "TvNTCJmOiGMQy6OQvwM", value: "1.00", isRepeatable: false)
        }
        
        WXApi.registerApp(wechatAppId, withDescription: "FT中文网")
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
        /*
         let action1 = UIMutableUserNotificationAction()
         action1.identifier = "ACTION_1"
         action1.title = "first action"
         action1.activationMode = UIUserNotificationActivationMode.Background
         action1.destructive = false
         action1.authenticationRequired = true
         
         let action2 = UIMutableUserNotificationAction()
         action2.identifier = "ACTION_2"
         action2.title = "second action"
         action2.activationMode = UIUserNotificationActivationMode.Foreground
         action2.destructive = false
         action2.authenticationRequired = true
         
         let category1 = UIMutableUserNotificationCategory()
         category1.identifier = "CATEGORY_1"
         category1.setActions([action1], forContext: UIUserNotificationActionContext.Minimal)
         category1.setActions([action1, action2], forContext: UIUserNotificationActionContext.Default)
         
         let categories = NSSet(objects: category1)
         
         
         let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: categories as? Set<UIUserNotificationCategory>)
         */
        let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
        
        
        // if launched from a tap on a notification
        if let launchOptions = launchOptions {
            if let userInfo = launchOptions[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
                //                if let action = userInfo["action"], let id = userInfo["id"], let title = userInfo["aps"]!!["alert"] {
                //                    let rootViewController = self.window!.rootViewController as! ViewController
                //                    let _ = setTimeout(5.0, block: { () -> Void in
                //                        rootViewController.openNotification(action as! String, id: id as! String, title: title as! String)
                //                    })
                //                }
                //guard let listOfFriends = tResult["data"] else { return; }
                
                guard let action = userInfo["action"] else {
                    return false
                }
                guard let id = userInfo["id"] else {
                    return false
                }
                guard let aps = userInfo["aps"] as? NSDictionary else {
                    return false
                }
                guard let title = aps["alert"] else {
                    return false
                }
                if let rootViewController = self.window?.rootViewController as? ViewController {
                    let _ = setTimeout(5.0, block: { () -> Void in
                        rootViewController.openNotification(action as? String, id: id as? String, title: title as? String)
                    })
                }
            }
        }
        
        
        /*
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
         [GoogleConversionPing pingWithConversionId:@"993907328"
         label:@"35JGCOi9xAQQgKX32QM"
         value:@"0" isRepeatable:NO];
         
         [WXApi registerApp:@"wxc1bc20ee7478536a" withDescription:@"FT中文网"];
         });
         */
        
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector:"checkForReachability:", name: kReachabilityChangedNotification, object: nil);
        
        
        return true
    }
    
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data ) {
        deviceTokenString = ""
        for i in 0..<deviceToken.count {
            deviceTokenString = deviceTokenString + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        saveDeviceInfo()
        //print(postString)
        sendDeviceToken()
        //print("send device token: \(deviceTokenString)")
    }
    
    func saveDeviceInfo() {
        let bundleID = Bundle.main.bundleIdentifier
        //        if let _ = Bundle.main.bundleIdentifier {
        //            bundleID = Bundle.main.bundleIdentifier!
        //        } else {
        //            bundleID = ""
        //        }
        let appNumber: String
        if bundleID == "com.ft.ftchinese.ipad" {
            appNumber = "1"
        } else if bundleID == "com.ft.ftchinese.mobile" {
            appNumber = "2"
        } else {
            appNumber = "0"
        }
        let timeZone = ltzAbbrev()
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
        let characterSet: CharacterSet = CharacterSet( charactersIn: "<>" )
        let errorString: String = ( error.localizedDescription as NSString )
            .trimmingCharacters( in: characterSet )
            .replacingOccurrences( of: " ", with: "" ) as String
        print(errorString)
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        if let aps = userInfo["aps"] as? NSDictionary {
            let title: String = aps["alert"] as? String ?? "为您推荐"
            let lead: String = userInfo["lead"] as? String ?? ""
            if let notiAction = userInfo["action"], let id = userInfo["id"] {
                if let rootViewController = self.window?.rootViewController as? ViewController {
                    if application.applicationState == .inactive || application.applicationState == .background{
                        rootViewController.openNotification(notiAction as? String, id: id as? String, title: title)
                    } else {
                        let alert = UIAlertController(title: title, message: lead, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "去看看", style: .default, handler: { (action: UIAlertAction) in
                            rootViewController.openNotification(notiAction as? String, id: id as? String, title: title)
                        }))
                        alert.addAction(UIAlertAction(title: "不感兴趣", style: UIAlertActionStyle.default, handler: nil))
                        rootViewController.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        /*
         let notification = UILocalNotification()
         if #available(iOS 8.2, *) {
         notification.alertTitle = "再次打开FT中文网"
         notification.alertBody = "享受尊贵会员特权，限时专送"
         notification.fireDate = NSDate(timeIntervalSinceNow: 10)
         notification.applicationIconBadgeNumber = 5
         notification.userInfo = ["action": "schedule"]
         notification.category = "CATEGORY_1"
         UIApplication.sharedApplication().scheduleLocalNotification(notification)
         } else {
         // Fallback on earlier versions
         }
         */
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // check for new launch ad to download
        // please be very careful when you write this code
        // because it might break the app forever!
        //        let statusType = IJReachability().connectedToNetworkOfType()
        //        if statusType == .wiFi || 1>0{
        //            // if the app is not downloading anything, download the creatives needed
        //        }
        
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
    
    
    
    
    
    // code related to wechat authorization
    
    // wechat developer appid
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
                //let dict = ["response": authResp.code]
                
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
                                            do {
                                                let JSON = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue: 0))
                                                guard let JSONDictionary = JSON as? NSDictionary else  {
                                                    print ("WeChat Return Value is Wrong")
                                                    return
                                                }
                                                //print (JSONDictionary)
                                                guard let nickname = JSONDictionary["nickname"] as? String else {
                                                    print ("WeChat nickname is not a string")
                                                    return
                                                }
                                                guard let openid = JSONDictionary["openid"] as? String else {
                                                    print ("WeChat Open Id is not a string")
                                                    return
                                                }
                                                guard let headimgurl = JSONDictionary["headimgurl"] as? String else {
                                                    print ("WeChat headimgurl is not a string")
                                                    return
                                                }
                                                let sex = JSONDictionary["sex"] as? Int ?? 999
                                                print(JSONDictionary)
                                                var info = ""
                                                for (key, value) in JSONDictionary {
                                                    if let k = key as? String, let v = value as? String {
                                                        info += "\r\n" + k + ": " + v
                                                    }
                                                }
                                                let title = "已经获得用户的微信信息"
                                                let lead = "用户\(nickname)，开放Id是\(openid), 照片链接为“\(headimgurl)”，性别给了个编号为\(sex)，也许是指男性，接下来我们可以利用这些信息来帮助用户登录我们的应用。" + info
                                                let alert = UIAlertController(title: title, message: lead, preferredStyle: UIAlertControllerStyle.alert)
                                                alert.addAction(UIAlertAction(title: "知道了", style: UIAlertActionStyle.default, handler: nil))
                                                if let rootViewController = self.window?.rootViewController as? ViewController {
                                                    rootViewController.present(alert, animated: true, completion: nil)
                                                }
                                                
                                            } catch let JSONError as NSError {
                                                print("\(JSONError)")
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
                
                //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WeChatAuthCodeResp"), object: nil, userInfo: dict)
            } else {
                //let dict = ["response": "Fail"]
                //print("failed wechat auth")
                //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WeChatAuthCodeResp"), object: nil, userInfo: dict)
            }
        } else {
            //let dict = ["response": "Fail"]
            //print("failed wechat auth")
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "WeChatAuthCodeResp"), object: nil, userInfo: dict)
        }
    }
    
    // code related to wechat authorization end
    
    
    
}
