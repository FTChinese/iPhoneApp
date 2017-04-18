//
//  AudioHelper.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/17.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import MediaPlayer

extension CMTime {
    var durationText:String {
        let totalSeconds = CMTimeGetSeconds(self)
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 3600)  / 60)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}
