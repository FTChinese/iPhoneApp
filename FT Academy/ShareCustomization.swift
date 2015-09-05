//
//  share.swift
//  FT Academy
//
//  Created by ZhangOliver on 15/9/5.
//  Copyright (c) 2015年 Zhang Oliver. All rights reserved.
//


import UIKit

class DataForShare: NSObject, UIActivityItemSource {
    var url : String = webPageUrl
    var lead : String = webPageDescription
    var imageCover : String = webPageImage
    
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        return webPageTitle;
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        if(activityType == UIActivityTypeMail){
            return webPageDescription
        } else if(activityType == UIActivityTypePostToWeibo || activityType == UIActivityTypePostToTwitter){
            return "【" + webPageTitle + "】" + webPageDescription + "（分享自 @FT中文网）"
        } else {
            return webPageTitle
        }
    }
    
    func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        if(activityType == UIActivityTypeMail){
            return webPageTitle
        } else {
            return webPageTitle
        }
    }
}