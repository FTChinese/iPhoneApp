//
//  NowPlayingCenter.swift
//  FT中文网
//
//  Created by Oliver Zhang on 2017/4/10.
//  Copyright © 2017年 Financial Times Ltd. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import MediaPlayer
import WebKit

struct NowPlayingCenter {
    func updateInfo(title: String, artist: String, albumArt: UIImage?, currentTime: NSNumber, mediaLength: NSNumber, PlaybackRate: Double){
        if let artwork = albumArt {
            let mediaInfo: Dictionary <String, Any> = [
                MPMediaItemPropertyTitle: title,
                MPMediaItemPropertyArtist: artist,
                MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: artwork),
                // MARK: - Useful for displaying Background Play Time under wifi
                MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
                MPMediaItemPropertyPlaybackDuration: mediaLength,
                MPNowPlayingInfoPropertyPlaybackRate: PlaybackRate
            ]
            MPNowPlayingInfoCenter.default().nowPlayingInfo = mediaInfo
        }
    }
    func updateTimeForPlayerItem(_ player: AVPlayer?) {
        if let player = player {
        if let playerItem = player.currentItem, var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            let duration = CMTimeGetSeconds(playerItem.duration)
            let currentTime = CMTimeGetSeconds(playerItem.currentTime())
            let rate = player.rate
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = rate
            print ("Update: \(currentTime)/\(duration)/\(rate)")
        }
        }
    }
}
