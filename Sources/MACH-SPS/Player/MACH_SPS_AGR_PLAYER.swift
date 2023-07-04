//
//  File.swift
//  
//
//  Created by Machina on 3.07.2023.
//

import AgoraRtcKit

class SPSAgoraPlayer: SPSPlayerView {
    
    var playerView = UIView()
    
    var agoraEngine: AgoraRtcEngineKit!
    var appID = ""
    var token = ""
    var channelName = ""
    
    func setupAgoraPlayerView(token: String, channelName: String, appID: String) {
        
        self.appID = appID
        self.channelName = channelName
        self.token = token
        playerView.removeFromSuperview()
        playerView.frame = self.bounds
        playerView.backgroundColor = .red
        addSubview(playerView)
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        initializeAgoraEngine()
        play()
    }
    
    func updateAgoraPlayerView(token: String, channelName: String, appID: String) {
        agoraEngine.leaveChannel() { [weak self] _ in
            self?.token = token
            self?.channelName = channelName
            self?.appID = appID
            self?.play()
        }
    }
    
    private func initializeAgoraEngine() {
        let config = AgoraRtcEngineConfig()
        // Pass in your App ID here.
        config.appId = appID
        // Use AgoraRtcEngineDelegate for the following delegate parameter.
        agoraEngine = AgoraRtcEngineKit.sharedEngine(with: config, delegate: self)
        agoraEngine.setClientRole(.audience)
    }

    override func play() {
        let option = AgoraRtcChannelMediaOptions()
        option.clientRoleType = .audience
        option.channelProfile = .liveBroadcasting
        agoraEngine.enableVideo()
        agoraEngine.joinChannel(byToken: token,
                                channelId: channelName,
                                uid: 0,
                                mediaOptions: option)
    }
    
    override func pause() {
        agoraEngine.leaveChannel()
    }
}

extension SPSAgoraPlayer: AgoraRtcEngineDelegate {
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionState, reason: AgoraConnectionChangedReason) {
        self.state = SPSPlayerState(agoraState: state)
        self.delegate?.stateUpdated(state: self.state)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        self.delegate?.playerError(error: NSError(domain: "Agora Error", code: errorCode.rawValue))
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .hidden
        videoCanvas.view = playerView
        agoraEngine.setupRemoteVideo(videoCanvas)
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoFrameOfUid uid: UInt, size: CGSize, elapsed: Int) {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.renderMode = .fit
        videoCanvas.view = playerView
        agoraEngine.setupRemoteVideo(videoCanvas)
    }
    
}
