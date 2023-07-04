//
//  File.swift
//  
//
//  Created by Machina on 9.05.2023.
//

import Foundation
import AmazonIVSPlayer
import AmazonIVSBroadcast
import AgoraRtcKit

public enum SPSPlayerState {
    case idle, ready, buffering, playing, ended, unknown
    
    init(avsState: IVSPlayer.State) {
        switch avsState {
        case .idle:
            self = .idle
        case .ready:
            self = .ready
        case .buffering:
            self = .buffering
        case .playing:
            self = .playing
        case .ended:
            self = .ended
        @unknown default:
            self = .unknown
        }
    }
    
    init(agoraState: AgoraConnectionState) {
        switch agoraState {
        case .disconnected:
            self = .ended
        case .connecting:
            self = .buffering
        case .connected:
            self = .playing
        case .reconnecting:
            self = .buffering
        case .failed:
            self = .ended
        @unknown default:
            self = .unknown
        }
    }
}

public enum SPSBroadcasterState {
    case invalid, disconnected, connecting, connected, error, unknown
    
    init(avsState: IVSBroadcastSession.State) {
        switch avsState {
        case .invalid:
            self = .invalid
        case .disconnected:
            self = .disconnected
        case .connecting:
            self = .connecting
        case .connected:
            self = .connected
        case .error:
            self = .error
        @unknown default:
            self = .unknown
        }
    }
}

public enum BroadcastSource: String {
    case aws = "AWS"
    case mux = "MUX"
    
    func getLabel() -> String {
        self.rawValue.lowercased()
    }
}

public enum StreamListType: String, Codable {
    case live = "live"
    case past = "old_stream"
}
