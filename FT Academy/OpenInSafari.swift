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
    
    
    override var activityType: UIActivityType {
        return UIActivityType(rawValue: "openInSafari")
    }
    
    override var activityImage: UIImage?
    {
        return UIImage(named: "Safari")!
    }
    
    override var activityTitle : String
    {
        return "打开链接"
    }
    
    
    override class var activityCategory : UIActivityCategory{
        return UIActivityCategory.share
    }
    
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true;
    }
    
    override func perform() {
        UIApplication.shared.openURL(URL(string:webPageUrl)!)
    }
    
    
    
    
    
    
}
