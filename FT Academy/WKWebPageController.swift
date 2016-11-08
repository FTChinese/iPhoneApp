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
    lazy var webView: WKWebView? = { return nil }()
    var myContext = 0
    let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.default)
    deinit {
        self.webView?.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView?.removeObserver(self, forKeyPath: "canGoBack")
        self.webView?.removeObserver(self, forKeyPath: "canGoForward")
    }
    
    
    override func loadView() {
        super.loadView()
        webPageTitle = webPageTitle0
        webPageDescription = webPageDescription0
        webPageImage = webPageImage0
        webPageImageIcon = webPageImageIcon0
        
        let contentController = WKUserContentController();
        //get page information if it follows opengraph
        let jsCode = "function getContentByMetaTagName(c) {for (var b = document.getElementsByTagName('meta'), a = 0; a < b.length; a++) {if (c == b[a].name || c == b[a].getAttribute('property')) { return b[a].content; }} return '';} var gCoverImage = getContentByMetaTagName('og:image') || '';var gIconImage = getContentByMetaTagName('thumbnail') || '';var gDescription = getContentByMetaTagName('og:description') || getContentByMetaTagName('description') || '';gIconImage=encodeURIComponent(gIconImage);webkit.messageHandlers.callbackHandler.postMessage(gCoverImage + '|' + gIconImage + '|' + gDescription);"
        let userScript = WKUserScript(
            source: jsCode,
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        contentController.add(
            self,
            name: "callbackHandler"
        )
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        self.webView = WKWebView(frame: self.containerView.frame, configuration: config)
        self.containerView.addSubview(self.webView!)
        self.containerView.clipsToBounds = true
        self.webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: &myContext)
        self.webView?.addObserver(self, forKeyPath: "canGoBack", options: .new, context: &myContext)
        self.webView?.addObserver(self, forKeyPath: "canGoForward", options: .new, context: &myContext)
        self.webView?.navigationDelegate = self
        self.webView?.uiDelegate = self
        self.webView?.scrollView.delegate = self
    }
    
    //there's a bug on iOS 9 so that you can't set decelerationRate directly on webView
    //http://stackoverflow.com/questions/31369538/cannot-change-wkwebviews-scroll-rate-on-ios-9-beta
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        
    }
    
    
    
    // message sent back to native app
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            let infoForShare = message.body as! String
            print(infoForShare)
            let toArray = infoForShare.components(separatedBy: "|")
            webPageDescription = toArray[2]
            webPageImage = toArray[0]
            webPageImageIcon = toArray[1]
            print("get image icon from web page: \(webPageImageIcon)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string:webPageUrl) {
            let req = URLRequest(url:url)
            if let currentWebView = self.webView {
                currentWebView.load(req)
                progressView.frame = CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width,height: 10)
                self.containerView.addSubview(progressView)
                backBarButton.isEnabled = false
                forwardBarButton.isEnabled = false
            }
        }
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context != &myContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if keyPath == "estimatedProgress" {
            let progress0 = self.webView!.estimatedProgress
            let progress = Float(progress0)
            self.progressView.setProgress(progress, animated: true)
            if progress == 1.0 {
                self.progressView.isHidden = true
            } else {
                self.progressView.isHidden = false
            }
            if let _ = self.webView!.url {
                webPageUrl = self.webView!.url!.absoluteString
                webPageTitle = self.webView!.title!
                if webPageTitle == "" {
                    webPageTitle = webPageTitle0
                }
            }
            
            return
        }
        if keyPath == "canGoBack" {
            let canGoBack = self.webView!.canGoBack
            backBarButton.isEnabled = canGoBack
            
            return
        }
        if keyPath == "canGoForward" {
            let canGoForward = self.webView!.canGoForward
            forwardBarButton.isEnabled = canGoForward
            
            return
        }
    }
    
    // this handles target=_blank links by opening them in the same view
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goBack(_ sender: AnyObject) {
        self.webView!.goBack()
        
    }
    
    @IBAction func goForward(_ sender: AnyObject) {
        self.webView!.goForward()
        
    }
    
    @IBAction func share(_ sender: AnyObject) {
        let wcActivity = WeChatShare(to: "chat")
        let wcMoment = WeChatShare(to: "moment")
        let openInSafari = OpenInSafari()
        if let myWebsite = self.webView?.url {
            let shareData = DataForShare()
            //let image = UIImage(named: "ftcicon.jpg")!
            let image = ShareImageActivityProvider(placeholderItem: UIImage(named: "ftcicon.jpg")!)
            let objectsToShare = [shareData, myWebsite, image] as [Any]
            //let objectsToShare = [shareData, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [wcActivity, wcMoment, openInSafari])
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            if UIDevice.current.userInterfaceIdiom == .pad {
                //self.presentViewController(controller, animated: true, completion: nil)
                let popup: UIPopoverController = UIPopoverController(contentViewController: activityVC)
                popup.present(from: CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0), in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
            } else {
                self.present(activityVC, animated: true, completion: nil)
            }
            
            if webPageImageIcon == "" {
                weChatShareIcon = UIImage(named: "ftcicon.jpg")
            } else if webPageImageIcon != ""{
                if webPageImageIcon.range(of: "https://image.webservices.ft.com") == nil {
                    webPageImageIcon = "https://image.webservices.ft.com/v1/images/raw/\(webPageImageIcon)?source=ftchinese&width=72&height=72"
                }
                print("image icon is \(webPageImageIcon)")
                if let imgUrl = URL(string: webPageImageIcon) {
                    print("update image icon : \(webPageImageIcon)")
                    updateWeChatShareIcon(imgUrl)
                }
            }
        }
        
    }
    
    
    @IBAction func dismissSegue(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reload(_ sender: AnyObject) {
        self.webView!.reload()
        
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if webPageUrl.range(of: "d=landscape") != nil {
            return UIInterfaceOrientationMask.landscape
        } else if webPageUrl.range(of: "d=portrait") != nil {
            return UIInterfaceOrientationMask.portrait
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
                return UIInterfaceOrientationMask.landscape
            } else {
                return UIInterfaceOrientationMask.portrait
            }
        } else {
            return UIInterfaceOrientationMask.all
        }
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
}

