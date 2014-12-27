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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var url = NSURL(string:"http://m.ftchinese.com/")
        var req = NSURLRequest(URL:url!)
        if supportWK == true {
            //self.webView!.loadRequest(req)
            
            let templatepath = NSBundle.mainBundle().pathForResource("index", ofType: "html")!
            //let base = NSURL.fileURLWithPath(templatepath)!
            let base = NSURL(string:"http://m.ftchinese.com/iphone-2014.html#iOSShare")
            var s = NSString(contentsOfFile:templatepath, encoding:NSUTF8StringEncoding, error:nil)!
            //let ss = "<content>"
            //s = s.stringByReplacingOccurrencesOfString("<content>", withString:ss)
            self.webView!.loadHTMLString(s, baseURL:base)

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
        if navigationAction.navigationType == .LinkActivated{
            //UIApplication.sharedApplication().openURL(navigationAction.request.URL)
            openInView (navigationAction.request.URL.absoluteString!)
            decisionHandler(.Cancel)
        }else{
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

