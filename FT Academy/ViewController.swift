//
//  ViewController.swift
//  FT Academy
//
//  Created by Zhang Oliver on 14/12/25.
//  Copyright (c) 2014年 Zhang Oliver. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class ViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate, SFSafariViewControllerDelegate {
    
    var uiWebView: UIWebView!
    weak var timer: NSTimer?
    var pageStatus: WebViewStatus?
    var startUrl = "http://app003.ftmailbox.com/iphone-2014.html?isInSWIFT&iOSShareWechat&gShowStatusBar"
    
    let iPadStartUrl = "http://app005.ftmailbox.com/ipad-2014.html?isInSWIFT&iOSShareWechat&gShowStatusBar"
    //let iPadStartUrl = "http://m.ftchinese.com"
    //var startUrl = "http://192.168.253.2:9000?isInSWIFT&iOSShareWechat&gShowStatusBar"
    
    let overlayView = UIView()
    //    let reachability = Reachability.reachabilityForInternetConnection()
    //    var reachabilityNotifierOn = false
    
    
    deinit {
        //print("main view is being deinitialized")
    }
    
    override func loadView() {
        super.loadView()
        pageStatus = .ViewToLoad
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            startUrl = iPadStartUrl
        }
        
        if #available(iOS 8.0, *) {
            var webView: WKWebView?
            webView = WKWebView()
            self.view = webView
            webView!.navigationDelegate = self
            NSNotificationCenter.defaultCenter().addObserverForName("statusBarSelected", object: nil, queue: nil) { event in
                webView!.evaluateJavaScript("scrollToTop()") { (result, error) in
                    if error != nil {
                        //print("an error occored when trying to scroll to Top! ")
                    } else {
                        //print("scrolled to Top!")
                    }
                }
            }
        } else {
            self.uiWebView = UIWebView()
            self.view = self.uiWebView
            uiWebView?.delegate = self
        }
        
        //Add an overlay onto the webview to deal with white screen
        overlayView.backgroundColor = UIColor(netHex:0x002F5F)
        overlayView.frame = self.view.bounds
        self.view.addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
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
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.Bottom, multiplier: 1/3, constant: 1))
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 266))
        view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 210))
        
        let label = UILabel(frame: CGRectMake(0, 0, 441, 21))
        label.center = CGPointMake(160, 284)
        label.textAlignment = NSTextAlignment.Center
        label.text = "英国《金融时报》中文网"
        label.textColor = UIColor.whiteColor()
        self.overlayView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
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
        resetTimer(3)
    }
    
    
    
    func loadFromLocal() {
        
//        let url = NSURL(string:startUrl)
//        let req = NSURLRequest(URL:url!)
        let templatepath = NSBundle.mainBundle().pathForResource("index", ofType: "html")!
        //let base = NSURL.fileURLWithPath(templatepath)!
        let base = NSURL(string: startUrl)
        let s = try! NSString(contentsOfFile:templatepath, encoding:NSUTF8StringEncoding)
        //let ss = "<content>"
        
        if #available(iOS 8.0, *) {
            let webView = self.view as! WKWebView
            //webView.loadRequest(req)
            webView.loadHTMLString(s as String, baseURL:base)
        } else {
            //uiWebView?.loadRequest(req)
            uiWebView.loadHTMLString(s as String, baseURL: base)
        }
        checkConnectionType()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        if pageStatus == .WebViewDisplayed || pageStatus == .WebViewWarned {
            //Deal with white screen when back from other scene
            checkBlankPage()
            //print("back from other scene!")
        } else {
            //print("first time load!")
        }
        //checkConnectionType()
        //turnOnReachabilityNotifier()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(false)
        //turnOffReachabilityNotifier()
    }
    
    func checkBlankPage() {
        if #available(iOS 8.0, *) {
            let webView = self.view as! WKWebView
            webView.evaluateJavaScript("document.querySelector('body').innerHTML") { (result, error) in
                if error != nil {
                    //print("an error occored! Need to refresh the web app! ")
                    self.loadFromLocal()
                } else {
                    self.checkConnectionType()
                    //self.turnOnReachabilityNotifier()
                    //print("js run successfully!")
                }
            }
        } else {
            if let _ = uiWebView.stringByEvaluatingJavaScriptFromString("document.querySelector('body').innerHTML") {
                //self.turnOnReachabilityNotifier()
                checkConnectionType()
                
            } else {
                self.loadFromLocal()
            }
        }
    }
    
    func openNotification(action: String, id: String, title: String) {
        let jsCode: String
        switch(action) {
        case "story":
            jsCode = "readstory('\(id)')"
            break
        case "tag":
            jsCode = "showchannel('/index.php/ft/tag/\(id)?i=2', '\(title)')"
            break
        case "channel":
            jsCode = "showchannel('/index.php/ft/channel/phonetemplate.html?channel=\(id)', '\(title)')"
            break
        case "video":
            jsCode = "watchVideo('\(id)','\(title)')"
            break
        case "photo":
            jsCode = ""
            openInView ("http://www.ftchinese.com/photonews/\(id)?i=3&d=landscape")
            return
        case "gym":
            jsCode = "showSlide('/index.php/ft/interactive/\(id)?i=2', '\(title)', 0)"
            break
        case "special":
            jsCode = ""
            openInView ("http://www.ftchinese.com/interactive/\(id)")
            return
        case "page":
            jsCode = ""
            openInView ("\(id)")
            return
        default:
            jsCode = ""
            break
        }
        if #available(iOS 8.0, *) {
            let webView = self.view as! WKWebView
            webView.evaluateJavaScript(jsCode) { (result, error) in
            }
        } else {
            if let _ = self.uiWebView.stringByEvaluatingJavaScriptFromString(jsCode) {
            }
        }
    }
    
    
    func checkConnectionType() {
        let statusType = IJReachability().connectedToNetworkOfType()
        var connectionType = "unknown"
        switch statusType {
        case .WWAN:
            connectionType = "data"
        case .WiFi:
            connectionType =  "wifi"
        case .NotConnected:
            connectionType =  "no"
        }
        updateConnectionToWeb(connectionType)
    }
    
    func updateConnectionToWeb(connectionType: String) {
        let jsCode = "window.gConnectionType = '\(connectionType)';"
        if #available(iOS 8.0, *) { //WKWebView doesn't support manifest. Load from a statice HTML file.
            let webView = self.view as! WKWebView
            webView.evaluateJavaScript(jsCode) { (result, error) in
                //                if error != nil {
                //                    print("an error occored when trying update connection type! ")
                //                } else {
                //                    print("updated connection type! ")
                //                }
            }
        } else {
            //print("try to update connection type on iOS 7")
            let _ = uiWebView.stringByEvaluatingJavaScriptFromString(jsCode)
            //print("updated connection type on iOS 7")
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
        //print("memory warning in main view!")
        pageStatus = .WebViewWarned
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if pageStatus != .WebViewDisplayed {
            //print ("hide status bar")
            return true
        } else {
            //print ("show status bar")
            //self.prefersStatusBarHidden = false
            return false
        }
    }
    
    //On mobile phone, lock the screen to portrait only
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return UIInterfaceOrientationMask.All
        } else {
            return UIInterfaceOrientationMask.Portrait
        }
    }
    
    override func shouldAutorotate() -> Bool {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return true
        } else {
            return false
        }
    }
    
    //iOS 7 link clicked
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = request.URL!.absoluteString
        if (urlString != startUrl && urlString != "about:blank") {
            resetTimer(1.2)
        }
        if request.URL!.scheme == "ftcweixin" {
            shareToWeChat(urlString)
            return false
        }  else if request.URL!.scheme == "iosaction" {
            turnOnActionSheet(urlString)
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

    
    @available(iOS 8.0, *)
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        let urlString = navigationAction.request.URL!.absoluteString
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
        let urlComponents : NSArray = (originalURL as NSString!).substringFromIndex(13).componentsSeparatedByString("&")
        for keyValuePair in urlComponents {
            let stringSeparate = keyValuePair.rangeOfString("=").location
            if (stringSeparate>0 && stringSeparate < 100) {
                let pairKey = (keyValuePair as! NSString).substringToIndex(stringSeparate)
                let pairValue = (keyValuePair as! NSString).substringFromIndex(stringSeparate+1)
                queryStringDictionary[pairKey] = pairValue.stringByRemovingPercentEncoding
            }
        }
        webPageUrl = queryStringDictionary["url"]!.stringByRemovingPercentEncoding!
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
        let wcFav = WeChatFav()
        let openInSafari = OpenInSafari()
        let url = NSURL(string:webPageUrl)
        if let myWebsite = url {
            let shareData = DataForShare()
            let objectsToShare = [shareData, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [wcActivity, wcMoment, wcFav, openInSafari])
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                //self.presentViewController(controller, animated: true, completion: nil)
                let popup: UIPopoverController = UIPopoverController(contentViewController: activityVC)
                popup.presentPopoverFromRect(CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 4, 0, 0), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            } else {
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
        }
    }
    
    
    
    func openInView(urlString : String) {
        webPageUrl = urlString
        if #available(iOS 9.0, *) {
            // use the safariview for iOS 9
            if urlString.rangeOfString("http://www.ftchinese.com") == nil {
                //when opening an outside url which we have no control over
                let url = NSURL(string:urlString)
                let webVC = SFSafariViewController(URL: url!)
                webVC.delegate = self
                self.presentViewController(webVC, animated: true, completion: nil)
            } else {
                //when opening a url on a page that I can control
                self.performSegueWithIdentifier("WKWebPageSegue", sender: nil)
            }
        } else {
            // Fallback on earlier versions
            self.performSegueWithIdentifier("WKWebPageSegue", sender: nil)
        }
    }
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(controller: SFSafariViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        checkBlankPage()
    }
    
    
    @available(iOS 9.0, *)
    func safariViewController(controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if didLoadSuccessfully == false {
            //print("Page did not load!")
            //controller.dismissViewControllerAnimated(true, completion: nil)
        } else {
            //print("Page Load Successful!")
        }
    }
    
    
    @available(iOS 9.0, *)
    func safariViewController(controler: SFSafariViewController, activityItemsForURL: NSURL, title: String?) -> [UIActivity] {
        webPageUrl = activityItemsForURL.absoluteString
        //http://www.chaumet.cn/?utm_source=FTCMobile-HPFullscreen
        //the title for the above page, which is not utf-8, cannot be captured
        webPageTitle = title!
        if webPageTitle == "" {
            webPageTitle = webPageTitle0
        }
        //print("page title: \(webPageTitle), page url: \(webPageUrl)")
        let wcActivity = WeChatActivity()
        let wcMoment = WeChatMoment()
        return [wcActivity, wcMoment]
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
    
    /*
    func turnOnReachabilityNotifier() {
    if reachabilityNotifierOn == false {
    NSNotificationCenter.defaultCenter().addObserver(self,
    selector: "reachabilityChanged:",
    name: ReachabilityChangedNotification,
    object: reachability)
    
    reachability!.startNotifier()
    reachabilityNotifierOn = true
    print("start listen to reachability")
    }
    }
    
    func turnOffReachabilityNotifier() {
    if reachabilityNotifierOn == true {
    reachability!.stopNotifier()
    NSNotificationCenter.defaultCenter().removeObserver(self,
    name: ReachabilityChangedNotification,
    object: reachability)
    reachabilityNotifierOn = false
    print("stopped listen to reachability")
    }
    }
    
    
    
    
    func reachabilityChanged(note: NSNotification) {
    let reachability = note.object as! Reachability
    var connectionType = "unknown"
    if reachability.isReachable() {
    if reachability.isReachableViaWiFi() {
    connectionType = "wifi"
    } else {
    connectionType = "data"
    }
    } else {
    connectionType = "no"
    }
    updateConnectionToWeb(connectionType)
    }
    
    func checkConnectionType() {
    var connectionType = "unknown"
    if reachability!.isReachableViaWiFi() {
    //print("Reachable via WiFi")
    connectionType =  "wifi"
    } else if reachability!.isReachableViaWWAN() {
    connectionType = "data"
    } else {
    connectionType =  "no"
    }
    updateConnectionToWeb(connectionType)
    /*
    let statusType = IJReachability().connectedToNetworkOfType()
    var connectionType = "unknown"
    switch statusType {
    case .WWAN:
    connectionType = "data"
    case .WiFi:
    connectionType =  "wifi"
    case .NotConnected:
    connectionType =  "no"
    }
    updateConnectionToWeb(connectionType)
    */
    }
    
    func updateConnectionToWeb(connectionType: String) {
    let jsCode = "window.gConnectionType = '\(connectionType)';"
    if #available(iOS 8.0, *) { //WKWebView doesn't support manifest. Load from a statice HTML file.
    let webView = self.view as! WKWebView
    webView.evaluateJavaScript(jsCode) { (result, error) in
    if error != nil {
    print("an error occored when trying update connection type! ")
    } else {
    print("updated connection type! ")
    }
    }
    } else {
    //print("try to update connection type on iOS 7")
    let _ = uiWebView.stringByEvaluatingJavaScriptFromString(jsCode)
    print("updated connection type on iOS 7")
    }
    }
    
    */
    
}

