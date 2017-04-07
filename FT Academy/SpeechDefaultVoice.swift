//
//  SpeechDefaultVoice.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/7.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
struct SpeechDefaultVoice {

    public let englishVoiceKey = "English Voice"
    public let chineseVoiceKey = "Chinese Voice"
    
    public func getVoiceByLanguage(_ language: String) -> String {
        var englishDefaultVoice = "en-GB"
        var chineseDefaultChoice = "zh-CN"
        if let region = Locale.current.regionCode {
            switch region {
            case "US": englishDefaultVoice = "en-US"
            case "AU": englishDefaultVoice = "en-AU"
            case "ZA": englishDefaultVoice = "en-ZA"
            case "IE": englishDefaultVoice = "en-IE"
            case "TW": chineseDefaultChoice = "zh-TW"
            case "HK": chineseDefaultChoice = "zh-HK"
            default:
                break
            }
        }
        switch language {
        case "en":
            return UserDefaults.standard.string(forKey: englishVoiceKey) ?? englishDefaultVoice
        default:
            return UserDefaults.standard.string(forKey: chineseVoiceKey) ?? chineseDefaultChoice
        }

    }

}
