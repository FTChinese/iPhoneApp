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


class WKWebPageController: UIViewController, UIWebViewDelegate{
    @IBOutlet weak var containerView: UIWebView!
    var webView: WKWebView?
    
    override func loadView() {
        super.loadView()
        checkWKSupport()
        if supportWK == true {
            //self.webView = WKWebView()
            var contentController = WKUserContentController();
            var config = WKWebViewConfiguration()
            config.userContentController = contentController
            self.webView = WKWebView(
                frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.height - 44),
                //frame: CGRect(x: 0.0, y: 0.0, width: 1024, height: UIScreen.mainScreen().bounds.height - 44),
                configuration: config
            )
            //self.view = self.webView!
            self.containerView.addSubview(webView!)
            
            webView!.setTranslatesAutoresizingMaskIntoConstraints(false)
            
            var constX = NSLayoutConstraint(item: webView!, attribute: NSLayoutAttribute.RightMargin, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.RightMargin, multiplier: 1, constant: 0)
            //webView!.addConstraint(constX)
            
            self.containerView.clipsToBounds = true
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
        } else {
            containerView.loadRequest(req)
        }
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
        var url = NSURL(string:webPageUrl)
        if supportWK == true {
            url = webView?.URL
        } else {
            url = containerView.request?.URL
        }
        UIApplication.sharedApplication().openURL(url!)
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
    
    override func viewWillTransitionToSize(size: CGSize,
        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
            if supportWK == true {
                
            }
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    /*
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
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
        if supportWK == true {
            self.performSegueWithIdentifier("WKWebPageSegue", sender: nil)
        } else {
            
        }
    }
*/

}

