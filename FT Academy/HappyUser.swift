//
//  HappyReader.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/5/11.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
import StoreKit
// MARK: When user is happy, request review
public class HappyUser {
    private let versionKey = "current version"
    private let launchCountKey = "launch count"
    private let promptRatingFrequency = 10
    private let ratePromptKey = "rate prompted"
    private var shouldTrackRequestReview = false
    
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
        //print ("current version is \(versionFromBundle) and launch count is \(currentLaunchCount)")
        
        
//        if let bundle = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: bundle)
//        }
        
    }
    
    func requestReview() {
        // MARK: Request user to review
        let currentLaunchCount: Int = UserDefaults.standard.integer(forKey: launchCountKey)
        let ratePrompted: Bool = UserDefaults.standard.bool(forKey: ratePromptKey)
        if ratePrompted != true && currentLaunchCount >= promptRatingFrequency {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                UserDefaults.standard.set(true, forKey: ratePromptKey)
                shouldTrackRequestReview = true
            }
        }
    }
    
    func checkDeviceType() -> String {
        let deviceType: String
        if UIDevice.current.userInterfaceIdiom == .pad {
            deviceType = "iPad"
        } else {
            deviceType  = "iPhone"
        }
        return deviceType
    }
    
    func requestReviewTracking() -> String? {
        let deviceType = checkDeviceType()
        let versionFromBundle = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let currentLaunchCount = UserDefaults.standard.integer(forKey: launchCountKey)
        let jsCode = "try{ga('send','event', '\(deviceType) Request Review', '\(versionFromBundle)', '\(currentLaunchCount)', {'nonInteraction':1});}catch(ignore){}"
        if shouldTrackRequestReview == true {
            shouldTrackRequestReview = false
            return jsCode
        }
        return nil
    }
}
