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


class WKWebPageController: UIViewController, UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler{
    
    @IBOutlet weak var containerView: UIWebView!
    var webView: WKWebView?
    var myContext = 0
    let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)

    
    @IBOutlet weak var backBarButton: UIBarButtonItem!
    
    @IBOutlet weak var forwardBarButton: UIBarButtonItem!
    
    
    deinit {
        if #available(iOS 8.0, *) {
            self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
            self.webView?.removeObserver(self, forKeyPath: "canGoBack")
            self.webView?.removeObserver(self, forKeyPath: "canGoForward")
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
            if let _ = self.webView {
                self.webView!.loadRequest(req)
            }
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
            
            if let progress0 = self.webView?.estimatedProgress {
            //if let progress: Float = change[NSKeyValueChangeNewKey]?.floatValue {
                let progress = Float(progress0)
                self.progressView.setProgress(progress, animated: true)
                if progress == 1.0 {
                    self.progressView.hidden = true
                } else {
                    self.progressView.hidden = false
                }
                if let selfWebViewUrl = self.webView!.URL {
                    webPageUrl = self.webView!.URL!.absoluteString
                    webPageTitle = self.webView!.title!
                }
            }
            return
        }
        if keyPath == "canGoBack" {
            if let canGoBack = self.webView?.canGoBack {
            //if let canGoBack = change[NSKeyValueChangeNewKey]!.boolValue {
                backBarButton.enabled = canGoBack
            }
            return
        }
        if keyPath == "canGoForward" {
            if let canGoForward = self.webView?.canGoForward {
            //if let canGoForward = change[NSKeyValueChangeNewKey]?.boolValue {
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
            webView!.goBack()
        } else {
            containerView.goBack()
        }
    }

    @IBAction func goForward(sender: AnyObject) {
        if #available(iOS 8.0, *) {
            webView!.goForward()
        } else {
            containerView.goForward()
        }
    }
    
    @IBAction func share(sender: AnyObject) {
        //UIApplication.sharedApplication().openURL(url!)
        let wcActivity = WeChatActivity()
        let wcMoment = WeChatMoment()
        let openInSafari = OpenInSafari()
        var url = NSURL(string:webPageUrl)
        if #available(iOS 8.0, *) {
            url = webView?.URL
        } else {
            url = containerView.request?.URL
        }
        if let myWebsite = url
        {
            let shareData = DataForShare()
            let objectsToShare = [shareData, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [wcActivity, wcMoment, openInSafari])
            activityVC.excludedActivityTypes = [UIActivityTypeAirDrop, UIActivityTypeAddToReadingList]
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func dismissSegue(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func reload(sender: AnyObject) {
        if #available(iOS 8.0, *) {
            webView!.reload()
        } else {
            containerView.reload()
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIScreen.mainScreen().bounds.width > 700 {
            return UIInterfaceOrientationMask.All
        } else {
            return UIInterfaceOrientationMask.Portrait
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

