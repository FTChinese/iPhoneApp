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
import AVKit
import AVFoundation



class ViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate, SFSafariViewControllerDelegate {
    
    var webView = WKWebView()
    //lazy var webView: WKWebView? = { return nil }()
    private weak var timer: Timer?
    var pageStatus: WebViewStatus?
    private var startUrl = "http://app003.ftmailbox.com/iphone-2014.html?isInSWIFT&iOSShareWechat&gShowStatusBar"
    private let iPadStartUrl = "http://app005.ftmailbox.com/ipad-2014.html?isInSWIFT&iOSShareWechat&gShowStatusBar"
    // if the app use a native launch ad, suppress the pop up one
    private let useNativeLaunchAd = "useNativeLaunchAd"
    private var maxAdTimeAfterLaunch = 6.0
    private var maxAdTimeAfterWebRequest = 3.0
    
    private let adSchedule = AdSchedule()
    
    private lazy var player: AVPlayer? = {return nil} ()
    private lazy var token: Any? = {return nil} ()
    private lazy var overlayView: UIView? = UIView()
    
    // set to none before releasing this publicly
    private var adType = ""
    
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    
    deinit {
        //print("main view is being deinitialized")
    }
    
    // start to load the webview as soon as possible
    // and cover the whole view with an overlayview of either advertisement or launchscreen
    override func loadView() {
        super.loadView()
        pageStatus = .viewToLoad
        if UIDevice.current.userInterfaceIdiom == .pad {
            startUrl = iPadStartUrl
        }
        //self.webView = WKWebView()
        self.view = self.webView
        self.webView.navigationDelegate = self
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "statusBarSelected"), object: nil, queue: nil) { event in
            self.webView.evaluateJavaScript("scrollToTop()") { (result, error) in
                if error != nil {
                    //print("an error occored when trying to scroll to Top! ")
                } else {
                    //print("scrolled to Top!")
                }
            }
        }
        adOverlayView()
        //normalOverlayView()
    }
    
    // once view is loaded, load html into the webview
    // wait for several seconds before removing the overlay to reveal the web view
    // at the same time, check for new update of the ad schedule
    override func viewDidLoad() {
        super.viewDidLoad()
        pageStatus = .viewLoaded
        loadFromLocal()
        pageStatus = .webViewLoading
        displayWebviewAfterSeconds(maxAdTimeAfterLaunch)
        // download the latest ad schedule from the internet
        if (adType != "none") {
            adSchedule.updateAdSchedule()
        }
    }
    
    // this happens when starting the app and going back from a popover segue
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        if pageStatus == .webViewDisplayed || pageStatus == .webViewWarned {
            //Deal with white screen when back from other scene
            checkBlankPage()
        }
        print(player ?? "video player is now nil")
        print(overlayView ?? "overlay view is now nil")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        pageStatus = .webViewWarned
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override var prefersStatusBarHidden : Bool {
        if pageStatus != .webViewDisplayed {
            return true
        } else {
            return false
        }
    }
    
    //On mobile phone, lock the screen to portrait only
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return UIInterfaceOrientationMask.all
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    override var shouldAutorotate : Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return true
        } else {
            return false
        }
    }
    
    
    // if there's no ad to load
    func normalOverlayView() {
        if let overlayViewNormal = overlayView {
            overlayViewNormal.backgroundColor = UIColor(netHex:0x002F5F)
            overlayViewNormal.frame = self.view.bounds
            self.view.addSubview(overlayViewNormal)
            overlayViewNormal.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: overlayViewNormal, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlayViewNormal, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlayViewNormal, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlayViewNormal, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
            
            // the icon image
            if let image = UIImage(named: "FTC-start") {
                let imageView =  UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: 266, height: 210)
                imageView.contentMode = .scaleAspectFit
                overlayViewNormal.addSubview(imageView)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1/3, constant: 1))
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 266))
                view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 210))
            }
            
            // the lable
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 441, height: 21))
            label.center = CGPoint(x: 160, y: 284)
            label.textAlignment = NSTextAlignment.center
            label.text = "英国《金融时报》中文网"
            label.textColor = UIColor.white
            overlayViewNormal.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -20))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 441))
            view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 21))
        }
    }
    
    
    // if there's a full screen screen ad to show
    private func adOverlayView() {
        if self.adType == "none" {
            maxAdTimeAfterLaunch = 3.0
            maxAdTimeAfterWebRequest = 1.0
            normalOverlayView()
            return
        }
        adSchedule.parseSchedule()
        if let adScheduleDurationInSeconds: Double = adSchedule.durationInSeconds {
            maxAdTimeAfterLaunch = adScheduleDurationInSeconds
            maxAdTimeAfterWebRequest = adScheduleDurationInSeconds - 2.0
        }
        print (maxAdTimeAfterLaunch)
        if adSchedule.adType == "page" {
            addOverlayView()
            showHTMLAd()
        } else if adSchedule.adType == "image" {
            addOverlayView()
            showImage()
        } else if adSchedule.adType == "video" {
            do {
                try playVideo()
            } catch AppError.invalidResource(let name, let type) {
                debugPrint("Could not find resource \(name).\(type)")
            } catch {
                debugPrint("Generic error")
            }
        } else {
            normalOverlayView()
            return
        }
        //button to close the full screen ad
        addCloseButton()
        //set custom background
        setAdBackground()
    }
    
    
    
    private func addOverlayView() {
        if let overlay = overlayView {
            overlay.backgroundColor = UIColor(netHex:0x000000)
            overlay.frame = self.view.bounds
            self.view.addSubview(overlay)
            overlay.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: overlay, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlay, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlay, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlay, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
        }
    }
    
    private func addCloseButton() {
        let image = getImageFromSupportingFile(imageFileName: "close.png")
        let button: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.backgroundColor = UIColor(white: 0, alpha: 0.382)
        button.setImage(image, for: UIControlState())
        
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        
        if adSchedule.adType == "video" {
            self.view.viewWithTag(111)?.addSubview(button)
        } else {
            self.overlayView?.addSubview(button)
        }
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(ViewController.displayWebView), for: .touchUpInside)
        
        view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -16))
        view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 16))
        view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 40))
        view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 40))
    }
    
    private func setAdBackground() {
        if let newBGColor = adSchedule.backgroundColor {
            if adSchedule.adType == "video" {
                self.view.viewWithTag(111)?.backgroundColor = newBGColor
            } else {
                self.overlayView?.backgroundColor = newBGColor
            }
        }
    }
    
    private func showImage() {
        if let image = adSchedule.image {
            let imageView: UIImageView = UIImageView(image: image)
            imageView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            imageView.contentMode = .scaleAspectFit
            self.overlayView?.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: screenWidth))
            view.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: screenHeight))
            imageView.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.clickAd))
            imageView.addGestureRecognizer(tapRecognizer)
        }
    }
    
    private func showHTMLAd() {
        let adPageView = WKWebView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight))
        let base = URL(string: adSchedule.htmlBase)
        let s = adSchedule.htmlFile
        if #available(iOS 10.0, *) {
            adPageView.configuration.mediaTypesRequiringUserActionForPlayback = .init(rawValue: 0)
        } else {
            adPageView.configuration.mediaPlaybackRequiresUserAction = false
        }
        adPageView.loadHTMLString(s as String, baseURL:base)
        overlayView?.addSubview(adPageView)
        if adSchedule.adLink != "" {
            let adPageLinkOverlay = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight))
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.clickAd))
            overlayView?.addSubview(adPageLinkOverlay)
            adPageLinkOverlay.addGestureRecognizer(tapRecognizer)
        }
    }
    
    
    private func playVideo() throws {
        let path = adSchedule.videoFilePath
        maxAdTimeAfterLaunch = 525.0
        maxAdTimeAfterWebRequest = 523.0
        player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        
        let asset = AVURLAsset(url: URL(fileURLWithPath: path))
        let videoDuration = asset.duration
        
        // video view must be added to the self.view, not a subview
        // otherwise Xcode complains about constraints
        playerController.player = player
        
        // the following line seems to be useless
        self.addChildViewController(playerController)
        playerController.showsPlaybackControls = false
        
        //player?.setMediaSelectionCriteria(criteria: AVPlayerMediaSelectionCriteria?, forMediaCharacteristic: <#T##String#>)
        player?.isMuted = true
        player?.play()
        
        self.view.addSubview(playerController.view)
        playerController.view.tag = 111
        playerController.view.frame = self.view.frame
        
        // label for time at the left bottom
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 21))
        let timeLabel = String(format:"%.0f", CMTimeGetSeconds(videoDuration))
        label.textAlignment = NSTextAlignment.center
        label.text = timeLabel
        label.textColor = UIColor.white
        label.backgroundColor = UIColor(white: 0, alpha: 0.382)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 15
        label.tag = 112
        playerController.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 20))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -20))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 30))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 30))
        
        if let image = adSchedule.backupImage {
            playerController.view.backgroundColor = UIColor(patternImage: image)
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.displayWebView), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        if adSchedule.adLink != "" {
            let adPageLinkOverlay = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight - 44))
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.clickAd))
            playerController.view.addSubview(adPageLinkOverlay)
            adPageLinkOverlay.addGestureRecognizer(tapRecognizer)
        }
        
        token = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1,10), queue: DispatchQueue.main, using: { [weak self] timeInterval in
            let timeLeft = CMTimeGetSeconds(videoDuration-timeInterval)
            if let theLabel = self?.view.viewWithTag(112) as? UILabel {
                theLabel.text = String(format:"%.0f", timeLeft)
            }
        })
        
        // button for switching off mute mode
        if adSchedule.showSoundButton == true {
            let imageForMute = getImageFromSupportingFile(imageFileName: "sound.png")
            let imageForSound = getImageFromSupportingFile(imageFileName: "mute.png")
            let button: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            button.backgroundColor = UIColor(white: 0, alpha: 0.382)
            button.setImage(imageForMute, for: UIControlState())
            button.setImage(imageForSound, for: .selected)
            button.layer.masksToBounds = true
            button.layer.cornerRadius = 20
            playerController.view.addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(ViewController.videoMuteSwitch), for: .touchUpInside)
            view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 16))
            view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 16))
            view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 40))
            view.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 40))
        }
        
    }
    
    
    @IBAction private func videoMuteSwitch(sender: UIButton) {
        if sender.isSelected {
            player?.isMuted = true
            sender.isSelected = false
        } else {
            // this will make the video play sound even when iPhone is muted
            player?.isMuted = false
            sender.isSelected = true
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } catch let error as NSError {
                print("Couldn't turn on sound: \(error.localizedDescription)")
            }
        }
    }
    
    private func getImageFromSupportingFile(imageFileName: String) -> UIImage? {
        let filename: NSString = imageFileName as NSString
        let pathExtention = filename.pathExtension
        let pathPrefix = filename.deletingPathExtension
        if let templatepath = Bundle.main.path(forResource: pathPrefix, ofType: pathExtention) {
            let image: UIImage? = UIImage(contentsOfFile: templatepath)
            return image
        }
        return nil
    }
    
    
    // report ad impressions
    private func reportImpressionToWeb(impressions: [String]) {
        var deviceType = "iPhone"
        if UIDevice.current.userInterfaceIdiom == .pad {
            deviceType = "iPad"
        }
        for impressionUrlString in impressions {
            if let url = URL(string: impressionUrlString) {
                getDataFromUrl(url) { (data, response, error)  in
                    DispatchQueue.main.async { () -> Void in
                        guard let _ = data , error == nil else {
                            let jsCode = "try{ga('send','event', '\(deviceType) Launch Ad', 'Fail', '\(impressionUrlString)', {'nonInteraction':1});}catch(ignore){}"
                            self.webView.evaluateJavaScript(jsCode) { (result, error) in
                            }
                            print ("Fail to send impression to \(url.absoluteString)")
                            return
                        }
                        let jsCode = "try{ga('send','event', '\(deviceType) Launch Ad', 'Sent', '\(impressionUrlString)', {'nonInteraction':1});}catch(ignore){}"
                        self.webView.evaluateJavaScript(jsCode) { (result, error) in
                        }
                        print("sent impression to \(url.absoluteString)")
                    }
                }
            }
        }
    }
    
    // this should be public
    func clickAd() {
        openInView(adSchedule.adLink)
    }
    
    
    //Load HTML String from Bundle to start the App
    private func loadFromLocal() {
        if adSchedule.adType != "none" {
            startUrl = "\(startUrl)&\(useNativeLaunchAd)"
        }
        if let templatepath = Bundle.main.path(forResource: "index", ofType: "html") {
            //let base = NSURL.fileURLWithPath(templatepath)!
            let base = URL(string: startUrl)
            do {
                let s = try NSString(contentsOfFile:templatepath, encoding:String.Encoding.utf8.rawValue)
                self.webView.loadHTMLString(s as String, baseURL:base)
            } catch {
                loadFromWeb()
            }
            checkConnectionType()
        } else {
            loadFromWeb()
        }
    }
    
    private func loadFromWeb() {
        if let url = URL(string: startUrl) {
            let req = URLRequest(url: url)
            self.webView.load(req)
        }
    }
    
    
    
    // this is public because AppDelegate is going to use it
    func checkBlankPage() {
        //let webView = self.view as! WKWebView
        self.webView.evaluateJavaScript("document.querySelector('body').innerHTML") { (result, error) in
            if error != nil {
                self.loadFromLocal()
            } else {
                self.checkConnectionType()
            }
        }
        
    }
    
    // when user tap on a remote notification
    // this should be public
    func openNotification(_ action: String, id: String, title: String) {
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
            //let webView = self.view as! WKWebView
            self.webView.evaluateJavaScript(jsCode) { (result, error) in
            }
            
        }
    }
    
    
    private func checkConnectionType() {
        let statusType = IJReachability().connectedToNetworkOfType()
        var connectionType = "unknown"
        switch statusType {
        case .wwan:
            connectionType = "data"
        case .wiFi:
            connectionType =  "wifi"
        case .notConnected:
            connectionType =  "no"
        }
        updateConnectionToWeb(connectionType)
    }
    
    
    
    private func updateConnectionToWeb(_ connectionType: String) {
        let jsCode = "window.gConnectionType = '\(connectionType)';"
        //let webView = self.view as! WKWebView
        self.webView.evaluateJavaScript(jsCode) { (result, error) in
        }
        
    }
    
    
    private func displayWebviewAfterSeconds(_ seconds: TimeInterval) {
        timer?.invalidate()
        let nextTimer = Timer.scheduledTimer(
            timeInterval: seconds,
            target: self,
            selector: #selector(ViewController.displayWebView),
            userInfo: nil,
            repeats: false
        )
        nextTimer.tolerance = 10
        timer = nextTimer
    }
    
    
    
    // this should be public
    func displayWebView() {
        if pageStatus != .webViewDisplayed {
            if overlayView != nil {
                for subUIView in overlayView!.subviews {
                    subUIView.removeFromSuperview()
                }
                overlayView!.removeFromSuperview()
                overlayView = nil
            }
            self.view.viewWithTag(111)?.removeFromSuperview()
            pageStatus = .webViewDisplayed
            //trigger prefersStatusBarHidden
            setNeedsStatusBarAppearanceUpdate()
            getUserId()
            player?.pause()
            if let t = token {
                player?.removeTimeObserver(t)
                token = nil
            }
            //send impression ping
            reportImpressionToWeb(impressions: adSchedule.impression)
            player = nil
        }
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
        if let url = navigationAction.request.url {
            let urlString = url.absoluteString
            if (urlString != startUrl && urlString != "about:blank") {
                displayWebviewAfterSeconds(maxAdTimeAfterLaunch)
            }
            if url.scheme == "ftcweixin" {
                shareToWeChat(urlString)
                decisionHandler(.cancel)
            } else if url.scheme == "iosaction" {
                turnOnActionSheet(urlString)
                decisionHandler(.cancel)
            } else if url.scheme == "weixinlogin" {
                // launch weixin login and switch to wechat
                let req = SendAuthReq()
                req.scope = "snsapi_userinfo"
                req.state = "weliveinfinancialtimes"
                WXApi.send(req)
                decisionHandler(.cancel)
                // all new url schemes should be above here, otherwise the app will crash after clicking
            } else if navigationAction.navigationType == .linkActivated{
                if urlString.range(of: "mailto:") != nil{
                    UIApplication.shared.openURL(url)
                } else {
                    openInView (urlString)
                }
                decisionHandler(.cancel)
            }  else {
                decisionHandler(.allow)
            }
        }
    }
    
    func turnOnActionSheet(_ originalUrlString : String) {
        let originalURL = originalUrlString
        var queryStringDictionary = ["url":""]
        let urlComponents = originalURL.replacingOccurrences(of: "iosaction://?", with: "").components(separatedBy: "&")
        for keyValuePair in urlComponents {
            let stringSeparate = (keyValuePair as AnyObject).range(of: "=").location
            if (stringSeparate>0 && stringSeparate < 100) {
                let pairKey = (keyValuePair as NSString).substring(to: stringSeparate)
                let pairValue = (keyValuePair as NSString).substring(from: stringSeparate+1)
                queryStringDictionary[pairKey] = pairValue.removingPercentEncoding
            }
        }
        //weChatShareIcon = UIImage(named: "ftcicon.jpg")!
        //print(queryStringDictionary)
        webPageUrl = queryStringDictionary["url"]?.removingPercentEncoding ?? webPageUrl
        webPageTitle = queryStringDictionary["title"] ?? webPageTitle
        webPageDescription = queryStringDictionary["description"] ?? webPageDescription0
        webPageImage = queryStringDictionary["img"] ?? webPageImageIcon0
        webPageImageIcon = webPageImage
        
        let wcActivity = WeChatShare(to: "chat")
        let wcCircle = WeChatShare(to: "moment")
        let wcFav = WeChatShareFav(to: "fav")
        let openInSafari = OpenInSafari()
        let ccodeInActionSheet = ccode["actionsheet"] ?? "iosaction"
        let urlWithCCode = "\(webPageUrl)#ccode=\(ccodeInActionSheet)"
        let url = URL(string: urlWithCCode)
        if let myWebsite = url {
            let shareData = DataForShare()
            if let placeHolderImage = UIImage(named: "ftcicon.jpg") {
                let image = ShareImageActivityProvider(placeholderItem: placeHolderImage)
                let objectsToShare = [shareData, myWebsite, image] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [wcActivity, wcCircle, wcFav, openInSafari])
                activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                if UIDevice.current.userInterfaceIdiom == .pad {
                    let popup: UIPopoverController = UIPopoverController(contentViewController: activityVC)
                    popup.present(from: CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0), in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
                } else {
                    self.present(activityVC, animated: true, completion: nil)
                }
            }
        }
        
        if webPageImageIcon.range(of: "https://image.webservices.ft.com") == nil{
            webPageImageIcon = "https://image.webservices.ft.com/v1/images/raw/\(webPageImageIcon)?source=ftchinese&width=72&height=72"
        }
        if let imgUrl = URL(string: webPageImageIcon) {
            updateWeChatShareIcon(imgUrl)
        }
        
    }
    
    func openInView(_ urlString : String) {
        webPageUrl = urlString
        if #available(iOS 9.0, *) {
            // use the safariview for iOS 9
            if urlString.range(of: "http://www.ftchinese.com") == nil {
                //when opening an outside url which we have no control over
                if let url = URL(string:urlString) {
                    let webVC = SFSafariViewController(url: url)
                    webVC.delegate = self
                    self.present(webVC, animated: true, completion: nil)
                }
            } else {
                //when opening a url on a page that I can control
                self.performSegue(withIdentifier: "WKWebPageSegue", sender: nil)
            }
        } else {
            // Fallback on earlier versions
            self.performSegue(withIdentifier: "WKWebPageSegue", sender: nil)
        }
    }
    
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
        checkBlankPage()
    }
    
    
    @available(iOS 9.0, *)
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        if didLoadSuccessfully == false {
            //print("Page did not load!")
            //controller.dismissViewControllerAnimated(true, completion: nil)
        } else {
            //print("Page Load Successful!")
        }
    }
    
    
    @available(iOS 9.0, *)
    func safariViewController(_ controler: SFSafariViewController, activityItemsFor activityItemsForURL: URL, title: String?) -> [UIActivity] {
        webPageUrl = activityItemsForURL.absoluteString
        //http://www.chaumet.cn/?utm_source=FTCMobile-HPFullscreen
        //the title for the above page, which is not utf-8, cannot be captured
        webPageTitle = title ?? webPageTitle0
        let wcActivity = WeChatShare(to: "chat")
        let wcMoment = WeChatShare(to: "moment")
        return [wcActivity, wcMoment]
    }
    
    
    
    
    // MARK: NSCoding
    
    //        var users = [User]()
    //
    //        func saveUsers() {
    //            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(users, toFile: User.ArchiveURL.path!)
    //            if !isSuccessfulSave {
    //                print ("Failed to save meals...")
    //            } else {
    //                print ("save user id \(users[0].userid)")
    //            }
    //        }
    //
    //        func loadUsers() -> [User]? {
    //            print ("load from saved Users")
    //            return NSKeyedUnarchiver.unarchiveObjectWithFile(User.ArchiveURL.path!) as? [User]
    //        }
    //
    //
    //        func updateUserId(userId: String) {
    //            if let savedUsers = loadUsers() {
    //                users = savedUsers
    //            } else {
    //                let user1 = User(userid: "")!
    //                users += [user1]
    //            }
    //            users[0].userid = userId
    //            saveUsers()
    //        }
    
    // this should be public
    func getUserId() {
        var userId = ""
        self.webView.evaluateJavaScript("getCookie('USER_ID')") { (result, error) in
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
    }
    
    private func sendToken(_ userId: String) {
        var userIdString = userId
        if userId != "" {
            userIdString = "&u=\(userId)"
        }
        //print ("useridstring: \(userIdString), deviceUserId: \(deviceUserId)")
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

