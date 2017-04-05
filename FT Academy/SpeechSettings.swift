//
//  SpeechSettings.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/1.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
import UIKit
class SpeechSettings: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIPopoverPresentationControllerDelegate {
    
    let englishVoice = [
        "英国":"en-GB",
        "美国":"en-US",
        "澳大利亚":"en-AU",
        "南非":"en-ZA",
        "爱尔兰":"en-IE"
    ]
    var englishVoiceData = [String]()
    let chineseVoice = [
        "中国大陆":"zh-CN",
        "香港":"zh-HK",
        "台湾":"zh-TW"
    ]
    var chineseVoiceData = [String]()
    private let currentEnglishVoice = UserDefaults.standard.string(forKey: englishVoiceKey) ?? "en-GB"
    private var newEnglishVoice = UserDefaults.standard.string(forKey: englishVoiceKey) ?? "en-GB"
    private let currentChineseVoice = UserDefaults.standard.string(forKey: chineseVoiceKey) ?? "zh-CN"
    private var newChineseVoice = UserDefaults.standard.string(forKey: chineseVoiceKey) ?? "zh-CN"
    
    @IBAction func closeSettings(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var englishVoicePicker: UIPickerView!
    
    @IBOutlet weak var chineseVoicePicker: UIPickerView!
    
    @IBAction func saveChanges(_ sender: Any) {
        UserDefaults.standard.set(newEnglishVoice, forKey: englishVoiceKey)
        UserDefaults.standard.set(newChineseVoice, forKey: chineseVoiceKey)
        // MARK: - Play the speech again if necessary
        var needToReplayVoice = false
        let body = SpeechContent.sharedInstance.body
        if let language = body["language"] {
            if (language == "en" && currentEnglishVoice != newEnglishVoice) || (language == "ch" && currentChineseVoice != newChineseVoice) {
                needToReplayVoice = true
            }
        }
        if needToReplayVoice == true {
            let nc = NotificationCenter.default
            nc.post(
                name:Notification.Name(rawValue:"Replay Needed"),
                object: nil,
                userInfo: nil
            )
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func loadView() {
        super.loadView()
        if self.popoverPresentationController?.adaptivePresentationStyle == .popover {
            print ("this is a popover")
        }
        self.popoverPresentationController?.backgroundColor = UIColor(netHex: 0xFFF1E0)
        englishVoiceData = Array(englishVoice.keys)
        englishVoicePicker.dataSource = self
        englishVoicePicker.delegate = self
        let defaultRowForEnglish = getPickerRowByValue(englishVoice, value: currentEnglishVoice)
        print (currentEnglishVoice)
        print (defaultRowForEnglish)
        englishVoicePicker.selectRow(defaultRowForEnglish, inComponent: 0, animated: false)
        chineseVoiceData = Array(chineseVoice.keys)
        chineseVoicePicker.dataSource = self
        chineseVoicePicker.delegate = self
        let defaultRowForChinese = getPickerRowByValue(chineseVoice, value: currentChineseVoice)
        chineseVoicePicker.selectRow(defaultRowForChinese, inComponent: 0, animated: false)
    }
    
    private func getPickerRowByValue(_ voices: [String: String], value: String) -> Int {
        let voicesArray = Array(voices.values)
        let voiceIndex = voicesArray.index(of: value)
        return voiceIndex ?? 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.restorationIdentifier == "English Accent Picker" {
            return englishVoiceData.count
        } else {
            return chineseVoiceData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.restorationIdentifier == "English Accent Picker" {
            return englishVoiceData[row]
        } else {
            return chineseVoiceData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var language = "en"
        var accent = "en-GB"
        if pickerView.restorationIdentifier == "English Accent Picker" {
            language = "en"
            accent = englishVoice[englishVoiceData[row]] ?? "en-GB"
        } else {
            language = "ch"
            accent = chineseVoice[chineseVoiceData[row]] ?? "zh-CN"
        }
        changeVoice(language, voice: accent)
    }
    
    func changeVoice (_ language: String, voice: String) {
        // TODO: - Update Parent View's Accent and Save
        if language == "en" {
            newEnglishVoice = voice
        } else {
            newChineseVoice = voice
        }
    }
    
    
    
    
}
