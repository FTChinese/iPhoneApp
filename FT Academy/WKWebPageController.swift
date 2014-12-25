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


class WKWebPageController: UIViewController, UIWebViewDelegate, WKNavigationDelegate {
    


    override func viewDidLoad() {
        super.viewDidLoad()
        //webView!.navigationDelegate = self
        var url = NSURL(string:"http://m.ftchinese.com/")
        var req = NSURLRequest(URL:url!)
        //webView!.loadRequest(req)
        println ("opened")
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

    /*
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
        if supportWK == true {
            self.performSegueWithIdentifier("WKWebPageSegue", sender: nil)
        } else {
            
        }
    }
*/
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

