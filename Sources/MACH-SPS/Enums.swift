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
    case erstream = "ERSTREAM"
    case agora = "AGORA"
    
    func getLabel() -> String {
        switch self {
        case .aws:
            return "aws"
        case .mux:
            return "mux"
        case .erstream:
            return "aws"
        case .agora:
            return "agora"
        }
    }
}

@objc
public enum StreamListType: Int, Codable {
    case live
    case past
    
    public  func getValue() -> String{
        switch self {
        case .live:
            return "live"
        case .past:
            return "past"
        }
    }
}
