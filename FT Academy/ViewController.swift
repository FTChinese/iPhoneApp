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
import StoreKit
import FolioReaderKit


class ViewController: UIViewController, UIWebViewDelegate, WKNavigationDelegate, SFSafariViewControllerDelegate, URLSessionDownloadDelegate {
    
    // MARK: after ios 8, WKWebView is always needed
    lazy var webView = WKWebView()
    private weak var timer: Timer?
    var pageStatus: WebViewStatus?
    private var startUrl = "http://app003.ftmailbox.com/iphone-2014.html?isInSWIFT&iOSShareWechat&gShowStatusBar"
    private let iPadStartUrl = "http://app005.ftmailbox.com/ipad-2014.html?isInSWIFT&iOSShareWechat&gShowStatusBar"
    // MARK: if the app use a native launch ad, suppress the pop up one
    private let useNativeLaunchAd = "useNativeLaunchAd"
    private var maxAdTimeAfterLaunch = 6.0
    private var maxAdTimeAfterWebRequest = 3.0
    private let fadeOutDuration = 0.5
    private let adSchedule = AdSchedule()
    private lazy var player: AVPlayer? = {return nil} ()
    private lazy var token: Any? = {return nil} ()
    private lazy var overlayView: UIView? = UIView()
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
        
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let statusType = IJReachability().connectedToNetworkOfType()
        if statusType == .wiFi {
            if #available(iOS 10.0, *) {
                config.mediaTypesRequiringUserActionForPlayback = .init(rawValue: 0)
            } else {
                config.mediaPlaybackRequiresUserAction = false
            }
        }
        webView = WKWebView(frame: self.view.bounds, configuration: config)
        //let webView = WKWebView(frame: self.topView.bounds, configuration: config)
        
        self.view = self.webView
        webView.scrollView.bounces = false
        webView.configuration.allowsInlineMediaPlayback = true
        webView.navigationDelegate = self
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
        
        //TextToSpeech()
    }
    /**
     Once view is loaded:
     - Load html into the webview.
     - Wait for several seconds before removing the overlay to reveal the web view at the same time.
     - Check for new update of the ad schedule.
     **/
    override func viewDidLoad() {
        super.viewDidLoad()
        pageStatus = .viewLoaded
        loadFromLocal()
        pageStatus = .webViewLoading
        displayWebviewAfterSeconds(maxAdTimeAfterLaunch)
        // MARK: download the latest ad schedule from the internet
        if (adType != "none") {
            adSchedule.updateAdSchedule()
        }
        // MARK: load in-app purchase products information
        loadProducts()
        // MARK: listen to in-app purchase transaction notification
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
    }
    
    /**
     viewWillAppear happens when:
     - Starting the app
     - Going back from a popover segue, like the WKWebPageController
     */
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
    
    // MARK: On mobile phone, lock the screen to portrait only
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
    
    
    // MARK: if there's no ad to load
    func normalOverlayView() {
        if let overlayViewNormal = overlayView {
            maxAdTimeAfterLaunch = 3.0
            maxAdTimeAfterWebRequest = 2.0
            overlayViewNormal.backgroundColor = UIColor(netHex:0x002F5F)
            overlayViewNormal.frame = self.view.bounds
            self.view.addSubview(overlayViewNormal)
            overlayViewNormal.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: overlayViewNormal, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlayViewNormal, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlayViewNormal, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: overlayViewNormal, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
            
            // MARK: the icon image
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
            
            // MARK: the lable at the bottom
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
    
    
    // MARK: if there's a full screen screen ad to show
    private func adOverlayView() {
        if self.adType == "none" {
            maxAdTimeAfterLaunch = 1.0
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
            playVideo()
        } else {
            normalOverlayView()
            return
        }
        // MARK: button to close the full screen ad
        addCloseButton()
        // MARK: set custom background
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
    
    private func playVideo() {
        let path = adSchedule.videoFilePath
        let pathUrl = URL(fileURLWithPath: path)
        maxAdTimeAfterLaunch = 60.0
        maxAdTimeAfterWebRequest = 57.0
        player = AVPlayer(url: pathUrl)
        let playerController = AVPlayerViewController()
        
        let asset = AVURLAsset(url: URL(fileURLWithPath: path))
        let videoDuration = asset.duration
        
        // MARK: video view must be added to the self.view, not a subview, otherwise Xcode complains about constraints
        playerController.player = player
        
        // MARK: the following line seems to be useless
        self.addChildViewController(playerController)
        playerController.showsPlaybackControls = false
        
        //player?.setMediaSelectionCriteria(criteria: AVPlayerMediaSelectionCriteria?, forMediaCharacteristic: <#T##String#>)
        player?.isMuted = true
        player?.play()
        
        self.view.addSubview(playerController.view)
        playerController.view.tag = 111
        playerController.view.frame = self.view.frame
        
        // MARK: label for time at the left bottom
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
        
        var timeRecorded = [0]
        var deviceType = "iPhone"
        if UIDevice.current.userInterfaceIdiom == .pad {
            deviceType = "iPad"
        }
        
        let lastcomponent = pathUrl.lastPathComponent
        token = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1,10), queue: DispatchQueue.main, using: { [weak self] timeInterval in
            let timeLeft = CMTimeGetSeconds(videoDuration-timeInterval)
            if let theLabel = self?.view.viewWithTag(112) as? UILabel {
                theLabel.text = String(format:"%.0f", timeLeft)
            }
            // MARK: record play time as events
            let timeSpent = Int(CMTimeGetSeconds(timeInterval))
            let timeRecordStep = 5
            if !timeRecorded.contains(timeSpent) && timeSpent % timeRecordStep == 0 {
                print(timeSpent)
                let jsCode = "try{ga('send','event', '\(deviceType) Launch Video Play', '\(lastcomponent)', '\(timeSpent)', {'nonInteraction':1});}catch(ignore){}"
                self?.webView.evaluateJavaScript(jsCode) { (result, error) in
                }
                timeRecorded.append(timeSpent)
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
            // MARK: this will make the video play sound even when iPhone is muted
            player?.isMuted = false
            sender.isSelected = true
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            } catch let error {
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
    
    
    // MARK: report ad impressions
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
    
    // MARK: this should be public
    func clickAd() {
        openInView(adSchedule.adLink)
    }
    
    // MARK: Load HTML String from Bundle to start the App
    private func loadFromLocal() {
        if adSchedule.adType != "none" {
            startUrl = "\(startUrl)&\(useNativeLaunchAd)"
        }
        print ("start url is \(startUrl)")
        if let templatepath = Bundle.main.path(forResource: "index", ofType: "html") {
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
    
    // MARK: this is public because AppDelegate is going to use it
    func checkBlankPage() {
        self.webView.evaluateJavaScript("document.querySelector('body').innerHTML") { (result, error) in
            if error != nil {
                self.loadFromLocal()
            } else {
                self.checkConnectionType()
            }
        }
    }
    
    // MARK: User tap on a remote notification. This should be public.
    func openNotification(_ action: String?, id: String?, title: String?) {
        if let action = action, let id = id {
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
                self.webView.evaluateJavaScript(jsCode) { (result, error) in
                }
                
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
        nextTimer.tolerance = 1
        timer = nextTimer
    }
    
    
    // MARK: this should be public
    func displayWebView() {
        if pageStatus != .webViewDisplayed {
            if let overlay = overlayView {
                for subUIView in overlay.subviews {
                    subUIView.removeFromSuperview()
                }
                UIView.animate(
                    withDuration: fadeOutDuration,
                    animations: {
                        overlay.alpha = 0.0
                },
                    completion: {(value: Bool) in
                        overlay.removeFromSuperview()
                        self.overlayView = nil
                }
                )
            }
            if let videoView = self.view.viewWithTag(111) {
                UIView.animate(
                    withDuration: fadeOutDuration,
                    animations: {
                        videoView.alpha = 0.0
                }, completion: { (value: Bool) in
                    videoView.removeFromSuperview()
                })
            }
            pageStatus = .webViewDisplayed
            // MARK: trigger prefersStatusBarHidden
            setNeedsStatusBarAppearanceUpdate()
            getUserId()
            player?.pause()
            if let t = token {
                player?.removeTimeObserver(t)
                token = nil
            }
            // MARK: send impression ping
            reportImpressionToWeb(impressions: adSchedule.impression)
            // MARK: show social login buttons
            showSocialLoginButtons()
            player = nil
        }
    }
    
    private func showSocialLoginButtons() {
        var jsCode = ""
        for socialPlatform in supportedSocialPlatforms {
            if socialPlatform != "" {
                jsCode += "var all\(socialPlatform) = document.querySelectorAll('.social-login-\(socialPlatform)');for (var i=0; i<all\(socialPlatform).length; i++) {all\(socialPlatform)[i].style.display = 'block';}"
            }
        }
        if jsCode != "" {
            jsCode = "try{\(jsCode)}catch(ignore){}"
            print (jsCode)
            webView.evaluateJavaScript(jsCode) { (result, error) in
                if error != nil {
                    print (error ?? "error is nil")
                } else {
                    print ("no error")
                }
            }
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
            } else if url.scheme == "buy" {
                buyProduct(urlString: urlString)
                decisionHandler(.cancel)
            } else if url.scheme == "restorepurchases" {
                restorePurchases()
                decisionHandler(.cancel)
            } else if url.scheme == "downloadproduct" {
                //buyProduct(urlString: urlString)
                downloadProductFromWeb(urlString)
                decisionHandler(.cancel)
            } else if url.scheme == "canceldownload" {
                cancelDownload(urlString)
                decisionHandler(.cancel)
            } else if url.scheme == "pausedownload" {
                pauseDownload(urlString)
                decisionHandler(.cancel)
            } else if url.scheme == "resumedownload" {
                resumeDownload(urlString)
                decisionHandler(.cancel)
            } else if url.scheme == "removedownload" {
                //buyProduct(urlString: urlString)
                removeDownload(urlString)
                decisionHandler(.cancel)
            } else if url.scheme == "readbook" {
                readBook(urlString: urlString)
                decisionHandler(.cancel)
            } else if url.scheme == "try" {
                tryBook(urlString: urlString)
                decisionHandler(.cancel)
            } else if url.scheme == "iap" {
                print("iap scheme is not in use any more")
                decisionHandler(.cancel)
            } else if url.scheme == "iosaction" {
                turnOnActionSheet(urlString)
                decisionHandler(.cancel)
            } else if url.scheme == "weixinlogin" {
                // MARK: launch weixin login and switch to wechat
                let req = SendAuthReq()
                req.scope = "snsapi_userinfo"
                req.state = "weliveinfinancialtimes"
                WXApi.send(req)
                decisionHandler(.cancel)
                // MARK: all new url schemes should be above here, otherwise the app will crash after clicking
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
                let activityVC: UIActivityViewController
                if WXApi.isWXAppSupport() == true {
                    activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [wcActivity, wcCircle, wcFav, openInSafari])
                } else {
                    activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [openInSafari])
                }
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
            // MARK: use the safariview for iOS 9
            if urlString.range(of: "http://www.ftchinese.com") == nil {
                // MARK: when opening an outside url which we have no control over
                if let url = URL(string:urlString) {
                    if let urlScheme = url.scheme?.lowercased() {
                        if ["http", "https"].contains(urlScheme) {
                            // MARK: Can open with SFSafariViewController
                            let webVC = SFSafariViewController(url: url)
                            webVC.delegate = self
                            self.present(webVC, animated: true, completion: nil)
                        } else {
                            // MARK: When Scheme is not supported or no scheme is given, use openURL
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            } else {
                // MARK: when opening a url on a page that we can control
                self.performSegue(withIdentifier: "WKWebPageSegue", sender: nil)
            }
        } else {
            // MARK: Fallback on earlier versions
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
            //controller.dismissViewControllerAnimated(true, completion: nil)
        } else {
            //print("Page Load Successful!")
        }
    }
    
    
    @available(iOS 9.0, *)
    func safariViewController(_ controler: SFSafariViewController, activityItemsFor activityItemsForURL: URL, title: String?) -> [UIActivity] {
        webPageUrl = activityItemsForURL.absoluteString
        // MARK: the title for the above page, which is not utf-8, cannot be captured
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
    
    // MARK: this should be public
    func getUserId() {
        var userId = ""
        self.webView.evaluateJavaScript("getCookie('USER_ID')") { (result, error) in
            if error != nil {
                print ("error running js")
                //self.loadFromLocal()
            } else {
                //get the user id
                let resultString = result as? String
                if let r = resultString {
                    userId = r
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
    
    
    
    
    // MARK: - in-app purchase start
    
    // TODO: - There should be functions to clear useless file, for example, by removing trial files when user downloaded the paid for files
    
    private var products = [SKProduct]()
    
    private func loadProducts() {
        products = []
        FTCProducts.store.requestProducts{success, products in
            if success {
                if let products = products {
                    self.products = products
                    self.productToJSCode(self.products, jsVariableName: "displayProductsOnHome", jsVariableType: "function")
                    self.productToJSCode(self.products, jsVariableName: "iapProducts", jsVariableType: "object")
                }
            }
        }
    }
    
    private func buyProduct(urlString: String) {
        print (urlString)
        let productId = urlString.replacingOccurrences(of: "buy://", with: "")
        /*
         var product: SKProduct?
         for p in products {
         if p.productIdentifier == productId {
         product = p
         print ("product id matched: \(p.productIdentifier)")
         break
         }
         }
         */
        let product = findSKProductByID(productId)
        if let product = product {
            FTCProducts.store.buyProduct(product)
            let jsCode = "iapActions('\(productId)', 'pending');"
            self.webView.evaluateJavaScript(jsCode) { (result, error) in
            }
        }
    }
    
    private func restorePurchases() {
        print ("restore purchase button clicked")
        FTCProducts.store.restorePurchases()
    }
    
    private func findSKProductByID(_ productID: String) -> SKProduct? {
        var product: SKProduct?
        for p in products {
            if p.productIdentifier == productID {
                product = p
                print ("product id matched: \(p.productIdentifier)")
                break
            }
        }
        return product
    }
    
    private func findProductInfoById(_ productID: String) -> [String: String]? {
        var product: [String: String]?
        for p in FTCProducts.allProducts {
            if p["id"] == productID {
                product = p
                break
            }
        }
        return product
    }
    
    
    
    private func readBook(urlString: String) {
        print ("read book: \(urlString)")
        let productIdentifier = urlString.replacingOccurrences(of: "readbook://", with: "")
            .replacingOccurrences(of: "?isad=1", with: "")
        // MARK: - check if the file exists locally
        
        if let fileLocation = checkFilePath(fileUrl: productIdentifier) {
            print (fileLocation)
            let config = FolioReaderConfig()
            config.scrollDirection = .horizontal
            config.allowSharing = false
            config.tintColor = UIColor(netHex: 0x9E2F50)
            config.menuBackgroundColor = UIColor(netHex: 0xFFF1E0)
            config.enableTTS = false
            FolioReader.presentReader(parentViewController: self, withEpubPath: fileLocation, andConfig: config)
        } else {
            print ("file not found: download it")
            let alert = UIAlertController(title: "文件还没有下载，要现在下载吗？", message: "下载到本地可以打开并阅读", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "立即下载",
                                          style: UIAlertActionStyle.default,
                                          handler: {_ in self.downloadProduct(productIdentifier)}
            ))
            alert.addAction(UIAlertAction(title: "以后再说", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        //self.performSegue(withIdentifier: "ReadBookSegue", sender: nil)
    }
    
    private func tryBook(urlString: String) {
        print ("try book: \(urlString)")
        let productIdentifier = urlString.replacingOccurrences(of: "try://", with: "")
            .replacingOccurrences(of: "?isad=1", with: "")
        
        let tryBookFileName = "try." + productIdentifier
        // MARK: - check if the file exists locally
        
        if let fileLocation = checkFilePath(fileUrl: tryBookFileName) {
            print (fileLocation)
            let config = FolioReaderConfig()
            config.scrollDirection = .horizontal
            config.allowSharing = false
            config.tintColor = UIColor(netHex: 0x9E2F50)
            config.menuBackgroundColor = UIColor(netHex: 0xFFF1E0)
            config.enableTTS = false
            FolioReader.presentReader(parentViewController: self, withEpubPath: fileLocation, andConfig: config)
        } else {
            print ("file not found: download it")
            let alert = UIAlertController(title: "文件还没有下载，要现在下载吗？", message: "下载到本地可以打开并阅读", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "立即下载",
                                          style: UIAlertActionStyle.default,
                                          handler: {_ in self.downloadProductForTrying(productIdentifier)}
            ))
            alert.addAction(UIAlertAction(title: "以后再说", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        //self.performSegue(withIdentifier: "ReadBookSegue", sender: nil)
    }
    
    // MARK: - The Download Operation Queue
    lazy var downloadQueue:OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    // MARK: keep a reference of all the Download Tasks
    var downloadTasks = [String: URLSessionDownloadTask]()
    
    private func downloadProductFromWeb(_ urlString: String) {
        let productId = urlString.replacingOccurrences(of: "downloadproduct://", with: "")
            .replacingOccurrences(of: "?isad=1", with: "")
        downloadProduct(productId)
    }
    
    private func downloadProduct(_ productID: String) {
        print ("Download this product by id: \(productID), you can continue to download and/or display the information to user")
        if let fileDownloadUrl = findProductInfoById(productID)?["download"] {
            print ("download this file: \(fileDownloadUrl)")
            var jsCode = ""
            if checkFilePath(fileUrl: productID) == nil {
                // MARK: - Download the file through the internet
                print ("The file does not exist. Download from \(fileDownloadUrl)")
                let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: productID)
                let backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: downloadQueue)
                if let url = URL(string: fileDownloadUrl) {
                    let request = URLRequest(url: url)
                    downloadTasks[productID] = backgroundSession.downloadTask(with: request)
                    downloadTasks[productID]?.resume()
                    jsCode = "iapActions('\(productID)', 'downloading')"
                } else {
                    jsCode = "iapActions('\(productID)', 'pendingdownload')"
                }
            } else {
                // TODO: - Update interface to change the button action into read
                print ("The file already exists. No need to download. Update Interface")
                jsCode = "iapActions('\(productID)', 'success')"
            }
            self.webView.evaluateJavaScript(jsCode) { (result, error) in
            }
        }
    }
    
    private func downloadProductForTrying(_ productID: String) {
        print ("Download this product for trying by id: \(productID), you can continue to download and/or display the information to user")
        if let fileDownloadUrl = findProductInfoById(productID)?["downloadfortry"] {
            print ("download this file: \(fileDownloadUrl)")
            var jsCode = ""
            let productIdForTrying = "try." + productID
            if checkFilePath(fileUrl: productIdForTrying) == nil {
                // MARK: - Download the file through the internet
                print ("The file does not exist. Download from \(fileDownloadUrl)")
                let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: productIdForTrying)
                let backgroundSession = URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: downloadQueue)
                if let url = URL(string: fileDownloadUrl) {
                    let request = URLRequest(url: url)
                    downloadTasks[productIdForTrying] = backgroundSession.downloadTask(with: request)
                    downloadTasks[productIdForTrying]?.resume()
                    jsCode = "iapActions('\(productID)', 'pending')"
                } else {
                    jsCode = "iapActions('\(productID)', 'fail')"
                }
            } else {
                // TODO: - Update interface to change the button action into read
                print ("The file already exists. No need to download. Update Interface")
                jsCode = "iapActions('\(productID)', 'fail')"
            }
            self.webView.evaluateJavaScript(jsCode) { (result, error) in
            }
        }
    }
    
    private func cancelDownload(_ urlString: String) {
        let productId = urlString.replacingOccurrences(of: "canceldownload://", with: "")
            .replacingOccurrences(of: "?isad=1", with: "")
        downloadTasks[productId]?.cancel()
        let jsCode = "iapActions('\(productId)', 'pendingdownload')"
        self.webView.evaluateJavaScript(jsCode) { (result, error) in
        }
    }
    
    private func pauseDownload(_ urlString: String) {
        let productId = urlString.replacingOccurrences(of: "pausedownload://", with: "")
            .replacingOccurrences(of: "?isad=1", with: "")
        downloadTasks[productId]?.suspend()
        let jsCode = "updateDownloadPauseButton('\(productId)', 'pause')"
        self.webView.evaluateJavaScript(jsCode) { (result, error) in
        }
    }
    
    private func resumeDownload(_ urlString: String) {
        let productId = urlString.replacingOccurrences(of: "resumedownload://", with: "")
            .replacingOccurrences(of: "?isad=1", with: "")
        downloadTasks[productId]?.resume()
        let jsCode = "updateDownloadPauseButton('\(productId)', 'resume')"
        self.webView.evaluateJavaScript(jsCode) { (result, error) in
        }
    }
    
    private func removeDownload(_ urlString: String) {
        let productId = urlString.replacingOccurrences(of: "removedownload://", with: "")
            .replacingOccurrences(of: "?isad=1", with: "")
        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }
        let filePath = "\(dirPath)/\(productId)"
        do {
            try fileManager.removeItem(atPath: filePath)
            print ("removed the file at \(filePath)")
            let jsCode = "iapActions('\(productId)', 'pendingdownload')"
            self.webView.evaluateJavaScript(jsCode) { (result, error) in
            }
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    
    
    
    
    
    //MARK: URLSessionDownloadDelegate
    // 1
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        if let productId = session.configuration.identifier {
            let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentDirectoryPath:String = path[0]
            let fileManager = FileManager()
            let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/\(productId)"))
            
            print ("\(productId) file downloaded to: \(location.absoluteURL)")
            if fileManager.fileExists(atPath: destinationURLForFile.path){
                //showFileWithPath(path: destinationURLForFile.path)
                print ("the file exists, you can open it. ")
            } else {
                do {
                    try fileManager.moveItem(at: location, to: destinationURLForFile)
                    // show file
                    // showFileWithPath(path: destinationURLForFile.path)
                    print ("file moved. you can open it")
                    
                    if productId.hasPrefix("try") {
                        // MARK: - This is a trial file, open it immediately
                        print ("open the try book")
                        let config = FolioReaderConfig()
                        config.scrollDirection = .horizontal
                        config.allowSharing = false
                        config.tintColor = UIColor(netHex: 0x9E2F50)
                        config.menuBackgroundColor = UIColor(netHex: 0xFFF1E0)
                        config.enableTTS = false
                        let jsCode = "iapActions('\(productId.replacingOccurrences(of: "try.", with: ""))', 'fail');"
                        self.webView.evaluateJavaScript(jsCode) { (result, error) in
                        }
                        if let fileLocation = checkFilePath(fileUrl: productId) {
                            DispatchQueue.main.async {
                                FolioReader.presentReader(parentViewController: self, withEpubPath: fileLocation, andConfig: config)
                            }
                        }
                        return
                    }
                }catch{
                    print("An error occurred while moving file to destination url")
                }
            }
            let jsCode = "iapActions('\(productId)', 'success');"
            self.webView.evaluateJavaScript(jsCode) { (result, error) in
            }
        }
    }
    // 2
    // MARK: keep a reference of all the Download Progress
    var downloadProgresses = [String: String]()
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
        // MARK: - evaluateJavaScript is very energy consuming, do this only several times
        if let productId = session.configuration.identifier {
            let totalMBsWritten = String(format: "%.1f", Float(totalBytesWritten)/1000000)
            let percentageNumber = 100 * Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            if totalMBsWritten == "0.0" {
                downloadProgresses[productId] = "0.0"
            }
            if downloadProgresses[productId] != totalMBsWritten {
                downloadProgresses[productId] = totalMBsWritten
                let totalMBsExpectedToWrite = String(format: "%.1f", Float(totalBytesExpectedToWrite)/1000000)
                let jsCode = "updateDownloadProgress('\(productId)', '\(percentageNumber)%', '\(totalMBsWritten)M / \(totalMBsExpectedToWrite)M')"
                self.webView.evaluateJavaScript(jsCode) { (result, error) in
                }
                //print (totalMBsWritten)
            }
        }
    }
    
    //MARK: URLSessionTaskDelegate
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        // downloadTask = nil
        // progressView.setProgress(0.0, animated: true)
        if (error != nil) {
            print(error!.localizedDescription)
            if let productId = session.configuration.identifier {
                let jsCode = "iapActions('\(productId)', 'pendingdownload');"
                self.webView.evaluateJavaScript(jsCode) { (result, error) in
                }
            }
        }else{
            // MARK: - the interface should have been updated through the didFinishDownloadingTo func
            print("The task finished transferring data successfully")
        }
    }
    
    
    
    
    private func productToJSCode (_ products: [SKProduct], jsVariableName: String, jsVariableType: String){
        var productsString = ""
        for product in products {
            print("product from oliver: ")
            print("title: \(product.localizedTitle); id: \(product.productIdentifier); ")
            let priceFormatter: NumberFormatter = {
                let formatter = NumberFormatter()
                formatter.formatterBehavior = .behavior10_4
                formatter.numberStyle = .currency
                formatter.locale = product.priceLocale
                return formatter
            }()
            let productPrice = priceFormatter.string(from: product.price) ?? ""
            var productImage = ""
            var productTeaser = ""
            var productGroup = ""
            var productGroupTitle = ""
            let isPurchased = FTCProducts.store.isProductPurchased(product.productIdentifier)
            for oneProduct in FTCProducts.allProducts {
                if let bookId = oneProduct["id"] {
                    if bookId == product.productIdentifier {
                        productImage = oneProduct["image"] ?? ""
                        productTeaser = oneProduct["teaser"] ?? ""
                        productGroup = oneProduct["group"] ?? ""
                        productGroupTitle = oneProduct["groupTitle"] ?? ""
                        break
                    }
                }
            }
            let isDownloaded = { () -> Bool in
                if checkFilePath(fileUrl: product.productIdentifier) == nil {
                    return false
                } else {
                    return true
                }
            }()
            let productString = "{title: '\(product.localizedTitle)',description: '\(product.localizedDescription)',price: '\(productPrice)',id: '\(product.productIdentifier)',image: '\(productImage)', teaser: '\(productTeaser)', isPurchased: \(isPurchased), isDownloaded: \(isDownloaded), group: '\(productGroup)', groupTitle: '\(productGroupTitle)'}"
            productsString += ",\(productString)"
        }
        switch jsVariableType{
        case "function":
            productsString = "\(jsVariableName)([\(productsString)]);"
        case "object":
            productsString = "window.\(jsVariableName) = [\(productsString)];"
        default:
            productsString = "window.\(jsVariableName) = [\(productsString)];"
        }
        productsString = productsString
            .replacingOccurrences(of: "[,", with: "[")
            .replacingOccurrences(of: "\n", with: "<br>", options: .regularExpression)
        
        print (productsString)
        
        self.webView.evaluateJavaScript(productsString) { (result, error) in
            if error == nil {
                //                print ("result: ")
                //                print (result)
            }
        }
    }
    
    // MARK: This should be public
    public func handlePurchaseNotification(_ notification: Notification) {
        var jsCode = ""
        if let productID = notification.object as? String {
            // MARK: when user buys or restores a product, we should display relevant information
            for (_, product) in products.enumerated() {
                guard product.productIdentifier == productID else { continue }
                jsCode = "iapActions('\(productID)', 'downloading')"
                self.webView.evaluateJavaScript(jsCode) { (result, error) in
                }
                downloadProduct(productID)
            }
        } else if let errorObject = notification.object as? [String : String?] {
            let alert = UIAlertController(title: "交易失败，您的钱还在口袋里", message: errorObject["error"] ?? "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "我知道了", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            if let productId = errorObject["id"] {
                jsCode = "iapActions('\(productId ?? "")', 'fail')"
                print (jsCode)
                self.webView.evaluateJavaScript(jsCode) { (result, error) in
                }
            }
        } else if notification.object == nil {
            // MARK: When the transaction fail without any error message (NSError)
            let alert = UIAlertController(title: "交易失败，您的钱还在口袋里", message: "未知错误", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "我知道了", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            jsCode = "iapActions('', 'fail')"
            self.webView.evaluateJavaScript(jsCode) { (result, error) in
            }
        }
    }
    
    
    
    // MARK: - in-app purchase end
    
    
    // Text to Speech
    func TextToSpeech() {
        let mySpeechSynthesizer:AVSpeechSynthesizer = AVSpeechSynthesizer()
        let myString:String = "人民币无疑是当前宏观经济政策制定者和全球金融市场最关注的问题之一。<br>“8·11”汇改全球市场震动，一周年过去了，人民币的故事并没有结束。如何评价这一事件？中国对世界经济影响有何变化？人民币在全球市场上究竟占据何种地位？与美元的“难舍难分”又会带来什么影响？<br>随着人民币正式加入SDR在即，经济放缓下的贬值压力也随之加大。人民币会继续贬值吗？想要打破贬值预期，到底应该怎么做？"
        let mySpeechUtterance:AVSpeechUtterance = AVSpeechUtterance(string:myString)
        mySpeechUtterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        //mySpeechUtterance.rate = 1.2
        mySpeechSynthesizer.speak(mySpeechUtterance)
    }
    
}

