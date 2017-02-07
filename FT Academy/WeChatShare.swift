//
//  WeChatShare.swift
//  FT中文网
//
//  Created by ZhangOliver on 2016/11/1.
//  Copyright © 2016年 Financial Times Ltd. All rights reserved.
//

import UIKit
class WeChatShare : UIActivity{
    var to: String
    var text:String?
    
    init(to: String) {
        self.to = to
    }
    
    override var activityType: UIActivityType {
        switch to {
        case "moment": return UIActivityType(rawValue: "WeChatMoment")
        case "fav": return UIActivityType(rawValue: "WeChatFav")
        default: return UIActivityType(rawValue: "WeChat")
        }
    }
    
    override var activityImage: UIImage? {
        switch to {
        case "moment": return UIImage(named: "Moment")
        case "fav": return UIImage(named: "WeChatFav")
        default: return UIImage(named: "WeChat")
        }
    }
    
    override var activityTitle : String {
        switch to {
        case "moment": return "微信朋友圈"
        case "fav": return "微信收藏"
        default: return "微信好友"
        }
    }
    
    
    override class var activityCategory : UIActivityCategory {
        // use a subclass to return different value for fav
        return UIActivityCategory.share
    }
    
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func perform() {
        var toString = ""
        switch to {
        case "moment": toString = "moment"
        case "fav": toString = "fav"
        default: toString = "chat"
        }
        print ("sent to wechat successfully")
        shareToWeChat("ftcweixin://?url=\(webPageUrl)&title=\(webPageTitle)&description=\(webPageDescription)&img=\(webPageImageIcon)&to=\(toString)")
    }
    
}

// use a subclass to return different value for fav
class WeChatShareFav: WeChatShare {
    override class var activityCategory : UIActivityCategory {
        return UIActivityCategory.action
    }
}
