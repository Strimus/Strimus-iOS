//
//  MACH_SPS_AGR_BROADCASTER.swift
//  
//
//  Created by Sukru Kahraman on 2.03.2024.
//

import UIKit
import AgoraRtcKit
import SwiftUI

public class SPSAgoraBroadcaster: SPSBroadcasterView {
    
    // The client's role in the session.
    public var role: AgoraClientRole = .audience {
        didSet { engine.setClientRole(role) }
    }

    // The set of all users in the channel.
    @Published public var allUsers: Set<UInt> = []

    // Integer ID of the local user.
    @Published public var localUserId: UInt = 0

    private var engine: AgoraRtcEngineKit!
    
    // The Agora RTC Engine Kit for the session.
    
    
    func initializeAgora() {
        let engine = setupEngine()
        self.engine = engine
    }
    
    override func setupStream() {
        initializeAgora()
        createRemoteCanvasView(with: 0)
    }

    open func setupEngine() -> AgoraRtcEngineKit {
        let eng = AgoraRtcEngineKit.sharedEngine(withAppId: appId ?? "", delegate: self)
        eng.enableVideo()
        eng.setClientRole(role)
        return eng
    }
    
    func joinBroadcastStream( _ channel: String, token: String? = nil, uid: UInt = 0, isBroadcaster: Bool = true ) async -> Int32 {
        /// See ``AgoraManager/checkForPermissions()``, or Apple's docs for details of this method.

        let opt = AgoraRtcChannelMediaOptions()
        opt.channelProfile = .liveBroadcasting
        opt.clientRoleType = isBroadcaster ? .broadcaster : .audience
        opt.audienceLatencyLevel = isBroadcaster ? .ultraLowLatency : .lowLatency

        return self.engine.joinChannel(
            byToken: token, channelId: channel,
            uid: uid, mediaOptions: opt
        )
    }
    
    func createRemoteCanvasView(with uid: UInt) {
        // Create and return the video view
        DispatchQueue.main.async {
            var canvas = AgoraRtcVideoCanvas()
            let canvasView = UIView()
            canvas.view = canvasView
            
            self.engine.startPreview()
            self.engine.setupLocalVideo(canvas)
            self.delegate?.streamIsReady(preview: canvasView)
        }
        
    }
    
    func leaveChannel(leaveChannelBlock: ((AgoraChannelStats) -> Void)? = nil) -> Int32 {
        let leaveErr = self.engine.leaveChannel(leaveChannelBlock)
        self.engine.stopPreview()
        self.allUsers.removeAll()
        return leaveErr
    }
    
    public override func startStream() {
        Task {
            await joinBroadcastStream(channelName ?? "", token: token)
        }
    }
    
    public override func stopStream() {
    }
}

extension SPSAgoraBroadcaster: AgoraRtcEngineDelegate {
    public func rtcEngine(
        _ engine: AgoraRtcEngineKit, didJoinChannel channel: String,
        withUid uid: UInt, elapsed: Int
    ) {
        // The delegate is telling us that the local user has successfully joined the channel.
        self.localUserId = uid
        if self.role == .broadcaster {
            self.allUsers.insert(uid)
        }
    }

    public func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        // The delegate is telling us that a remote user has joined the channel.
        self.allUsers.insert(uid)
    }

    public func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        // The delegate is telling us that a remote user has left the channel.
        self.allUsers.remove(uid)
    }
    
    public func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        
    }
}
