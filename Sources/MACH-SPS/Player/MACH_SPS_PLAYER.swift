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
    
    public func getPlayerView(url: URL) -> SPSPlayerView {
        ivsPlayer.getIVSPlayerView(url: url)
    }
    
    public func updatePlayerView(url: URL) {
        ivsPlayer.updateIVSPlayer(url: url)
    }
}

