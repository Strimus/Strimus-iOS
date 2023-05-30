//
//  File.swift
//  
//
//  Created by Machina on 9.05.2023.
//

import Foundation
import AmazonIVSPlayer
import AmazonIVSBroadcast
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
}
