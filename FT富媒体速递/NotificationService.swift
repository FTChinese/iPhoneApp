//
//  NotificationService.swift
//  FT富媒体速递
//
//  Created by Oliver Zhang on 2017/5/27.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            // bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            if let urlString = bestAttemptContent.userInfo["media"] as? String {
                let urlStringFinal: String
                if urlString.range(of:".jpg") != nil || urlString.range(of:".jpeg") != nil {
                    urlStringFinal = "https://www.ft.com/__origami/service/image/v2/images/raw/\(urlString)?source=ftchinese&width=800&height=450&fit=cover"
                } else {
                    urlStringFinal = urlString
                }
                let fileName: String
                if let url = URL(string: urlString) {
                    fileName = url.lastPathComponent
                } else {
                    fileName = "attachment"
                }
                
                if let url = URL(string: urlStringFinal),
                    let data = NSData(contentsOf: url) as Data? {
                    let path = NSTemporaryDirectory() + fileName
                    // FIXME: - Video files are not able to be created at this point
                    _ = FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
                    do {
                        let file = URL(fileURLWithPath: path)
                        let attachment = try UNNotificationAttachment(
                            identifier: "attachment",
                            url:file,
                            options: nil
                        )
                        bestAttemptContent.attachments = [attachment]
                    } catch {
                        print(error)
                    }
                }
            }
            contentHandler(bestAttemptContent)
        }
    }
    
    
    
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    
}
