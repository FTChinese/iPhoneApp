//
//  HappyReader.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/5/11.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
import StoreKit

class HappyUser {
    private let versionKey = "current version"
    private let launchCountKey = "launch count"
    private let promptRatingFrequency = 10
    private let ratePromptKey = "rate prompted"
    
    func launchCount() {
        let versionFromBundle: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let versionFromUserDefault: String = UserDefaults.standard.string(forKey: versionKey) ?? ""
        var currentLaunchCount: Int = UserDefaults.standard.integer(forKey: launchCountKey)
        if versionFromBundle == versionFromUserDefault {
            currentLaunchCount += 1
        } else {
            UserDefaults.standard.set(versionFromBundle, forKey: versionKey)
            UserDefaults.standard.set(false, forKey: ratePromptKey)
            currentLaunchCount = 1
        }
        UserDefaults.standard.set(currentLaunchCount, forKey: launchCountKey)
        // print ("current version is \(versionFromBundle) and launch count is \(currentLaunchCount)")
    }
    
    func requestReview() {
        // MARK: Request user to review
        let currentLaunchCount: Int = UserDefaults.standard.integer(forKey: launchCountKey)
        let ratePrompted: Bool = UserDefaults.standard.bool(forKey: ratePromptKey)
        if ratePrompted != true && currentLaunchCount >= promptRatingFrequency {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                UserDefaults.standard.set(true, forKey: ratePromptKey)
            }
        }
    }
}
