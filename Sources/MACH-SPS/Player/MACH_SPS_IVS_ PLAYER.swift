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
    
    func getIVSPlayerView(url: URL) -> SPSIVSPlayer {
        playerView.removeFromSuperview()
        player = IVSPlayer()
        player?.delegate = self
        playerView.player = player
        player?.load(url)
        player?.looping = true
        playerView.frame = self.bounds
        addSubview(playerView)
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return self
    }
    
    func updateIVSPlayer(url: URL) {
        player?.load(url)
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
