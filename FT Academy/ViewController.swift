//
//  ViewController.swift
//  FT Academy
//
//  Created by Zhang Oliver on 14/12/25.
//  Copyright (c) 2014年 Zhang Oliver. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate {

    @IBOutlet weak var containerView: UIWebView!
    
    var webView: WKWebView?
    
    override func loadView() {
        super.loadView()
        checkWKSupport()
        if supportWK == true {
            self.webView = WKWebView()
            self.view = self.webView!
            self.webView!.navigationDelegate = self
        } else {
            containerView.delegate = self
        }
        let googleAd = GoogleAdMob()
        googleAd.run()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var url = NSURL(string:"http://m.ftchinese.com/phone.html#iOSShareWechat")
        var req = NSURLRequest(URL:url!)
        if supportWK == true {
            self.webView!.loadRequest(req)
            /*
            let templatepath = NSBundle.mainBundle().pathForResource("index", ofType: "html")!
            //let base = NSURL.fileURLWithPath(templatepath)!
            let base = NSURL(string:"http://app005.ftmailbox.com/iphone-2014.html#iOSShareWechat")
            var s = NSString(contentsOfFile:templatepath, encoding:NSUTF8StringEncoding, error:nil)!
            //let ss = "<content>"
            //s = s.stringByReplacingOccurrencesOfString("<content>", withString:ss)
            self.webView!.loadHTMLString(s, baseURL:base)
*/
        } else {
            containerView.loadRequest(req)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func webView(webView: WKWebView!, decidePolicyForNavigationAction navigationAction: WKNavigationAction!, decisionHandler: ((WKNavigationActionPolicy) -> Void)!) {
        if navigationAction.request.URL.scheme == "ftcweixin" {
            shareToWeChat(navigationAction.request.URL.absoluteString!)
            decisionHandler(.Cancel)
        } else if navigationAction.navigationType == .LinkActivated{
            //UIApplication.sharedApplication().openURL(navigationAction.request.URL)
            var urlString = navigationAction.request.URL.absoluteString!
            if urlString.rangeOfString("mailto:") != nil{
                UIApplication.sharedApplication().openURL(navigationAction.request.URL)
            } else {
            openInView (navigationAction.request.URL.absoluteString!)
            }
            decisionHandler(.Cancel)
        } else {
            decisionHandler(.Allow)
        }
    }
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == .LinkClicked {
            openInView(request.URL.absoluteString!)
            return false
        }
        return true;
    }
    func openInView(urlString : String) {
        webPageUrl = urlString
        self.performSegueWithIdentifier("WKWebPageSegue", sender: nil)
    }
    func shareToWeChat(originalUrlString : String) {
        let originalURL = originalUrlString
        var queryStringDictionary = ["url":""]
        var urlComponents : NSArray = (originalURL as NSString!).substringFromIndex(13).componentsSeparatedByString("&")
        for keyValuePair in urlComponents {
            let stringSeparate = keyValuePair.rangeOfString("=").location
            if (stringSeparate>0 && stringSeparate < 100) {
                let pairKey = (keyValuePair as NSString).substringToIndex(stringSeparate)
                let pairValue = (keyValuePair as NSString).substringFromIndex(stringSeparate+1)
                queryStringDictionary[pairKey] = pairValue.stringByRemovingPercentEncoding
            }
        }
        if WXApi.isWXAppInstalled() == false  && 1>1 {
            var alert = UIAlertController(title: "请先安装微信", message: "谢谢您的支持！请先去app store安装微信再分享", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "了解", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
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
    /*
    func webView(webView: UIWebView, shouldStartLoadWithRequest r: NSURLRequest, navigationType nt: UIWebViewNavigationType) -> Bool {
        if r.URL.scheme == "play" {
            println("user would like to hear the podcast")
            return false
        }
        if nt == .LinkClicked { // disable link-clicking
            if self.canNavigate {
                return true
            }
            println("user would like to navigation to \(r.URL)")
            // this is how you would open in Mobile Safari
            // UIApplication.sharedApplication().openURL(r.URL)
            return false
        }
        return true
    }
*/
    
}

