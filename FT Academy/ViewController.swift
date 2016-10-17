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
    
    var uiWebView: UIWebView!
    @available(iOS 8.0, *)
    lazy var webView: WKWebView? = { return nil }()
    weak var timer: Timer?
    var pageStatus: WebViewStatus?
    var startUrl = "http://app003.ftmailbox.com/iphone-2014.html?isInSWIFT&iOSShareWechat&gShowStatusBar"
    //var startUrl = "https://backyard.ftchinese.com/"
    //var startUrl = "http://192.168.253.25:9000/?isInSWIFT&iOSShareWechat&gShowStatusBar"
    let iPadStartUrl = "http://app005.ftmailbox.com/ipad-2014.html?isInSWIFT&iOSShareWechat&gShowStatusBar"
    var maxAdTimeAfterLaunch = 6.0
    var maxAdTimeAfterWebRequest = 3.0
    lazy var overlayView: UIView? = UIView()
    var adType = "none"
    let adLink = "http://www.rolex.com"
    let lauchAdSchedule = "http://m.ftchinese.com/test.json?3"
    let videoFile = "P38938019__AT_video_gr5.mp4"
    let imageFile = "rolex.jpg"
    let htmlFile = "yyk001.html"
    let htmlBaseUrl = "http://www3.ftchinese.com/adv/yyk/"
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    
    deinit {
        //print("main view is being deinitialized")
    }
    
    override func loadView() {
        super.loadView()
        pageStatus = .viewToLoad
        if UIDevice.current.userInterfaceIdiom == .pad {
            startUrl = iPadStartUrl
        }
        
        if #available(iOS 8.0, *) {
            //var webView: WKWebView!
            self.webView = WKWebView()
            self.view = self.webView
            self.webView!.navigationDelegate = self
            NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "statusBarSelected"), object: nil, queue: nil) { event in
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
        

        //adOverlayView()
        normalOverlayView()
    }
    
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageStatus = .viewLoaded
        loadFromLocal()
        pageStatus = .webViewLoading
        resetTimer(maxAdTimeAfterLaunch)
        updateAdSchedule()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        if pageStatus == .webViewDisplayed || pageStatus == .webViewWarned {
            //Deal with white screen when back from other scene
            checkBlankPage()
        }
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
        overlayView!.backgroundColor = UIColor(netHex:0x002F5F)
        overlayView!.frame = self.view.bounds
        self.view.addSubview(overlayView!)
        overlayView!.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: overlayView!, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: overlayView!, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: overlayView!, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: overlayView!, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
        
        let imageName = "FTC-start"
        let image = UIImage(named: imageName)
        var imageView: UIImageView?
        imageView = UIImageView(image: image!)
        imageView!.frame = CGRect(x: 0, y: 0, width: 266, height: 210)
        imageView!.contentMode = .scaleAspectFit
        self.overlayView!.addSubview(imageView!)
        imageView!.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: imageView!, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: imageView!, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1/3, constant: 1))
        view.addConstraint(NSLayoutConstraint(item: imageView!, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 266))
        view.addConstraint(NSLayoutConstraint(item: imageView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 210))
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 441, height: 21))
        label.center = CGPoint(x: 160, y: 284)
        label.textAlignment = NSTextAlignment.center
        label.text = "英国《金融时报》中文网"
        label.textColor = UIColor.white
        self.overlayView!.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -20))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 441))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 21))
    }
    
    
    // if there's ad image to load
    func adOverlayView() {
        parseSchedule()
        
        
        if adType == "page" {
            addOverlayView()
            showHTMLAd()
        } else if adType == "image" {
            addOverlayView()
            showImage()
        } else if adType == "video" {
            do {
                try playVideo()
            } catch AppError.invalidResource(let name, let type) {
                debugPrint("Could not find resource \(name).\(type)")
            } catch {
                debugPrint("Generic error")
            }
        }
        
        //跳过广告的按钮
        addCloseButton()
    }
    
    func addOverlayView() {
        overlayView!.backgroundColor = UIColor(netHex:0x000000)
        overlayView!.frame = self.view.bounds
        self.view.addSubview(overlayView!)
        overlayView!.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: overlayView!, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: overlayView!, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: overlayView!, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: overlayView!, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0))
    }
    
    func addCloseButton() {
        let button: UIButton? = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        button!.setTitle("跳过广告", for: UIControlState())
        if adType == "video" {
            self.view.viewWithTag(111)!.addSubview(button!)
        } else {
            self.overlayView!.addSubview(button!)
        }
        
        button!.translatesAutoresizingMaskIntoConstraints = false
        button!.addTarget(self, action: #selector(ViewController.displayWebView), for: .touchUpInside)
        
        view.addConstraint(NSLayoutConstraint(item: button!, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: button!, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: button!, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 100))
        view.addConstraint(NSLayoutConstraint(item: button!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 44))
    }
    
    func showImage() {
        let filename: NSString = imageFile as NSString
        let pathExtention = filename.pathExtension
        let pathPrefix = filename.deletingPathExtension
        let templatepath = Bundle.main.path(forResource: pathPrefix, ofType: pathExtention)!
        let image: UIImage? = UIImage(contentsOfFile: templatepath)
        let imageView: UIImageView? = UIImageView(image: image!)
        imageView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        imageView?.contentMode = .scaleAspectFit
        self.overlayView!.addSubview(imageView!)
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: imageView!, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: screenWidth))
        view.addConstraint(NSLayoutConstraint(item: imageView!, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: screenHeight))
        imageView?.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.clickAd))
        imageView!.addGestureRecognizer(tapRecognizer)
    }
    
    func showHTMLAd() {
        if #available(iOS 8.0, *) {
            let filename: NSString = htmlFile as NSString
            let pathExtention = filename.pathExtension
            let pathPrefix = filename.deletingPathExtension
            let adPageView = WKWebView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight - 44))
            let templatepath = Bundle.main.path(forResource: pathPrefix, ofType: pathExtention)!
            let base = URL(string: htmlBaseUrl)
            let s = try! NSString(contentsOfFile:templatepath, encoding:String.Encoding.utf8.rawValue)
            adPageView.loadHTMLString(s as String, baseURL:base)
            overlayView!.addSubview(adPageView)
            
            if adLink != "" {
                let adPageLinkOverlay = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight - 44))
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.clickAd))
                overlayView!.addSubview(adPageLinkOverlay)
                adPageLinkOverlay.addGestureRecognizer(tapRecognizer)
            }
            
        } else {
            adType = "image"
            showImage()
        }
    }
    
    func playVideo() throws {
        let filename: NSString = videoFile as NSString
        let pathExtention = filename.pathExtension
        let pathPrefix = filename.deletingPathExtension
        
        guard let path = Bundle.main.path(forResource: pathPrefix, ofType:pathExtention) else {
            throw AppError.invalidResource(pathPrefix, pathExtention)
        }
        
        if #available(iOS 8.0, *) {
            maxAdTimeAfterLaunch = 525.0
            maxAdTimeAfterWebRequest = 523.0
            let player = AVPlayer(url: URL(fileURLWithPath: path))
            let playerController = AVPlayerViewController()
            
            // this code doesn't make Xcode complain about constraints
            // video view must be added to the self.view, not a subview
            playerController.player = player
            // this code seems to be useless and causes memory leak when video is closed
            // self.addChildViewController(playerController)
            playerController.showsPlaybackControls = false
            //player.muted = true
            player.play()
            self.view.addSubview(playerController.view)
            playerController.view.tag = 111
            playerController.view.frame = self.view.frame
            player.play()
            NotificationCenter.default.addObserver(self, selector: #selector(ViewController.displayWebView), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            if adLink != "" {
                let adPageLinkOverlay = UIView(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight - 44))
                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.clickAd))
                playerController.view.addSubview(adPageLinkOverlay)
                adPageLinkOverlay.addGestureRecognizer(tapRecognizer)
            }
        } else {
            adType = "image"
            showImage()
        }
    }
    
    
    func clickAd() {
        openInView(adLink)
    }
    func updateAdSchedule() {
        let urlLauchAdSchedule = URL(string: lauchAdSchedule)
        grabFileFromWeb(urlLauchAdSchedule!)
    }
    func grabFileFromWeb(_ url: URL) {
        //print("lastPathComponent: " + (url.lastPathComponent ?? ""))
        //weChatShareIcon = UIImage(named: "ftcicon.jpg")
        getDataFromUrl(url) { (data, response, error)  in
            DispatchQueue.main.async { () -> Void in
                guard let data = data , error == nil else { return }
                //print(response?.suggestedFilename ?? "")
                //print(data)
                self.saveFile(data, filename: "schedule.json")
                //print(data)
                //print("Download Finished")
                //weChatShareIcon = UIImage(data: data)
            }
        }
    }
    
    func saveFile(_ data: Data, filename: String) {
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent(filename)
        let fileManager = FileManager.default
        let created = fileManager.createFile(atPath: jsonFilePath.absoluteString, contents: nil, attributes: nil)
        if created {
            //print("File created ")
        } else {
            //print("Couldn't create file for some reason")
        }
        // Write that JSON to the file created earlier
        do {
            let file = try FileHandle(forWritingTo: jsonFilePath)
            file.write(data)
            //print("JSON data was written to the file successfully!")
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
    }
    
    //Load HTML String from Bundle to start the App
    func loadFromLocal() {
        //        let url = NSURL(string:startUrl)
        //        let req = NSURLRequest(URL:url!)
        let templatepath = Bundle.main.path(forResource: "index", ofType: "html")!
        //let base = NSURL.fileURLWithPath(templatepath)!
        let base = URL(string: startUrl)
        let s = try! NSString(contentsOfFile:templatepath, encoding:String.Encoding.utf8.rawValue)
        //let ss = "<content>"
        
        if #available(iOS 8.0, *) {
            //            let webView = self.view as! WKWebView
            //            webView.loadRequest(req)
            self.webView!.loadHTMLString(s as String, baseURL:base)
        } else {
            //uiWebView?.loadRequest(req)
            uiWebView.loadHTMLString(s as String, baseURL: base)
        }
        checkConnectionType()
    }
    
    func parseSchedule() {
        let scheduleDataFinal: Data
        let jsonFileTime: Int
        let jsonFileTimeBundle: Int
        let scheduleData = readFile("schedule.json", fileLocation: "download")
        let scheduleDataBundle = readFile("schedule.json", fileLocation: "bundle")
        if scheduleData != nil {
            jsonFileTime = getJSONFileTime(scheduleData!)
        } else {
            jsonFileTime = 0
        }
        if scheduleDataBundle != nil {
            jsonFileTimeBundle = getJSONFileTime(scheduleDataBundle!)
        } else {
            jsonFileTimeBundle = 0
        }
        // compare two versions of schedule.json file
        // use whichever is latest
        if jsonFileTime > jsonFileTimeBundle {
            scheduleDataFinal = scheduleData!
            print("get schedule from download")
        } else {
            scheduleDataFinal = scheduleDataBundle!
            print("get schedule from bundle")
        }
        

        do {
            let JSON = try JSONSerialization.jsonObject(with: scheduleDataFinal, options:JSONSerialization.ReadingOptions(rawValue: 0))
            guard let JSONDictionary: NSDictionary = JSON as? NSDictionary else {
                print("Not a Dictionary")
                return
            }
            guard let creatives = JSONDictionary["creatives"] as? NSArray else {
                print("creatives Not an Array")
                return
            }
            for (creative) in creatives {
                print(creative)
            }
        }
        catch let JSONError as NSError {
            print("\(JSONError)")
        }

    }
    
    func getJSONFileTime(_ jsonData: Data) -> Int {
        do {
            let JSON = try JSONSerialization.jsonObject(with: jsonData, options:JSONSerialization.ReadingOptions(rawValue: 0))
            guard let JSONDictionary: NSDictionary = JSON as? NSDictionary else {
                print("Not a Dictionary")
                return 0
            }
            //print("JSONDictionary! \(JSONDictionary)")
            guard let fileTime = JSONDictionary["fileTime"] as? Int else {
                print("No File Time")
                return 0
            }
            return fileTime
        }
        catch let JSONError as NSError {
            print("\(JSONError)")
        }
        return 0
    }
    
    func readFile(_ fileName: String, fileLocation: String) -> Data? {
        if fileLocation == "download" {
            let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = DocumentDirURL.appendingPathComponent(fileName)
            return (try? Data(contentsOf: fileURL))
        } else {
            let filename: NSString = fileName as NSString
            let pathExtention = filename.pathExtension
            let pathPrefix = filename.deletingPathExtension
            guard let fileURLBuddle = Bundle.main.path(forResource: pathPrefix, ofType: pathExtention) else {
                return nil
            }
            return (try? Data(contentsOf: URL(fileURLWithPath: fileURLBuddle)))
        }
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
            if let _ = uiWebView.stringByEvaluatingJavaScript(from: "document.querySelector('body').innerHTML") {
                checkConnectionType()
            } else {
                self.loadFromLocal()
            }
        }
    }
    
    //when user tap on a remote notification
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
            if #available(iOS 8.0, *) {
                //let webView = self.view as! WKWebView
                self.webView!.evaluateJavaScript(jsCode) { (result, error) in
                }
            } else {
                if let _ = self.uiWebView.stringByEvaluatingJavaScript(from: jsCode) {
                }
            }
        }
    }
    
    
    func checkConnectionType() {
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
    
    
    
    func updateConnectionToWeb(_ connectionType: String) {
        let jsCode = "window.gConnectionType = '\(connectionType)';"
        if #available(iOS 8.0, *) {
            //let webView = self.view as! WKWebView
            self.webView!.evaluateJavaScript(jsCode) { (result, error) in
            }
        } else {
            let _ = uiWebView.stringByEvaluatingJavaScript(from: jsCode)
        }
    }
    
    
    func resetTimer(_ seconds: TimeInterval) {
        timer?.invalidate()
        let nextTimer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(ViewController.handleIdleEvent(_:)), userInfo: nil, repeats: false)
        timer = nextTimer
    }
    
    func handleIdleEvent(_ timer: Timer) {
        // do whatever you want when idle after certain period of time
        displayWebView()
    }
    
    func displayWebView() {
        if pageStatus != .webViewDisplayed {
            for subUIView in overlayView!.subviews {
                subUIView.removeFromSuperview()
            }
            overlayView!.removeFromSuperview()
            overlayView = nil
            self.view.viewWithTag(111)?.removeFromSuperview()
            pageStatus = .webViewDisplayed
            //trigger prefersStatusBarHidden
            setNeedsStatusBarAppearanceUpdate()
            getUserId()
        }
    }
    
    
    //iOS 7 link clicked
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let urlString = request.url!.absoluteString
        if (urlString != startUrl && urlString != "about:blank") {
            resetTimer(maxAdTimeAfterWebRequest)
        }
        if request.url!.scheme == "ftcweixin" {
            shareToWeChat(urlString)
            return false
        }  else if request.url!.scheme == "iosaction" {
            turnOnActionSheet(urlString)
            return false
        } else if navigationType == .linkClicked{
            if urlString.range(of: "mailto:") != nil{
                UIApplication.shared.openURL(request.url!)
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
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
        let urlString = navigationAction.request.url!.absoluteString
        if (urlString != startUrl && urlString != "about:blank") {
            resetTimer(maxAdTimeAfterWebRequest)
        }
        if navigationAction.request.url!.scheme == "ftcweixin" {
            shareToWeChat(urlString)
            decisionHandler(.cancel)
        } else if navigationAction.request.url!.scheme == "iosaction" {
            turnOnActionSheet(urlString)
            decisionHandler(.cancel)
        } else if navigationAction.navigationType == .linkActivated{
            if urlString.range(of: "mailto:") != nil{
                UIApplication.shared.openURL(navigationAction.request.url!)
            } else {
                openInView (urlString)
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    func turnOnActionSheet(_ originalUrlString : String) {
        let originalURL = originalUrlString
        var queryStringDictionary = ["url":""]
        let urlComponents = (originalURL as NSString!).substring(from: 13).components(separatedBy: "&")
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
        webPageUrl = queryStringDictionary["url"]!.removingPercentEncoding!
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
        let url = URL(string: urlWithCCode)
        if let myWebsite = url {
            let shareData = DataForShare()
            //let image = UIImage(named: "ftcicon.jpg")!
            let image = ShareImageActivityProvider(placeholderItem: UIImage(named: "ftcicon.jpg")!)
            let objectsToShare = [shareData, myWebsite, image] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [wcActivity, wcCircle, wcFav, openInSafari])
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            if UIDevice.current.userInterfaceIdiom == .pad {
                let popup: UIPopoverController = UIPopoverController(contentViewController: activityVC)
                popup.present(from: CGRect(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 4, width: 0, height: 0), in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
            } else {
                self.present(activityVC, animated: true, completion: nil)
            }
            //            let imageNew = UIImage(named: "WeChatFav")!
            //            objectsToShare = [shareData, myWebsite, imageNew]
            //            activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [wcActivity, wcCircle, wcFav, openInSafari])
            //            self.presentViewController(activityVC, animated: true, completion: nil)
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
                let url = URL(string:urlString)
                let webVC = SFSafariViewController(url: url!)
                webVC.delegate = self
                self.present(webVC, animated: true, completion: nil)
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
            if let uId = uiWebView.stringByEvaluatingJavaScript(from: "getCookie('USER_ID')") {
                if uId != "null" && uId != "" {
                    userId = uId
                }
                self.sendToken(userId)
            }
        }
    }
    
    func sendToken(_ userId: String) {
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

