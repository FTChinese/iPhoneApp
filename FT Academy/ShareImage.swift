//
//  share.swift
//  FT Academy
//
//  Created by ZhangOliver on 15/9/5.
//  Copyright (c) 2015年 Zhang Oliver. All rights reserved.
//


import UIKit

class ShareImageActivityProvider: UIActivityItemProvider {
    
    override func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject?
    {
        return weChatShareIcon
    }
    
}