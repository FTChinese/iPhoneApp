//
//  Whatsapp.swift
//  Send2Phone
//
//  Created by Sohel Siddique on 3/27/15.
//  Copyright (c) 2015 Zuzis. All rights reserved.
//

import UIKit

class WeChatActivity : UIActivity{
    
    override init() {
        self.text = ""
        
    }
    
    var text:String?
    
    
    override func activityType()-> String {
        return "WeChat"
    }
    
    override func activityImage()-> UIImage?
    {
        return UIImage(named: "WeChat")!
    }
    
    override func activityTitle() -> String
    {
        return "微信好友"
    }
    

    override class func activityCategory() -> UIActivityCategory{
        return UIActivityCategory.Action
    }
    
    func getURLFromMessage(message:String)-> NSURL
    {
        var url = "whatsapp://"
        
        if (message != "")
        {
            url = "\(url)send?text=\(message)"
        }
        
        return NSURL(string: url)!
    }
    
    
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true;
    }

    override func performActivity() {
        //webPageUrl = "http%-7A%2F%2Fm.ftchinese.com%2Fstory%2F001063730"
        shareToWeChat("ftcweixin://?url=\(webPageUrl)&title=\(webPageTitle)&description=\(webPageDescription)&img=\(webPageImageIcon)&to=chat")
    }
    
    //href="ftcweixin://?url=http%-7A%2F%2Fm.ftchinese.com%2Fstory%2F001063730&title=%E5%8C%97%E4%BA%AC%E9%98%85%E5%85%B5%E8%83%8C%E5%90%8E%E7%9A%84%E2%80%9C%E5%9B%9B%E5%9B%BD%E6%BC%94%E4%B9%89%E2%80%9D&description=自北京宣布今年9月3日要举行庆祝二战/抗战胜利70周年大阅兵的消息以来，全球的观察家都在猜测，哪些主要国家的哪些重要领导人将会出席北京阅兵式。中国的老百姓讲面子，中国的党政高官更讲面子。来的外国代表越多、其级别越高，北京的这笔风险投资在国内外的政治和宣传市场上获取的回报率就越耀眼。&img=http://i.ftimg.net/picture/5/000045605_piclink.jpg&to=chat"
    
    /*
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        
        
        for activityItem in activityItems{
            if(activityItem.isKindOfClass(NSString)){
                var whatsAppUrl:NSURL = self.getURLFromMessage(self.text!)
                if(UIApplication.sharedApplication().canOpenURL(whatsAppUrl)){
                    UIApplication.sharedApplication().openURL(whatsAppUrl)
                }
                break;
            }
        }

    }
*/
    


    


}