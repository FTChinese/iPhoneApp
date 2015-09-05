//
//  global.swift
//  FT Academy
//
//  Created by Zhang Oliver on 14/12/25.
//  Copyright (c) 2014年 Zhang Oliver. All rights reserved.
//

import Foundation
import UIKit
var webPageUrl = "http://m.ftchinese.com/"
var webPageTitle = "FT中文网特别报道"
var webPageDescription = "FT中文网是英国《金融时报》旗下唯一中文网站。"
var webPageImage = "http://i.ftimg.net/picture/5/000045605_piclink.jpg"
var supportWK = false
enum WebViewStatus {
    case ViewToLoad
    case ViewLoaded
    case WebViewLoading
    case WebViewDisplayed
    case WebViewWarned
}
func checkWKSupport() {
    switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
    case .OrderedSame, .OrderedDescending:
        supportWK = true
    case .OrderedAscending:
        supportWK = false
    }
}
func shareToWeChat(originalUrlString : String) {
    let originalURL = originalUrlString
    var queryStringDictionary = ["url":""]
    var urlComponents : NSArray = (originalURL as NSString!).substringFromIndex(13).componentsSeparatedByString("&")
    for keyValuePair in urlComponents {
        let stringSeparate = keyValuePair.rangeOfString("=").location
        if (stringSeparate>0 && stringSeparate < 100) {
            let pairKey = (keyValuePair as! NSString).substringToIndex(stringSeparate)
            let pairValue = (keyValuePair as! NSString).substringFromIndex(stringSeparate+1)
            queryStringDictionary[pairKey] = pairValue.stringByRemovingPercentEncoding
        }
    }
    if WXApi.isWXAppInstalled() == false {
        if supportWK == true {
            var alert = UIAlertController(title: "请先安装微信", message: "谢谢您的支持！请先去app store安装微信再分享", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "了解", style: UIAlertActionStyle.Default, handler: nil))
            //self.presentViewController(alert, animated: true, completion: nil)
        } else {
            var alertView = UIAlertView();
            alertView.addButtonWithTitle("了解");
            alertView.title = "请安装微信";
            alertView.message = "谢谢您的支持！请先去app store安装微信再分享";
            alertView.show();
        }
        return
    }
    var message = WXMediaMessage()
    message.title = queryStringDictionary["title"]
    message.description = queryStringDictionary["description"]
    var image : UIImage
    if queryStringDictionary["img"] != nil {
        let url = NSURL(string: queryStringDictionary["img"]!)
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        image = UIImage(data: data!)!
    } else {
        image = UIImage(named: "Icon")!
    }
    image = image.resizableImageWithCapInsets(UIEdgeInsetsZero)
    message.setThumbImage(image)
    var webpageObj = WXWebpageObject()
    webpageObj.webpageUrl = queryStringDictionary["url"]
    message.mediaObject = webpageObj
    var req = SendMessageToWXReq()
    req.bText = false
    req.message = message
    if queryStringDictionary["to"] == "chat" {
        req.scene = 0
    } else if queryStringDictionary["to"] == "fav" {
        req.scene = 2
    } else {
        req.scene = 1
    }
    WXApi.sendReq(req)
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}