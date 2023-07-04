//
//  File.swift
//  
//
//  Created by Machina on 15.04.2023.
//

import AmazonIVSPlayer

class SPSIVSPlayer: SPSPlayerView {
    
    var playerView = IVSPlayerView()

    private var player: IVSPlayer?
    
    func setupIVSPlayerView(stream: SBSStream) {
        playerView.removeFromSuperview()
        player = IVSPlayer()
        player?.delegate = self
        playerView.player = player
        if stream.type == .live {
            if let url = stream.url {
                player?.load(url)
            }
        } else {
            if let url = stream.videos?.first?.url {
                player?.load(url)
            }
        }
        player?.looping = true
        playerView.frame = self.bounds
        addSubview(playerView)
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func updateIVSPlayer(stream: SBSStream) {
        if stream.type == .live {
            if let url = stream.url {
                player?.load(url)
            }
        } else {
            if let url = stream.videos?.first?.url {
                player?.load(url)
            }
        }
    }
    
    override func play() {
        player?.play()
    }
    
    override func pause() {
        player?.pause()
    }
}

extension SPSIVSPlayer: IVSPlayer.Delegate {
    func player(_ player: IVSPlayer, didChangeState state: IVSPlayer.State) {
        self.state = SPSPlayerState(avsState: state)
        self.delegate?.stateUpdated(state: self.state)
    }
    
    func player(_ player: IVSPlayer, didFailWithError error: Error) {
        self.delegate?.playerError(error: error)
    }
}
