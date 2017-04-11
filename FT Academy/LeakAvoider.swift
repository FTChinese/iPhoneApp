//
//  LeakAvoider.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/11.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
import WebKit

// MARK: - WKWebView causes view controller to leak. Use this to avoid leak: http://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak
class LeakAvoider: NSObject, WKScriptMessageHandler {
    weak var delegate : WKScriptMessageHandler?
    init(delegate:WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}
