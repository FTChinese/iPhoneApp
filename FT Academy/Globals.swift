//
//  global.swift
//  FT Academy
//
//  Created by Zhang Oliver on 14/12/25.
//  Copyright (c) 2014年 Zhang Oliver. All rights reserved.
//

import Foundation
import UIKit

// campaign codes that changes every year
let ccode = [
    "wechat": "2G168002",
    "actionsheet": "iosaction"
]
let p=0
let webPageUrl0 = "http://m.ftchinese.com/"
let webPageTitle0 = "来自FT中文网iOS应用的分享"
let webPageDescription0 = "本链接分享自FT中文网的iOS应用，FT中文网是英国《金融时报》旗下唯一中文网站。"
let webPageImage0 = "http://i.ftimg.net/picture/8/000045768_piclink.jpg"
let webPageImageIcon0 = "http://i.ftimg.net/picture/8/000045768_piclink.jpg"
var webPageUrl = ""
var webPageTitle = ""
var webPageDescription = ""
var webPageImage = ""
var webPageImageIcon = ""
var postString = ""
var deviceTokenSent = false
var deviceTokenString = ""
var deviceUserId = "no"
let deviceTokenUrl = "http://noti.ftacademy.cn/iphone-collect.php"

enum WebViewStatus {
    case ViewToLoad
    case ViewLoaded
    case WebViewLoading
    case WebViewDisplayed
    case WebViewWarned
}

enum AppError : ErrorType {
    case InvalidResource(String, String)
}

func sendDeviceToken() {
    if postString != "" && deviceUserId != "no" && deviceTokenSent == false {
        let url = NSURL(string: deviceTokenUrl)
        let request = NSMutableURLRequest(URL:url!)
        let postStringFinal = "\(postString)\(deviceUserId)"
        request.HTTPMethod = "POST"
        //print(postString)
        request.HTTPBody = postStringFinal.dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if data != nil {
                deviceTokenSent = true
                let urlContent = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
                print("Data to \(postStringFinal): \(urlContent)")
            } else {
                print("failed to send token: \(deviceTokenString)! ")
            }
        })
        task.resume()
    }
}

func ltzAbbrev() -> String {
    return NSTimeZone.localTimeZone().abbreviation!
}


func shareToWeChat(originalUrlString : String) {
    let originalURL = originalUrlString
    var queryStringDictionary = ["url":""]
    let urlComponents : NSArray = (originalURL as NSString!).substringFromIndex(13).componentsSeparatedByString("&")
    for keyValuePair in urlComponents {
        let stringSeparate = keyValuePair.rangeOfString("=").location
        if (stringSeparate>0 && stringSeparate < 100) {
            let pairKey = (keyValuePair as! NSString).substringToIndex(stringSeparate)
            let pairValue = (keyValuePair as! NSString).substringFromIndex(stringSeparate+1)
            queryStringDictionary[pairKey] = pairValue
        }
    }
    if WXApi.isWXAppInstalled() == false {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: "请先安装微信", message: "谢谢您的支持！请先去app store安装微信再分享", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "了解", style: UIAlertActionStyle.Default, handler: nil))
        } else {
            // Fallback on earlier versions
            let alertView = UIAlertView();
            alertView.addButtonWithTitle("了解");
            alertView.title = "请安装微信";
            alertView.message = "谢谢您的支持！请先去app store安装微信再分享";
            alertView.show();
        }
        return
    }
    let message = WXMediaMessage()
    message.title = queryStringDictionary["title"]
    message.description = queryStringDictionary["description"]
    var image : UIImage
    
    /*
    var shareOption = ""
    
    // get image data from internet can slow up the process
    // use the default icon now until we figure out a better way
    // http://stackoverflow.com/questions/24231680/loading-image-from-url/28942299
    
    
    if queryStringDictionary["img"] != nil {
        
        let abTest = (0.0...1.0).random()
        if abTest > 0.5 {
            var imgUrl = queryStringDictionary["img"]
            if imgUrl!.rangeOfString("https://image.webservices.ft.com") == nil{
                imgUrl = "https://image.webservices.ft.com/v1/images/raw/\(imgUrl!)?source=ftchinese&width=72&height=72"
            }
            let url = NSURL(string: imgUrl!)
            // make sure your image in this url does exist, otherwise unwrap in a if let check
            let data = NSData(contentsOfURL: url!)
            if (data == nil) {
                image = UIImage(named: "ftcicon.jpg")!
            } else {
                image = UIImage(data: data!)!
            }
            shareOption = "thumbnail"
            //queryStringDictionary["url"] = "\(queryStringDictionary["url"])?shareicon=thumbnail"
            //print("share thumbnail")
        } else {
            image = UIImage(named: "ftcicon.jpg")!
            shareOption = "logo"
            //queryStringDictionary["url"] = "\(queryStringDictionary["url"])?shareicon=logo"
            //print("share logo")
        }

    } else {
        image = UIImage(named: "ftcicon.jpg")!
    }
    */
    
    
    
    if weChatShareIcon != nil {
        image = weChatShareIcon!
    } else {
        image = UIImage(named: "ftcicon.jpg")!
    }

    
    
    //let _ = setTimeout(2.0, block: { () -> Void in
        image = image.resizableImageWithCapInsets(UIEdgeInsetsZero)
        message.setThumbImage(image)
        let webpageObj = WXWebpageObject()
        //webpageObj.webpageUrl = "\(queryStringDictionary["url"]!)?shareicon=\(shareOption)#ccode=\(ccode["wechat"]!)"
    
        var shareUrl = queryStringDictionary["url"]!
        if shareUrl.rangeOfString("story/[0-9]+$", options: .RegularExpressionSearch) != nil {
            shareUrl = shareUrl + "?full=y"
        }
        webpageObj.webpageUrl = "\(shareUrl)#ccode=\(ccode["wechat"]!)"
        message.mediaObject = webpageObj
        let req = SendMessageToWXReq()
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
    //})
}

var weChatShareIcon = UIImage(named: "ftcicon.jpg")

func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
    NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
        completion(data: data, response: response, error: error)
        }.resume()
}


func updateWeChatShareIcon(url: NSURL) {
    print("Download Started")
    print("lastPathComponent: " + (url.lastPathComponent ?? ""))
    weChatShareIcon = UIImage(named: "ftcicon.jpg")
    getDataFromUrl(url) { (data, response, error)  in
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            guard let data = data where error == nil else { return }
            //print(response?.suggestedFilename ?? "")
            //print("Download Finished")
            weChatShareIcon = UIImage(data: data)
        }
    }
}





func setTimeout(delay:NSTimeInterval, block:()->Void) -> NSTimer {
    return NSTimer.scheduledTimerWithTimeInterval(delay, target: NSBlockOperation(block: block), selector: #selector(NSOperation.main), userInfo: nil, repeats: false)
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

extension IntervalType {
    public func random() -> Bound {
        let range = (self.end as! Double) - (self.start as! Double)
        let randomValue = (Double(arc4random_uniform(UINT32_MAX)) / Double(UINT32_MAX)) * range + (self.start as! Double)
        return randomValue as! Bound
    }
}