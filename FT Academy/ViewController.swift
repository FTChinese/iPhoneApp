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

    var webView: WKWebView?
    var uiWebView: UIWebView?
    weak var timer: NSTimer?
    var pageStatus: WebViewStatus?
    //var startUrl = "http://m.ftchinese.com/mba-2014.html#iOSShareWechat&gShowStatusBar"
    //var startUrl = "http://olizh.github.io/?10#isInSWIFT"
    let startUrl = "http://app003.ftmailbox.com/iphone-2014.html?isInSWIFT&iOSShareWechat&gShowStatusBar"
    //let startUrl = "http://m.ftchinese.com/"
    //let startUrl = "http://192.168.253.2:9000?isInSWIFT&iOSShareWechat&gShowStatusBar"
    let overlayView = UIView()
    
    deinit {
        println("main view is being deinitialized")
    }
    
    override func loadView() {
        super.loadView()
        pageStatus = .ViewToLoad
        checkWKSupport()
        if supportWK == true {
            self.webView = WKWebView()
            self.view = self.webView
            self.webView!.navigationDelegate = self
        } else {
            self.uiWebView = UIWebView()
            self.view = self.uiWebView
            uiWebView?.delegate = self
        }
        
        //Add an overlay onto the webview to deal with white screen
        overlayView.backgroundColor = UIColor(netHex:0x002F5F)
        overlayView.frame = self.view.bounds
        self.view.addSubview(overlayView)
        overlayView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraint(NSLayoutConstraint(item: overlayView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: overlayView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: overlayView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: overlayView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Trailing, multiplier: 1, constant: 0))
        
        let imageName = "FTC-start"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 0, y: 0, width: 266, height: 210)
        imageView.contentMode = .ScaleAspectFit
        self.overlayView.addSubview(imageView)
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1/3, constant: 1))
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 266))
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 210))

        let label = UILabel(frame: CGRectMake(0, 0, 441, 21))
        label.center = CGPointMake(160, 284)
        label.textAlignment = NSTextAlignment.Center
        label.text = "努力加载中..."
        label.textColor = UIColor.whiteColor()
        self.overlayView.addSubview(label)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -20))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 441))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 21))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pageStatus = .ViewLoaded
        loadFromLocal()
        pageStatus = .WebViewLoading
        resetTimer(5.0)
    }
    
    func loadFromLocal() {
        var url = NSURL(string:startUrl)
        var req = NSURLRequest(URL:url!)
        if supportWK == true { //WKWebView doesn't support manifest. Load from a statice HTML file.
            //self.webView!.loadRequest(req)
            
            let templatepath = NSBundle.mainBundle().pathForResource("index", ofType: "html")!
            //let base = NSURL.fileURLWithPath(templatepath)!
            let base = NSURL(string: startUrl)
            var s = NSString(contentsOfFile:templatepath, encoding:NSUTF8StringEncoding, error:nil)!
            //let ss = "<content>"
            //s = s.stringByReplacingOccurrencesOfString("<content>", withString:ss)
            self.webView!.loadHTMLString(s as String, baseURL:base)

        } else {
            //UI Web View supports manifest
            //Need more experiments to decide whether it's necessary to load from local file
            uiWebView?.loadRequest(req)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        if pageStatus == .WebViewDisplayed || pageStatus == .WebViewWarned {
            //Code to deal with white screen when back from other scene
            //this code is magical in that it doesn't add new code if the white screen is not displayed
            //yet it reload the page from local file when white screen is displayed
            loadFromLocal()
            NSLog("back from other scene!")
        } else {
            NSLog("first time load!")
        }
    }
    
    func resetTimer(seconds: NSTimeInterval) {
        timer?.invalidate()
        let nextTimer = NSTimer.scheduledTimerWithTimeInterval(seconds, target: self, selector: "handleIdleEvent:", userInfo: nil, repeats: false)
        timer = nextTimer
    }

    func handleIdleEvent(timer: NSTimer) {
        // do whatever you want when idle after certain period of time
        displayWebView()
    }
    
    func displayWebView() {
        if pageStatus != .WebViewDisplayed {
            overlayView.removeFromSuperview()
            pageStatus = .WebViewDisplayed
            //trigger prefersStatusBarHidden
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSLog("memory warning in main view!")
        pageStatus = .WebViewWarned
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if pageStatus != .WebViewDisplayed {
            NSLog ("hide status bar")
            return true
        } else {
            NSLog ("show status bar")
            //self.prefersStatusBarHidden = false
            return false
        }
    }
    
    //On mobile phone, lock the screen to portrait only
    override func supportedInterfaceOrientations() -> Int {
        if UIScreen.mainScreen().bounds.width > 700 {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.Portrait.rawValue)
        }
    }

    override func shouldAutorotate() -> Bool {
        if UIScreen.mainScreen().bounds.width > 700 {
            return true
        } else {
            return false
        }
    }

    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        let urlString = navigationAction.request.URL!.absoluteString!
        if (urlString != startUrl && urlString != "about:blank") {
            //displayWebView()
            resetTimer(1.2)
        }
        if navigationAction.request.URL!.scheme == "ftcweixin" {
            shareToWeChat(urlString)
            decisionHandler(.Cancel)
        } else if navigationAction.request.URL!.scheme == "iosaction" {
            turnOnActionSheet(urlString)
            decisionHandler(.Cancel)
        } else if navigationAction.navigationType == .LinkActivated{
            if urlString.rangeOfString("mailto:") != nil{
                UIApplication.sharedApplication().openURL(navigationAction.request.URL!)
            } else {
                openInView (urlString)
            }
            decisionHandler(.Cancel)
        } else {
            decisionHandler(.Allow)
        }
    }
    
    func turnOnActionSheet(originalUrlString : String) {
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
        webPageUrl = queryStringDictionary["url"]!.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!        
        webPageTitle = queryStringDictionary["title"]!
        if queryStringDictionary["description"] != nil {
            webPageDescription = queryStringDictionary["description"]!
        } else {
            webPageDescription = webPageDescription0
        }
        webPageImage = queryStringDictionary["img"]!
        webPageImageIcon = queryStringDictionary["img"]!
        let wcActivity = WeChatActivity()
        let wcMoment = WeChatMoment()
        let openInSafari = OpenInSafari()
        var url = NSURL(string:webPageUrl)
        if let myWebsite = url
        {
            let shareData = DataForShare()
            let objectsToShare = [shareData, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [wcActivity, wcMoment, openInSafari])
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = request.URL!.absoluteString!
        if (urlString != startUrl && urlString != "about:blank") {
            resetTimer(1.2)
        }
        if request.URL!.scheme == "ftcweixin" {
            shareToWeChat(urlString)
            return false
        } else if navigationType == .LinkClicked{
            if urlString.rangeOfString("mailto:") != nil{
                UIApplication.sharedApplication().openURL(request.URL!)
            } else {
                openInView (urlString)
            }
            return false
        } else {
            return true
        }
    }
    
    func openInView(urlString : String) {
        webPageUrl = urlString
        self.performSegueWithIdentifier("WKWebPageSegue", sender: nil)
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

