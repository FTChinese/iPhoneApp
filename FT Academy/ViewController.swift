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
    @available(iOS 8.0, *)
    lazy var webView: WKWebView? = { return nil }()
    weak var timer: NSTimer?
    var pageStatus: WebViewStatus?
    var startUrl = "http://app003.ftmailbox.com/iphone-2014.html?isInSWIFT&iOSShareWechat&gShowStatusBar"
    //var startUrl = "http://192.168.253.25:9000/?isInSWIFT&iOSShareWechat&gShowStatusBar"
    let iPadStartUrl = "http://app005.ftmailbox.com/ipad-2014.html?isInSWIFT&iOSShareWechat&gShowStatusBar"
    let overlayView = UIView()
    
    deinit {
        //print("main view is being deinitialized")
    }
    
    override func loadView() {
        super.loadView()
        //print("load view")
        pageStatus = .ViewToLoad
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            startUrl = iPadStartUrl
        }
        
        if #available(iOS 8.0, *) {
            //var webView: WKWebView!
            self.webView = WKWebView()
            self.view = self.webView
            self.webView!.navigationDelegate = self
            NSNotificationCenter.defaultCenter().addObserverForName("statusBarSelected", object: nil, queue: nil) { event in
                self.webView!.evaluateJavaScript("scrollToTop()") { (result, error) in
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
            //let webView = self.view as! WKWebView
            //webView.loadRequest(req)
            self.webView!.loadHTMLString(s as String, baseURL:base)
        } else {
            //uiWebView?.loadRequest(req)
            uiWebView.loadHTMLString(s as String, baseURL: base)
        }
        checkConnectionType()
        
        
        // get the current userid and save it
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        if pageStatus == .WebViewDisplayed || pageStatus == .WebViewWarned {
            //Deal with white screen when back from other scene
            checkBlankPage()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(false)
    }
    
    func checkBlankPage() {
        if #available(iOS 8.0, *) {
            //let webView = self.view as! WKWebView
            self.webView!.evaluateJavaScript("document.querySelector('body').innerHTML") { (result, error) in
                if error != nil {
                    self.loadFromLocal()
                } else {
                    self.checkConnectionType()
                }
            }
        } else {
            if let _ = uiWebView.stringByEvaluatingJavaScriptFromString("document.querySelector('body').innerHTML") {
                checkConnectionType()
            } else {
                self.loadFromLocal()
            }
        }
    }
    
    //when user tap on a remote notification
    func openNotification(action: String, id: String, title: String) {
        var jsCode: String
        switch(action) {
        case "story":
            jsCode = "readstory('\(id)')"
        case "tag":
            jsCode = "showchannel('/index.php/ft/tag/\(id)?i=2', '\(id)')"
        case "channel":
            jsCode = "showchannel('/index.php/ft/channel/phonetemplate.html?channel=\(id)', '\(id)')"
        case "video":
            jsCode = "watchVideo('\(id)','视频')"
        case "photo":
            jsCode = ""
            openInView ("http://www.ftchinese.com/photonews/\(id)?i=3&d=landscape")
        case "gym":
            jsCode = "showSlide('/index.php/ft/interactive/\(id)?i=2', 'FT商学院', 0)"
        case "special":
            jsCode = ""
            openInView ("http://www.ftchinese.com/interactive/\(id)")
        case "page":
            jsCode = ""
            openInView ("\(id)")
        default:
            jsCode = ""
            break
        }
        if jsCode != "" {
            jsCode = "try{ga('set', 'campaignName', '\(action)');ga('set', 'campaignSource', 'Apple Push Service');ga('set', 'campaignMedium', 'Push Notification');}catch(ignore){}\(jsCode);ga('send','event', 'Tap Notification', '\(action)', '\(id)');fa('send','event', 'Tap Notification', '\(action)', '\(id)');"
            if #available(iOS 8.0, *) {
                //let webView = self.view as! WKWebView
                self.webView!.evaluateJavaScript(jsCode) { (result, error) in
                }
            } else {
                if let _ = self.uiWebView.stringByEvaluatingJavaScriptFromString(jsCode) {
                }
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
        if #available(iOS 8.0, *) {
            //let webView = self.view as! WKWebView
            self.webView!.evaluateJavaScript(jsCode) { (result, error) in
            }
        } else {
            let _ = uiWebView.stringByEvaluatingJavaScriptFromString(jsCode)
        }
    }
    
    
    func resetTimer(seconds: NSTimeInterval) {
        timer?.invalidate()
        let nextTimer = NSTimer.scheduledTimerWithTimeInterval(seconds, target: self, selector: #selector(ViewController.handleIdleEvent(_:)), userInfo: nil, repeats: false)
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
            getUserId()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        pageStatus = .WebViewWarned
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        if pageStatus != .WebViewDisplayed {
            return true
        } else {
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

    //iOS 8 link clicked
    @available(iOS 8.0, *)
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: ((WKNavigationActionPolicy) -> Void)) {
        let urlString = navigationAction.request.URL!.absoluteString
        if (urlString != startUrl && urlString != "about:blank") {
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
        print(queryStringDictionary)
        webPageUrl = queryStringDictionary["url"]!.stringByRemovingPercentEncoding!
        webPageTitle = queryStringDictionary["title"]!
        if queryStringDictionary["description"] != nil {
            webPageDescription = queryStringDictionary["description"]!
        } else {
            webPageDescription = webPageDescription0
        }
        if queryStringDictionary["img"] != nil {
            webPageImage = queryStringDictionary["img"]!
        } else {
            webPageImage = webPageImageIcon0
        }
        
        webPageImageIcon = webPageImage

        let wcActivity = WeChatActivity()
        let wcCircle = WeChatMoment()
        let wcFav = WeChatFav()
        let openInSafari = OpenInSafari()
        let ccodeInActionSheet = ccode["actionsheet"]! as String
        let urlWithCCode = "\(webPageUrl)#ccode=\(ccodeInActionSheet)"
        let url = NSURL(string: urlWithCCode)
        if let myWebsite = url {
            let shareData = DataForShare()
            let objectsToShare = [shareData, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [wcActivity, wcCircle, wcFav, openInSafari])
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                let popup: UIPopoverController = UIPopoverController(contentViewController: activityVC)
                popup.presentPopoverFromRect(CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height / 4, 0, 0), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            } else {
                self.presentViewController(activityVC, animated: true, completion: nil)
            }
        }
        
        if webPageImageIcon.rangeOfString("https://image.webservices.ft.com") == nil{
            webPageImageIcon = "https://image.webservices.ft.com/v1/images/raw/\(webPageImageIcon)?source=ftchinese&width=72&height=72"
        }
        if let imgUrl = NSURL(string: webPageImageIcon) {
            updateWeChatShareIcon(imgUrl)
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
        let wcActivity = WeChatActivity()
        let wcMoment = WeChatMoment()
        return [wcActivity, wcMoment]
    }
    
    

    
    // MARK: NSCoding
    
//    var users = [User]()
//    
//    func saveUsers() {
//        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(users, toFile: User.ArchiveURL.path!)
//        if !isSuccessfulSave {
//            print ("Failed to save meals...")
//        } else {
//            print ("save user id \(users[0].userid)")
//        }
//    }
//    
//    func loadUsers() -> [User]? {
//        print ("load from saved Users")
//        return NSKeyedUnarchiver.unarchiveObjectWithFile(User.ArchiveURL.path!) as? [User]
//    }
//    
//    
//    func updateUserId(userId: String) {
//        if let savedUsers = loadUsers() {
//            users = savedUsers
//        } else {
//            let user1 = User(userid: "")!
//            users += [user1]
//        }
//        users[0].userid = userId
//        saveUsers()
//    }
    
    func getUserId() {
        var userId = ""
        if #available(iOS 8.0, *) {
            self.webView!.evaluateJavaScript("getCookie('USER_ID')") { (result, error) in
                if error != nil {
                    print ("error running js")
                    //self.loadFromLocal()
                } else {
                    //get the user id
                    let resultString = result as? String
                    if resultString != nil {
                        userId = resultString!
                        //print ("the cookie value is \(resultString!)")
                        //self.updateUserId(resultString!)
                    } else {
                        //print ("cookie is not available")
                    }
                    self.sendToken(userId)
                }
            }
        } else {
            if let uId = uiWebView.stringByEvaluatingJavaScriptFromString("getCookie('USER_ID')") {
                if uId != "null" && uId != "" {
                    userId = uId
                }
                self.sendToken(userId)
            }
        }
    }
    
    func sendToken(userId: String) {
        
        var userIdString = userId
        if userId != "" {
            userIdString = "&u=\(userId)"
        }
        print ("useridstring: \(userIdString), deviceUserId: \(deviceUserId)")
        if userIdString != deviceUserId {
            deviceTokenSent = false
            deviceUserId = userIdString
        }
        if deviceTokenSent == false {
            sendDeviceToken()
        }
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

