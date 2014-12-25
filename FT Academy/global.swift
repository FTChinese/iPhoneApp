//
//  global.swift
//  FT Academy
//
//  Created by Zhang Oliver on 14/12/25.
//  Copyright (c) 2014年 Zhang Oliver. All rights reserved.
//

import Foundation
import UIKit
var webPageUrl = "http://m.ftchinese.com/"
var supportWK = false
func checkWKSupport() {
    switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
    case .OrderedSame, .OrderedDescending:
        supportWK = true
    case .OrderedAscending:
        supportWK = false
    }
}