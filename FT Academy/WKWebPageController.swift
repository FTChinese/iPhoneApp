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

class WKWebPageController: UIViewController, UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler, UIScrollViewDelegate{
    
    @IBOutlet weak var containerView: UIWebView!
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    @IBOutlet weak var forwardBarButton: UIBarButtonItem!
    var subWKView: UIView?
    @available(iOS 8.0, *)
    lazy var webView: WKWebView? = { return nil }()
    var myContext = 0
    let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)
    
    
    deinit {
        if #available(iOS 8.0, *) {
            //let webView = subWKView as! WKWebView
            self.webView!.removeObserver(self, forKeyPath: "estimatedProgress")
            self.webView!.removeObserver(self, forKeyPath: "canGoBack")
            self.webView!.removeObserver(self, forKeyPath: "canGoForward")
        }
    }
    
    
    override func loadView() {
        super.loadView()
        webPageTitle = webPageTitle0
        webPageDescription = webPageDescription0
        webPageImage = webPageImage0
        webPageImageIcon = webPageImageIcon0
        if #available(iOS 8.0, *) {
            let contentController = WKUserContentController();
            //get page information if it follows opengraph
            let jsCode = "function getContentByMetaTagName(c) {for (var b = document.getElementsByTagName('meta'), a = 0; a < b.length; a++) {if (c == b[a].name || c == b[a].getAttribute('property')) { return b[a].content; }} return '';} var gCoverImage = getContentByMetaTagName('og:image') || '';var gIconImage = getContentByMetaTagName('thumbnail') || '';var gDescription = getContentByMetaTagName('og:description') || getContentByMetaTagName('description') || '';gIconImage=encodeURIComponent(gIconImage);webkit.messageHandlers.callbackHandler.postMessage(gCoverImage + '|' + gIconImage + '|' + gDescription);"
            let userScript = WKUserScript(
                source: jsCode,
                injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
                forMainFrameOnly: true
            )
            contentController.addUserScript(userScript)
            contentController.addScriptMessageHandler(
                self,
                name: "callbackHandler"
            )
            let config = WKWebViewConfiguration()
            config.userContentController = contentController
            //var webView: WKWebView!
            var longLine = UIScreen.mainScreen().bounds.width
            var shortLine = UIScreen.mainScreen().bounds.height
            if longLine < shortLine {
                longLine = UIScreen.mainScreen().bounds.height
                shortLine = UIScreen.mainScreen().bounds.width
            }
            if webPageUrl.rangeOfString("d=landscape") != nil {
                self.webView = WKWebView(frame: CGRect(x: 0.0, y: 0.0, width: longLine, height: shortLine - 44), configuration: config)
            } else if webPageUrl.rangeOfString("d=portrait") != nil {
                self.webView = WKWebView(frame: CGRect(x: 0.0, y: 0.0, width: shortLine, height: longLine - 44), configuration: config)
            } else {
                self.webView = WKWebView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 44), configuration: config)
            }
            self.containerView.addSubview(self.webView!)
            self.containerView.clipsToBounds = true
            self.webView!.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: &myContext)
            self.webView!.addObserver(self, forKeyPath: "canGoBack", options: .New, context: &myContext)
            self.webView!.addObserver(self, forKeyPath: "canGoForward", options: .New, context: &myContext)
            self.webView!.navigationDelegate = self
            self.webView!.UIDelegate = self
            self.webView!.scrollView.delegate = self
            self.subWKView = self.webView
            
        } else {
            containerView.delegate = self
            containerView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        }
        
    }
    
    //there's a bug on iOS 9 so that you can't set decelerationRate directly on webView
    //http://stackoverflow.com/questions/31369538/cannot-change-wkwebviews-scroll-rate-on-ios-9-beta
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if #available(iOS 8.0, *) {
            scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        }
    }
    
    
    
    // message sent back to native app
    @available(iOS 8.0, *)
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            let infoForShare = message.body as! String
            let toArray = infoForShare.componentsSeparatedByString("|")
            webPageDescription = toArray[2]
            webPageImage = toArray[0]
            webPageImageIcon = toArray[1]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL(string:webPageUrl)
        let req = NSURLRequest(URL:url!)
        if #available(iOS 8.0, *) {
            //let webView = self.subWKView as! WKWebView
            self.webView!.loadRequest(req)
            progressView.frame = CGRectMake(0,0,UIScreen.mainScreen().bounds.width,10)
            self.containerView.addSubview(progressView)
            backBarButton.enabled = false
            forwardBarButton.enabled = false
        } else {
            containerView.loadRequest(req)
        }
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context != &myContext {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        if keyPath == "estimatedProgress" {
            if #available(iOS 8.0, *) {
                //let webView = self.subWKView as! WKWebView
                let progress0 = self.webView!.estimatedProgress
                let progress = Float(progress0)
                self.progressView.setProgress(progress, animated: true)
                if progress == 1.0 {
                    self.progressView.hidden = true
                } else {
                    self.progressView.hidden = false
                }
                if let _ = self.webView!.URL {
                    webPageUrl = self.webView!.URL!.absoluteString
                    webPageTitle = self.webView!.title!
                    if webPageTitle == "" {
                        webPageTitle = webPageTitle0
                    }
                }
            }
            return
        }
        if keyPath == "canGoBack" {
            if #available(iOS 8.0, *) {
                //let webView = self.subWKView as! WKWebView
                let canGoBack = self.webView!.canGoBack
                backBarButton.enabled = canGoBack
            }
            return
        }
        if keyPath == "canGoForward" {
            if #available(iOS 8.0, *) {
                //let webView = self.subWKView as! WKWebView
                let canGoForward = self.webView!.canGoForward
                forwardBarButton.enabled = canGoForward
            }
            return
        }
    }
    
    // this handles target=_blank links by opening them in the same view
    @available(iOS 8.0, *)
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
        if #available(iOS 8.0, *) {
            //let webView = self.subWKView as! WKWebView
            self.webView!.goBack()
        } else {
            containerView.goBack()
        }
    }
    
    @IBAction func goForward(sender: AnyObject) {
        if #available(iOS 8.0, *) {
            //let webView = self.subWKView as! WKWebView
            self.webView!.goForward()
        } else {
            containerView.goForward()
        }
    }
    
    @IBAction func share(sender: AnyObject) {
        let wcActivity = WeChatActivity()
        let wcMoment = WeChatMoment()
        let openInSafari = OpenInSafari()
        var url = NSURL(string:webPageUrl)
        if #available(iOS 8.0, *) {
            //let webView = self.subWKView as! WKWebView
            url = self.webView!.URL
        } else {
            url = containerView.request?.URL
            webPageTitle = containerView.stringByEvaluatingJavaScriptFromString("document.title")!
            let jsCode = "function getContentByMetaTagName(c) {for (var b = document.getElementsByTagName('meta'), a = 0; a < b.length; a++) {if (c == b[a].name || c == b[a].getAttribute('property')) { return b[a].content; }} return '';}"
            let _ = containerView.stringByEvaluatingJavaScriptFromString(jsCode)
            webPageDescription = containerView.stringByEvaluatingJavaScriptFromString("getContentByMetaTagName('og:description') || getContentByMetaTagName('description') || ''")!
            webPageImage = containerView.stringByEvaluatingJavaScriptFromString("getContentByMetaTagName('og:image') || ''")!
            webPageImageIcon = containerView.stringByEvaluatingJavaScriptFromString("encodeURIComponent(getContentByMetaTagName('thumbnail') || '')")!
        }
        if let myWebsite = url {
            let shareData = DataForShare()
            let objectsToShare = [shareData, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [wcActivity, wcMoment, openInSafari])
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
                //self.presentViewController(controller, animated: true, completion: nil)
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
    
    
    @IBAction func dismissSegue(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func reload(sender: AnyObject) {
        if #available(iOS 8.0, *) {
            //let webView = self.subWKView as! WKWebView
            self.webView!.reload()
        } else {
            containerView.reload()
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if webPageUrl.rangeOfString("d=landscape") != nil {
            return UIInterfaceOrientationMask.Landscape
        } else if webPageUrl.rangeOfString("d=portrait") != nil {
            return UIInterfaceOrientationMask.Portrait
        } else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            if UIScreen.mainScreen().bounds.width > UIScreen.mainScreen().bounds.height {
                return UIInterfaceOrientationMask.Landscape
            } else {
                return UIInterfaceOrientationMask.Portrait
            }
        } else {
            return UIInterfaceOrientationMask.Portrait
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
}

