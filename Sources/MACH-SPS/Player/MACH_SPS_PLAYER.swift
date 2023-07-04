//
//  File.swift
//  
//
//  Created by Machina on 15.04.2023.
//

import Foundation
import UIKit

public protocol SPSPlayerDelegate: AnyObject {
    func stateUpdated(state: SPSPlayerState)
    func playerError(error: Error)
}

public class SPSPlayerView: UIView {
    public var state: SPSPlayerState = .unknown
    public weak var delegate: SPSPlayerDelegate?
    public func play() {}
    public func pause() {}
}

public class SPSPlayer: UIView {
    
    var ivsPlayer = SPSIVSPlayer()
    var agoraPlayer = SPSAgoraPlayer()
    
    public func getPlayerView(stream: SBSStream) -> SPSPlayerView {
        if let channel = stream.channelName {
            setupAgoraPlayer(stream: stream, channelName: channel)
            return agoraPlayer
        } else {
            ivsPlayer.setupIVSPlayerView(stream: stream)
            return ivsPlayer
        }
    }
    
    public func updatePlayerView(stream: SBSStream) {
        ivsPlayer.updateIVSPlayer(stream: stream)
    }
    
    private func setupAgoraPlayer(stream: SBSStream, channelName: String) {
        Task {
            let subscriber = try? await Strimus.shared.getAgoraSubscriberToken(streamId: "\(stream.id)")
            if let token = subscriber?.token {
                agoraPlayer.setupAgoraPlayerView(token: token, channelName: channelName, appID:  "907a7150e4e84f97906a00eaea187315")
                
            }
        }
    }
}

