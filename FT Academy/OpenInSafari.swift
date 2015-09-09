//
//  Whatsapp.swift
//  Send2Phone
//
//  Created by Sohel Siddique on 3/27/15.
//  Copyright (c) 2015 Zuzis. All rights reserved.
//

import UIKit

class OpenInSafari : UIActivity{
    
    override init() {
        self.text = ""
        
    }
    
    var text:String?
    
    
    override func activityType()-> String {
        return "openInSafari"
    }
    
    override func activityImage()-> UIImage?
    {
        return UIImage(named: "Safari")!
    }
    
    override func activityTitle() -> String
    {
        return "打开链接"
    }
    
    
    override class func activityCategory() -> UIActivityCategory{
        return UIActivityCategory.Share
    }
    
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true;
    }
    
    override func performActivity() {
        UIApplication.sharedApplication().openURL(NSURL(string:webPageUrl)!)
    }
    
    
    
    
    
    
}