//
//  AudioPlayer.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/5.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import WebKit
import SafariServices



// MARK: - Use singleton pattern to pass speech data between view controllers. It's better in in term of code style than prepare segue.
class AudioContent {
    static let sharedInstance = AudioContent()
    var body = [String: String]()
}

class AudioPlayer: UIViewController,WKScriptMessageHandler,UIScrollViewDelegate,SFSafariViewControllerDelegate,WKNavigationDelegate {
    
    private var audioTitle = ""
    private var audioUrlString = ""
    private var audioId = ""
    private lazy var player: AVPlayer? = nil
    private lazy var playerItem: AVPlayerItem? = nil
    private lazy var webView: WKWebView? = nil
    private let nowPlayingCenter = NowPlayingCenter()
    
    
    @IBOutlet weak var containerView: UIWebView!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var buttonPlayAndPause: UIBarButtonItem!
    @IBOutlet weak var progressSlider: UISlider!
    @IBAction func ButtonPlayPause(_ sender: UIBarButtonItem) {
        if let player = player {
            if (player.rate != 0) && (player.error == nil) {
                player.pause()
                buttonPlayAndPause.image = UIImage(named:"BigPlayButton")
            } else {
                // MARK: - Continue audio even when device is set to mute. Do this only when user is actually playing audio because users might want to read FTC news while listening to music from other apps.
                try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                
                // MARK: - Continue audio when device is in background
                try? AVAudioSession.sharedInstance().setActive(true)
                player.play()
                player.replaceCurrentItem(with: playerItem)
                buttonPlayAndPause.image = UIImage(named:"BigPauseButton")
                
                // TODO: - Need to find a way to display media duration and current time in lock screen
                var mediaLength: NSNumber = 0
                if let d = self.playerItem?.duration {
                    let duration = CMTimeGetSeconds(d)
                    if duration.isNaN == false {
                        mediaLength = duration as NSNumber
                    }
                }
                
                var currentTime: NSNumber = 0
                if let c = self.playerItem?.currentTime() {
                    let currentTime1 = CMTimeGetSeconds(c)
                    if currentTime1.isNaN == false {
                        currentTime = currentTime1 as NSNumber
                    }
                }
                nowPlayingCenter.updateInfo(
                    title: audioTitle,
                    artist: "FT中文网",
                    albumArt: UIImage(named: "cover.jpg"),
                    currentTime: currentTime,
                    mediaLength: mediaLength,
                    PlaybackRate: 1.0
                )
            }
            nowPlayingCenter.updateTimeForPlayerItem(player)
        }
    }
    
    @IBAction func StopAudio(_ sender: UIBarButtonItem) {
        if let player = player {
            player.pause()
            self.player = nil
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let currentValue = sender.value
        //let maxTime = sender.maximumValue
        let currentTime = CMTimeMake(Int64(currentValue), 1)
        playerItem?.seek(to: currentTime)
        
        //print ("seeking to: \(currentTime)")
    }
    
    @IBAction func share(_ sender: UIBarButtonItem) {
        let wcActivity = WeChatShare(to: "chat")
        let wcCircle = WeChatShare(to: "moment")
        let openInSafari = OpenInSafari()
        if let myWebsite = self.webView?.url {
            let shareData = DataForShare()
            let image = ShareImageActivityProvider(placeholderItem: UIImage(named: "ftcicon.jpg")!)
            let objectsToShare = [shareData, myWebsite, image] as [Any]
            let activityVC: UIActivityViewController
            if WXApi.isWXAppSupport() == true {
                activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [wcActivity, wcCircle, openInSafari])
            } else {
                activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [openInSafari])
            }
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        playerItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
        
        // MARK: - Stop loading and remove message handlers to avoid leak
        self.webView?.stopLoading()
        self.webView?.configuration.userContentController.removeScriptMessageHandler(forName: "callbackHandler")
        self.webView?.configuration.userContentController.removeAllUserScripts()
        print ("deinit successfully and observer removed")
    }
    
    override func loadView() {
        super.loadView()
        parseAudioMessage()
        prepareAudioPlay()
        enableBackGroundMode()
        
        webPageTitle = webPageTitle0
        webPageDescription = webPageDescription0
        webPageImage = webPageImage0
        webPageImageIcon = webPageImageIcon0
        
        let jsCode = "function getContentByMetaTagName(c) {for (var b = document.getElementsByTagName('meta'), a = 0; a < b.length; a++) {if (c == b[a].name || c == b[a].getAttribute('property')) { return b[a].content; }} return '';} var gCoverImage = getContentByMetaTagName('og:image') || '';var gIconImage = getContentByMetaTagName('thumbnail') || '';var gDescription = getContentByMetaTagName('og:description') || getContentByMetaTagName('description') || '';gIconImage=encodeURIComponent(gIconImage);webkit.messageHandlers.callbackHandler.postMessage(gCoverImage + '|' + gIconImage + '|' + gDescription);"
        let userScript = WKUserScript(
            source: jsCode,
            injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
            forMainFrameOnly: true
        )
        let contentController = WKUserContentController()
        contentController.addUserScript(userScript)
        // MARK: - Use a LeakAvoider to avoid leak
        contentController.add(
            LeakAvoider(delegate:self),
            name: "callbackHandler"
        )
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        self.webView = WKWebView(frame: self.containerView.frame, configuration: config)
        self.containerView.addSubview(self.webView!)
        self.containerView.clipsToBounds = true
        self.webView?.scrollView.bounces = false
        self.webView?.navigationDelegate = self
        self.webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.webView?.scrollView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webPageUrl = "http://www.ftchinese.com/interactive/\(audioId)?hideheader=yes"
        if let url = URL(string:webPageUrl) {
            let req = URLRequest(url:url)
            // FIXME: - This is to suppress Apple's complaint. Should be webView?.load(req). Try change it back after Xcode upgrade.
            _ = webView?.load(req)
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("page loaded!")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            if let infoForShare = message.body as? String{
                print(infoForShare)
                let toArray = infoForShare.components(separatedBy: "|")
                webPageDescription = toArray[2]
                webPageImage = toArray[0]
                webPageImageIcon = toArray[1]
                print("get image icon from web page: \(webPageImageIcon)")
            }
        }
    }
    
    
    // MARK: - When users click on a link from the web view.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (@escaping (WKNavigationActionPolicy) -> Void)) {
        if let url = navigationAction.request.url {
            let urlString = url.absoluteString
            if navigationAction.navigationType == .linkActivated{
                if urlString.range(of: "mailto:") != nil{
                    UIApplication.shared.openURL(url)
                } else {
                    openInView (urlString)
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }
    }
    
    
    // FIXME: - This is very simlar to the same func in ViewController. Consider optimize the code.
    func openInView(_ urlString : String) {
        webPageUrl = urlString
        let segueId = "Audio To WKWebView"
        if #available(iOS 9.0, *) {
            // MARK: - Use Safariview for iOS 9 and above
            if urlString.range(of: "www.ftchinese.com") == nil && urlString.range(of: "i.ftimg.net") == nil {
                // MARK: - When opening an outside url which we have no control over
                if let url = URL(string:urlString) {
                    if let urlScheme = url.scheme?.lowercased() {
                        if ["http", "https"].contains(urlScheme) {
                            // MARK: - Can open with SFSafariViewController
                            let webVC = SFSafariViewController(url: url)
                            webVC.delegate = self
                            self.present(webVC, animated: true, completion: nil)
                        } else {
                            // MARK: - When Scheme is not supported or no scheme is given, use openURL
                            UIApplication.shared.openURL(url)
                        }
                    }
                }
            } else {
                // MARK: Open a url on a page that we have control over
                self.performSegue(withIdentifier: segueId, sender: nil)
            }
        } else {
            // MARK: Fallback on earlier versions
            self.performSegue(withIdentifier: segueId, sender: nil)
        }
    }
    
    private func parseAudioMessage() {
        let body = AudioContent.sharedInstance.body
        if let title = body["title"], let audioFileUrl = body["audioFileUrl"], let interactiveUrl = body["interactiveUrl"] {
            print (title)
            audioTitle = title
            audioUrlString = audioFileUrl
            audioId = interactiveUrl.replacingOccurrences(
                of: "^.*interactive/([0-9]+).*$",
                with: "$1",
                options: .regularExpression
            )
            webPageTitle = title
        }
    }
    
    private func prepareAudioPlay() {
        
        // MARK: - Use https url so that the audio can be buffered properly on actual devices
        audioUrlString = audioUrlString.replacingOccurrences(of: "http://v.ftimg.net/album/", with: "https://creatives.ftimg.net/album/")
        
        // MARK: - Remove toolBar's top border. This cannot be done in interface builder.
        toolBar.clipsToBounds = true
        
        if let url = URL(string: audioUrlString) {
            let asset = AVURLAsset(url: url)
            playerItem = AVPlayerItem(asset: asset)
            player = AVPlayer()
            
            // MARK: - If user is using wifi, buffer the audio immediately
            let statusType = IJReachability().connectedToNetworkOfType()
            if statusType == .wiFi {
                player?.replaceCurrentItem(with: playerItem)
            }
            
            // MARK: - Update audio play progress
            player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1/30.0, Int32(NSEC_PER_SEC)), queue: nil) { [weak self] time in
                if let d = self?.playerItem?.duration {
                    let duration = CMTimeGetSeconds(d)
                    if duration.isNaN == false {
                        self?.progressSlider.maximumValue = Float(duration)
                        if self?.progressSlider.isHighlighted == false {
                            self?.progressSlider.value = Float((CMTimeGetSeconds(time)))
                        }
                    }
                }
            }
            
            // MARK: - Observe Play to the End
            NotificationCenter.default.addObserver(self,selector:#selector(AudioPlayer.playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)

            // MARK: - Update buffer status
            playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
            playerItem?.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
        }
    }
    
    
    private func enableBackGroundMode() {
        // MARK: Receive Messages from Lock Screen
        UIApplication.shared.beginReceivingRemoteControlEvents();
        MPRemoteCommandCenter.shared().playCommand.addTarget {[weak self] event in
            print("resume music")
            self?.player?.play()
            self?.buttonPlayAndPause.image = UIImage(named:"BigPauseButton")
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {[weak self] event in
            print ("pause speech")
            self?.player?.pause()
            self?.buttonPlayAndPause.image = UIImage(named:"BigPlayButton")
            return .success
        }
//        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget {[weak self] event in
//            print ("next audio")
//            return .success
//        }
//        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget {[weak self] event in
//            print ("previous audio")
//            return .success
//        }
    }
    
    func playerDidFinishPlaying() {
        let startTime = CMTimeMake(0, 1)
        self.playerItem?.seek(to: startTime)
        self.player?.pause()
        self.progressSlider.value = 0
        self.buttonPlayAndPause.image = UIImage(named:"BigPlayButton")
        nowPlayingCenter.updateTimeForPlayerItem(player)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            if let k = keyPath {
                switch k {
                case "playbackBufferEmpty":
                    // Show loader
                    print ("is loading...")
                    
                case "playbackLikelyToKeepUp":
                    // Hide loader
                    print ("should be playing")
                    
                case "playbackBufferFull":
                    // Hide loader
                    print ("load successfully")
                default:
                    break
                }
            }
            nowPlayingCenter.updateTimeForPlayerItem(player)
        }
    }
    
    // TODO: Share
    
    // TODO: Download Management: Download or Delete
    
    // TODO: Subscribe
    
    // TODO: Display Background Images for Radio Columns
    
    // MARK: - Done: Deinit 1. remove observers 2. quit background play mode
    
    // MARK: - Done: Enable background play
    
    // MARK: - Done: Display the audio text
    
    // MARK: - Done: Update play progress
    
    
    
}
