//
//  share.swift
//  FT Academy
//
//  Created by ZhangOliver on 15/9/5.
//  Copyright (c) 2015年 Zhang Oliver. All rights reserved.
//


import UIKit


class DataForShare: NSObject, UIActivityItemSource {
    var url: String = webPageUrl
    var lead: String = webPageDescription
    var imageCover: String = webPageImage
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return webPageTitle;
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        //Sina Weibo cannot handle arrays. It's either text or image
        var textForShare = ""
        if activityType == UIActivityType.mail {
            textForShare = webPageDescription
        } else if activityType == UIActivityType.postToWeibo || activityType == UIActivityType.postToTwitter {
            textForShare = "【" + webPageTitle + "】" + webPageDescription
            let textForShareCredit = "（分享自 @FT中文网）"
            let textForShareLimit = 140
            let textForShareTailCount = textForShareCredit.characters.count + url.characters.count
            if textForShare.characters.count + textForShareTailCount > textForShareLimit {
                let index = textForShare.characters.index(textForShare.startIndex, offsetBy: textForShareLimit - textForShareTailCount - 3)
                textForShare = textForShare.substring(to: index) + "..."
            }
            textForShare = textForShare + "（分享自 @FT中文网）"
//        } else if activityType == "com.tencent.xin.sharetimeline" {
//            textForShare = webPageTitle
        } else {
            textForShare = webPageTitle
        }
        return textForShare
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        
        if(activityType == UIActivityType.mail){
            return webPageTitle
        } else {
            return webPageTitle
        }
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController,
        thumbnailImageForActivityType activityType: UIActivityType?,
        suggestedSize size: CGSize) -> UIImage? {
            var image : UIImage
            //            if queryStringDictionary["img"] != nil {
            //                var imgUrl = queryStringDictionary["img"]
            //                if imgUrl!.rangeOfString("https://image.webservices.ft.com") == nil{
            //                    imgUrl = "https://image.webservices.ft.com/v1/images/raw/\(imgUrl!)?source=ftchinese&width=72&height=72"
            //                }
            //                let url = NSURL(string: imgUrl!)
            //                let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
            //                if (data == nil) {
            //                    image = UIImage(named: "ftcicon.jpg")!
            //                } else {
            //                    image = UIImage(data: data!)!
            //                }
            //            } else {
            //                image = UIImage(named: "ftcicon.jpg")!
            //            }
            //print("width: \(size.width); height: \(size.height)")
            image = UIImage(named: "ftcicon.jpg")!
            image = image.resizableImage(withCapInsets: UIEdgeInsets.zero)
            return image
    }
    
}
