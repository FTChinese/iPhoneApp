//
//  WKWebPageController.swift
//  FT Academy
//
//  Created by Zhang Oliver on 14/12/25.
//  Copyright (c) 2014年 Zhang Oliver. All rights reserved.
//

import Foundation
import UIKit
import WebKit


class WKWebPageController: UIViewController, UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate{
    @IBOutlet weak var containerView: UIWebView!
    var webView: WKWebView?
    var myContext = 0
    let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)

    
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    
    @IBOutlet weak var forwardBarButton: UIBarButtonItem!
    
    
    deinit {
        if supportWK == true {
            self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
            self.webView?.removeObserver(self, forKeyPath: "canGoBack")
            self.webView?.removeObserver(self, forKeyPath: "canGoForward")
        }
    }
    
    
    override func loadView() {
        super.loadView()
        checkWKSupport()
        if supportWK == true {
            var contentController = WKUserContentController();
            var config = WKWebViewConfiguration()
            config.userContentController = contentController
            self.webView = WKWebView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 44), configuration: config)
            self.containerView.addSubview(webView!)
            self.containerView.clipsToBounds = true
            self.webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: &myContext)
            self.webView?.addObserver(self, forKeyPath: "canGoBack", options: .New, context: &myContext)
            self.webView?.addObserver(self, forKeyPath: "canGoForward", options: .New, context: &myContext)
            self.webView!.navigationDelegate = self
            self.webView!.UIDelegate = self
        } else {
            containerView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var url = NSURL(string:webPageUrl)
        var req = NSURLRequest(URL:url!)
        if supportWK == true {
            self.webView!.loadRequest(req)
            progressView.frame = CGRectMake(0,0,UIScreen.mainScreen().bounds.width,10)
            self.containerView.addSubview(progressView)
            backBarButton.enabled = false
            forwardBarButton.enabled = false
        } else {
            containerView.loadRequest(req)
        }
    }
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context != &myContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        if keyPath == "estimatedProgress" {
            if let progress: Float = change[NSKeyValueChangeNewKey]?.floatValue {
                self.progressView.setProgress(progress, animated: true)
                if progress == 1.0 {
                    self.progressView.hidden = true
                } else {
                    self.progressView.hidden = false
                }
            }
            return
        }
        if keyPath == "canGoBack" {
            if let canGoBack = change[NSKeyValueChangeNewKey]?.boolValue {
                backBarButton.enabled = canGoBack
            }
            return
        }
        if keyPath == "canGoForward" {
            if let canGoForward = change[NSKeyValueChangeNewKey]?.boolValue {
                forwardBarButton.enabled = canGoForward
            }
            return
        }
    }
    
    // this handles target=_blank links by opening them in the same view
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.loadRequest(navigationAction.request)
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goBack(sender: AnyObject) {
        if supportWK == true {
            webView!.goBack()
        } else {
            containerView.goBack()
        }
    }

    @IBAction func goForward(sender: AnyObject) {
        if supportWK == true {
            webView!.goForward()
        } else {
            containerView.goForward()
        }
    }
    
    @IBAction func share(sender: AnyObject) {
        
        //shareToWeChat("ftcweixin://?url=http%3A%2F%2Fm.ftchinese.com%2Fstory%2F001063730&title=%E5%8C%97%E4%BA%AC%E9%98%85%E5%85%B5%E8%83%8C%E5%90%8E%E7%9A%84%E2%80%9C%E5%9B%9B%E5%9B%BD%E6%BC%94%E4%B9%89%E2%80%9D&description=自北京宣布今年9月3日要举行庆祝二战/抗战胜利70周年大阅兵的消息以来，全球的观察家都在猜测，哪些主要国家的哪些重要领导人将会出席北京阅兵式。中国的老百姓讲面子，中国的党政高官更讲面子。来的外国代表越多、其级别越高，北京的这笔风险投资在国内外的政治和宣传市场上获取的回报率就越耀眼。&img=http://i.ftimg.net/picture/5/000045605_piclink.jpg&to=chat")
        
        
        let wcActivity = WeChatActivity()
        
        
        
        var url = NSURL(string:webPageUrl)
        var textToShare = "share test from oliver"
        if supportWK == true {
            url = webView?.URL
        } else {
            url = containerView.request?.URL
        }
        //UIApplication.sharedApplication().openURL(url!)
        

        
        textToShare = "Swift is awesome!  Check out this website about it!"
        
        if let myWebsite = url
        {
            let objectsToShare = [textToShare, myWebsite]
            //let shareTo = [UIActivityTypePostToWeibo]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [wcActivity])
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }

        
        
    }
    
    
    @IBAction func dismissSegue(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func reload(sender: AnyObject) {
        if supportWK == true {
            webView!.reload()
        } else {
            containerView.reload()
        }
    }
    
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

    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

