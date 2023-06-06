//
//  MACH_SPS_MUX_BROADCASTER.swift
//  
//
//  Created by Machina on 29.05.2023.
//

import HaishinKit
import AVFoundation
import UIKit
import VideoToolbox

public class SPSMuxBroadcaster: SPSBroadcasterView {
    
    private var rtmpConnection = RTMPConnection()
    private var rtmpStream: RTMPStream!
    private var mthkView: MTHKView!
    
    override func setupStream() {
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
            try session.setActive(true)
        } catch {
            print(error)
        }
        
        rtmpStream = RTMPStream(connection: rtmpConnection)
        
        // Configure the capture settings from the camera
        rtmpStream.frameRate = 30
        rtmpStream.sessionPreset = AVCaptureSession.Preset.medium
        rtmpStream.videoOrientation = .portrait
        /// Specifies the video capture settings.
        //rtmpStream.videoCapture(for: 0)?.isVideoMirrored = false
        //rtmpStream.videoCapture(for: 0)?.preferredVideoStabilizationMode = .auto

        // Configure the RTMP audio stream
        rtmpStream.audioSettings = AudioCodecSettings(bitRate: 64*00)
        
        // Attatch to the default audio device
        rtmpStream.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
            print(error.localizedDescription)
        }
        
        let front = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        // Attatch to the default camera
        rtmpStream.attachCamera(front) { error in
            print(error.localizedDescription)
        }
        
        // Add event listeners for RTMP status changes and IO Errors
        rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        rtmpConnection.addEventListener(.ioError, selector: #selector(rtmpErrorHandler), observer: self)
        
        DispatchQueue.main.async { [unowned self] in
            self.mthkView = MTHKView(frame: CGRect(origin: .zero, size: CGSize(width: Int(self.rtmpStream.videoSettings.videoSize.width), height: Int(self.rtmpStream.videoSettings.videoSize.height))))
            self.mthkView.videoOrientation = self.rtmpStream.videoOrientation
            self.mthkView.videoGravity = .resizeAspectFill
        }
       
        if let streamURL {
            rtmpConnection.connect(streamURL.absoluteString)
        }
    }
    
    
    public override func startStream() {
        if let streamKey {
            rtmpStream.publish(streamKey)
        }
    }
    
    public override func stopStream() {
        Task {
            if let id = streamId {
                try? await Strimus.shared.stopStream(id: id)
            }
            rtmpStream.close()
        }
    }
    
    @objc
    private func rtmpStatusHandler(_ notification: Notification) {
        print("RTMP Status Handler called.")
        
        let e = Event.from(notification)
        guard let data: ASObject = e.data as? ASObject, let code: String = data["code"] as? String else {
            return
        }

        switch code {
        case RTMPConnection.Code.connectSuccess.rawValue:
            DispatchQueue.main.async { [unowned self] in
                self.mthkView.attachStream(self.rtmpStream)
                previewView = mthkView
                self.delegate?.streamIsReady(preview: previewView)
            }
            
            state = .disconnected
        case RTMPStream.Code.publishStart.rawValue:
            delegate?.stateUpdated(state: .connected)
            state = .connected
        case RTMPStream.Code.unpublishSuccess.rawValue:
            delegate?.stateUpdated(state: .disconnected)
            state = .disconnected
        case RTMPConnection.Code.connectFailed.rawValue:
            delegate?.stateUpdated(state: .error)
            state = .error
        case RTMPConnection.Code.connectClosed.rawValue:
            delegate?.stateUpdated(state: .disconnected)
            state = .disconnected
        default:
            break
        }
    }
    
    @objc
    private func rtmpErrorHandler(_ notification: Notification) {
        delegate?.stateUpdated(state: .error)
    }
}

extension SPSMuxBroadcaster {
    enum Preset {
        case hd_1080p_30fps_5mbps
        case hd_720p_30fps_3mbps
        case sd_540p_30fps_2mbps
        case sd_360p_30fps_1mbps
    }
    
    // An encoding profile - width, height, framerate, video bitrate
    private class Profile {
        public var width : Int = 0
        public var height : Int = 0
        public var frameRate : Int = 0
        public var bitrate : Int = 0
        
        init(width: Int, height: Int, frameRate: Int, bitrate: Int) {
            self.width = width
            self.height = height
            self.frameRate = frameRate
            self.bitrate = bitrate
        }
    }
    
    // Converts a Preset to a Profile
    private func presetToProfile(preset: Preset) -> Profile {
        switch preset {
        case .hd_1080p_30fps_5mbps:
            return Profile(width: 1920, height: 1080, frameRate: 30, bitrate: 5000000)
        case .hd_720p_30fps_3mbps:
            return Profile(width: 1280, height: 720, frameRate: 30, bitrate: 3000000)
        case .sd_540p_30fps_2mbps:
            return Profile(width: 960, height: 540, frameRate: 30, bitrate: 2000000)
        case .sd_360p_30fps_1mbps:
            return Profile(width: 640, height: 360, frameRate: 30, bitrate: 1000000)
        }
    }
}
