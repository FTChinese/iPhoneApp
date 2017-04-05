//
//  PlaySpeech.swift
//  FT中文网
//
//  Created by ZhangOliver on 2017/3/26.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

import MediaPlayer

// MARK: Further Reading: http://www.appcoda.com/text-to-speech-ios-tutorial/


// MARK: - Use singleton pattern to pass speech data between view controllers. It's better in in term of code style than prepare segue.
class SpeechContent {
    static let sharedInstance = SpeechContent()
    var body = [String: String]()
}

// MARK: - Remove HTML Tags from the Text
extension String {
    private func deleteHTMLTag(_ tag:String) -> String {
        return self.replacingOccurrences(of: "(?i)</?\(tag)\\b[^<]*>", with: "", options: .regularExpression)
    }
    
    func deleteHTMLTags(_ tags:[String]) -> String {
        var mutableString = self
        for tag in tags {
            mutableString = mutableString.deleteHTMLTag(tag)
        }
        return mutableString
    }
}


class PlaySpeech: UIViewController, AVSpeechSynthesizerDelegate,UIPopoverPresentationControllerDelegate {
    
    private lazy var mySpeechSynthesizer:AVSpeechSynthesizer? = nil
    private lazy var audioText: NSMutableAttributedString? = nil
    private var audioLanguage = ""
    private var eventCategory = ""
    private lazy var previouseRange: NSRange? = nil

    
    @IBOutlet weak var buttonPlayPause: UIBarButtonItem!
    
    @IBAction func pauseSpeech(_ sender: UIBarButtonItem) {
        var image = UIImage(named: "PauseButton")
        if let mySpeechSynthesizer = mySpeechSynthesizer {
            if mySpeechSynthesizer.isPaused == false && mySpeechSynthesizer.isSpeaking == false {
                if let titleAndText = audioText?.string {
                    let mySpeechUtterance:AVSpeechUtterance = AVSpeechUtterance(string: titleAndText)
                    mySpeechUtterance.voice = AVSpeechSynthesisVoice(language: audioLanguage)
                    mySpeechSynthesizer.speak(mySpeechUtterance)
                    mySpeechSynthesizer.continueSpeaking()
                }
            } else if mySpeechSynthesizer.isPaused == false {
                mySpeechSynthesizer.pauseSpeaking(at: .word)
                image = UIImage(named: "PlayButton")
            } else {
                mySpeechSynthesizer.continueSpeaking()
            }
        }
        buttonPlayPause.image = image
    }
    
    @IBAction func stopSpeech(_ sender: UIBarButtonItem) {
        mySpeechSynthesizer?.stopSpeaking(at: .word)
        mySpeechSynthesizer = nil
        //print ("speech should stop now! ")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setSpeechOptions(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "Speech Settings", sender: sender)
    }
    
    @IBOutlet weak var bodytext: UITextView!
    
    deinit {
        mySpeechSynthesizer = nil
        print ("audio cleared")
    }
    
    override func loadView() {
        super.loadView()
        parseAudioMessage()
        enableBackGroundMode()
        displayText()
        // MARK: - listen to notifications about preference change
        let nc = NotificationCenter.default
        nc.addObserver(
            forName:Notification.Name(rawValue:"Replay Needed"),
            object:nil,
            queue:nil,
            using:replay
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func replay(notification:Notification) -> Void {
        //let userInfo = notification.userInfo
        mySpeechSynthesizer?.stopSpeaking(at: .word)
        parseAudioMessage()
        //displayText()
        if let titleAndText = audioText?.string {
            let mySpeechUtterance:AVSpeechUtterance = AVSpeechUtterance(string: titleAndText)
            mySpeechUtterance.voice = AVSpeechSynthesisVoice(language: audioLanguage)
            mySpeechSynthesizer?.speak(mySpeechUtterance)
            buttonPlayPause.image = UIImage(named: "PauseButton")
        }
    }
    
    private func parseAudioMessage() {
        let body = SpeechContent.sharedInstance.body
        if let language = body["language"], let text = body["text"], let title = body["title"], let eventCategory = body["eventCategory"] {
            var speechLanguage = ""
            switch language {
            case "en":
                speechLanguage = UserDefaults.standard.string(forKey: englishVoiceKey) ?? "en-GB"
            default:
                speechLanguage = UserDefaults.standard.string(forKey: chineseVoiceKey) ?? "zh-CN"
            }
            self.audioLanguage = speechLanguage
            self.eventCategory = eventCategory
            let titleParagraphStyle = NSMutableParagraphStyle()
            titleParagraphStyle.paragraphSpacing = 20
            let titleAttributes = [
                NSForegroundColorAttributeName: UIColor.black,
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 22),
                NSParagraphStyleAttributeName:titleParagraphStyle
            ]
            let bodyParagraphStyle = NSMutableParagraphStyle()
            bodyParagraphStyle.paragraphSpacing = 20
            bodyParagraphStyle.lineSpacing = 10
            
            let bodyAttributes = [
                NSForegroundColorAttributeName: UIColor.black,
                NSFontAttributeName: UIFont.systemFont(ofSize: 18),
                NSParagraphStyleAttributeName:bodyParagraphStyle,
                ]
            let titleAttrString = NSMutableAttributedString(
                string: title,
                attributes: titleAttributes
            )
            // MARK: - Use deliminator so that the utterance will pause after the title
            let deliminatorAttributes = [
                NSForegroundColorAttributeName: UIColor(netHex:0xFFF1E0),
                NSFontAttributeName: UIFont.systemFont(ofSize: 0)
            ]
            let deliminatorAttrString = NSMutableAttributedString(
                string: ". \r\n",
                attributes: deliminatorAttributes
            )
            let textFromHTML = text
                .replacingOccurrences(of: "[\r\n]", with: "", options: .regularExpression, range: nil)
                .replacingOccurrences(of: "(</p><p>)+", with: "\r\n", options: .regularExpression, range: nil)
            let bodyAttrString = NSMutableAttributedString(
                string: textFromHTML.deleteHTMLTags(["a","p","div","img","span","b","i"]),
                attributes: bodyAttributes
            )
            let fullBodyAttrString = NSMutableAttributedString()
            fullBodyAttrString.append(titleAttrString)
            fullBodyAttrString.append(deliminatorAttrString)
            fullBodyAttrString.append(bodyAttrString)
            audioText = fullBodyAttrString
        }
    }
    
    
    
    private func textToSpeech(_ text: NSMutableAttributedString, language: String) {
        // MARK: - Continue audio even when device is set to mute. Do this only when user is actually playing audio because users might want to read FTC news while listening to music from other apps.
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        
        // MARK: - Continue audio when device is in background
        try? AVAudioSession.sharedInstance().setActive(true)
        
        mySpeechSynthesizer = AVSpeechSynthesizer()
        let titleAndText = text.string
        let mySpeechUtterance:AVSpeechUtterance = AVSpeechUtterance(string: titleAndText)
        // MARK: Set lguange. Chinese is zh-CN
        mySpeechUtterance.voice = AVSpeechSynthesisVoice(language: language)
        // mySpeechUtterance.rate = 1.0
        mySpeechSynthesizer?.delegate = self
        mySpeechSynthesizer?.speak(mySpeechUtterance)
        
        //大标题 - 小标题  - 歌曲总时长 - 歌曲当前播放时长 - 封面
        if let artwork = UIImage(named: "ftcicon.jpg") {
            let settings = [MPMediaItemPropertyTitle: "FT中文网",
                            MPMediaItemPropertyArtist: "全球财经精粹",
                            //MPMediaItemPropertyPlaybackDuration: "\(audioPlayer.duration)",
                //MPNowPlayingInfoPropertyElapsedPlaybackTime: "\(audioPlayer.currentTime)",
                MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: artwork)] as [String : Any]
            MPNowPlayingInfoCenter.default().setValue(settings, forKey: "nowPlayingInfo")
        }
    }
    
    private func enableBackGroundMode() {
        // MARK: Receive Messages from Lock Screen
        UIApplication.shared.beginReceivingRemoteControlEvents();
        MPRemoteCommandCenter.shared().playCommand.addTarget {event in
            print("resume music")
            self.mySpeechSynthesizer?.continueSpeaking()
            return .success
        }
        MPRemoteCommandCenter.shared().pauseCommand.addTarget {event in
            print ("pause speech")
            self.mySpeechSynthesizer?.pauseSpeaking(at: .word)
            return .success
        }
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget {event in
            print ("next audio")
            return .success
        }
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget {event in
            print ("previous audio")
            return .success
        }
    }
    
    private func displayText() {
        if let audioText = audioText {
            self.bodytext.attributedText = audioText
            self.bodytext.scrollRangeToVisible(NSRange(location:0, length:0))
            textToSpeech(audioText, language: audioLanguage)
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if let mutableAttributedString = audioText {
            if let previouseRange = previouseRange {
                mutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: previouseRange)
            }
            mutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(netHex:0xF6801A), range: characterRange)
            self.bodytext.attributedText = mutableAttributedString
            self.bodytext.scrollRangeToVisible(characterRange)
        }
        previouseRange = characterRange
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if let mutableAttributedString = audioText {
            if let previouseRange = previouseRange {
                mutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: previouseRange)
                self.bodytext.attributedText = mutableAttributedString
                self.bodytext.scrollRangeToVisible(previouseRange)
            }
        }
        let body = SpeechContent.sharedInstance.body
        if let language = body["language"], let title = body["title"] {
            if let rootViewController = UIApplication.shared.windows[0].rootViewController as? ViewController {
                let jsCode = "ga('send','event','\(eventCategory)', 'Finish', '\(language): \(title.replacingOccurrences(of: "'", with: ""))');"
                rootViewController.webView.evaluateJavaScript(jsCode) { (result, error) in
                }
            }
        }
        let image = UIImage(named: "PlayButton")
        buttonPlayPause.image = image
    }
    
}
