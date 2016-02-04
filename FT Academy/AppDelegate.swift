//
//  AppDelegate.swift
//  FT Academy
//
//  Created by Zhang Oliver on 14/12/25.
//  Copyright (c) 2014年 Zhang Oliver. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var deviceTokenSent = false
    var deviceTokenString = ""
    let deviceTokenUrl = "http://noti.ftacademy.cn/iphone-collect.php"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //GoogleConversionPing.pingWithConversionId ("993907328", label: "35JGCOi9xAQQgKX32QM", value: "0", isRepeatable: false)
        
        
        // ftchinese iOS激活
        // Google iOS first open tracking snippet
        // Add this code to your application delegate's
        // application:didFinishLaunchingWithOptions: method.
        
        //[ACTConversionReporter reportWithConversionID:@"937693643" label:@"TvNTCJmOiGMQy6OQvwM" value:@"0.00" isRepeatable:NO];
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            ACTConversionReporter.reportWithConversionID("937693643", label: "Qe7aCL-Kx2MQy6OQvwM", value: "1.00", isRepeatable: false)
        } else {
            ACTConversionReporter.reportWithConversionID("937693643", label: "TvNTCJmOiGMQy6OQvwM", value: "1.00", isRepeatable: false)
        }
        
        
        WXApi.registerApp("wxc1bc20ee7478536a", withDescription: "FT中文网")
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0

        
        if #available(iOS 8.0, *) {
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
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        } else {
            let settings = UIRemoteNotificationType.Alert.union(UIRemoteNotificationType.Badge).union(UIRemoteNotificationType.Sound)
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(settings)
        }
        
        // if launched from a tap on a notification
        if let launchOptions = launchOptions {
            if let userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] {
                if let action = userInfo["action"], id = userInfo["id"], title = userInfo["aps"]!!["alert"] {
                    let rootViewController = self.window!.rootViewController as! ViewController
                    let _ = setTimeout(5.0, block: { () -> Void in
                        rootViewController.openNotification(action as! String, id: id as! String, title: title as! String)
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
    
    
    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        self.deviceTokenString = ( deviceToken.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
        sendDeviceToken()
        print(self.deviceTokenString)
    }
    
    func sendDeviceToken() {
        let bundleID: String
        if let _ = NSBundle.mainBundle().bundleIdentifier {
            bundleID = NSBundle.mainBundle().bundleIdentifier!
        } else {
            bundleID = ""
        }
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
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            deviceType = "pad"
        } else {
            deviceType = "phone"
        }
        let url = NSURL(string: self.deviceTokenUrl)
        let request = NSMutableURLRequest(URL:url!)
        request.HTTPMethod = "POST"
        let postString = "d=\(self.deviceTokenString)&t=\(timeZone)&s=\(status)&p=\(preference)&dt=\(deviceType)&a=\(appNumber)"
        print(postString)
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if data != nil {
                self.deviceTokenSent = true
//                let urlContent = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
//                print("Data: \(urlContent)")
            } else {
//                print("failed to send token: \(self.deviceTokenString)! ")
            }
        })
        task.resume()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        let characterSet: NSCharacterSet = NSCharacterSet( charactersInString: "<>" )
        let errorString: String = ( error.description as NSString )
            .stringByTrimmingCharactersInSet( characterSet )
            .stringByReplacingOccurrencesOfString( " ", withString: "" ) as String
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
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        var title = "为您推荐"
        if let _ = userInfo["aps"]?["alert"] {
            title = userInfo["aps"]?["alert"] as! String
        }
        var lead = ""
        if let _ = userInfo["lead"] {
            lead = userInfo["lead"] as! String
        }
        
        if let notiAction = userInfo["action"], id = userInfo["id"] {
            let rootViewController = self.window!.rootViewController as! ViewController
            if ( application.applicationState == .Inactive || application.applicationState == .Background  )
            {
                rootViewController.openNotification(notiAction as! String, id: id as! String, title: title)
            } else {
                if #available(iOS 8.0, *) {
                    let alert = UIAlertController(title: title, message: lead, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "去看看", style: .Default, handler: { (action: UIAlertAction!) in
                        //let rootViewController = self.window!.rootViewController as! ViewController
                        rootViewController.openNotification(notiAction as! String, id: id as! String, title: title)
                    }))
                    alert.addAction(UIAlertAction(title: "不感兴趣", style: UIAlertActionStyle.Default, handler: nil))
                    rootViewController.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let alertView = UIAlertView();
                    alertView.addButtonWithTitle("知道了");
                    alertView.title = title;
                    alertView.message = lead;
                    alertView.show();
                }
            }
        }
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
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
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //print ("application did become active")
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        let rootViewController = self.window!.rootViewController as! ViewController
        rootViewController.checkBlankPage()
        // send deviceToken only once
        if self.deviceTokenSent == false && self.deviceTokenString != "" {
            sendDeviceToken()
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // tap on status bar to scroll back to top
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        let events = event!.allTouches()
        let touch = events!.first
        let location = touch!.locationInView(self.window)
        let statusBarFrame = UIApplication.sharedApplication().statusBarFrame
        if CGRectContainsPoint(statusBarFrame, location) {
            NSNotificationCenter.defaultCenter().postNotificationName("statusBarSelected", object: nil)
        }
    }
}

