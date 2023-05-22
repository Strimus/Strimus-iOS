//
//  File.swift
//  
//
//  Created by Machina on 17.05.2023.
//

import AmazonIVSBroadcast
import Foundation
import AVFoundation

public protocol SPSBroadcasterDelegate: AnyObject {
    func stateUpdated(state: SPSBroadcasterState)
    func streamIsReady(preview: UIView?)
}

public class SPSIvsBroadcaster: NSObject {
   
    public weak var delegate: SPSBroadcasterDelegate?
    public var state : SPSBroadcasterState = .unknown
    
    private var session: IVSBroadcastSession?
    private var previewView: UIView?
    
    public func createStream(id: String) {
        requestVideoPermission(id: id)
    }
    
    public func startStream() {
        try? session?.start(with: URL(string: "rtmps://24406f8ae3f4.global-contribute.live-video.net:443/app/")!,
                       streamKey: "sk_eu-central-1_QwCF6hX4X1SZ_g2agBVjRV7zSjyTL4WLdoL9X9byL79")
    }
    
    public func stopStream() {
        session?.stop()
    }
    
    private func requestVideoPermission(id: String){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // permission already granted.
            requestAudioPermission(id: id)
        case .notDetermined:
           AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
               if granted {
                   self?.requestAudioPermission(id: id)
               }
           }
        case .denied, .restricted: // permission denied.
            break
        @unknown default: // permissions unknown.
            break
        }
    }
    
    private func requestAudioPermission(id: String){
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized: // permission already granted.
            setupStream(id: id)
        case .notDetermined:
           AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
               if granted {
                   self?.setupStream(id: id)
               }
           }
        case .denied, .restricted: // permission denied.
            break
        @unknown default: // permissions unknown.
            break
        }
    }
    
    private func setupStream(id: String) {
        session = try? IVSBroadcastSession(
            configuration: IVSPresets.configurations().basicPortrait(),
           descriptors: IVSPresets.devices().frontCamera(),
           delegate: self)
        guard let session else { return }
        session.awaitDeviceChanges { [weak self] in
            self?.generatePreview()
        }
        
    }
    
    private func generatePreview() {
        let devicePreview = try? session?.listAttachedDevices()
           .compactMap({ $0 as? IVSImageDevice })
           .first?
           .previewView()
        previewView = devicePreview
        delegate?.streamIsReady(preview: previewView)
    }
}

extension SPSIvsBroadcaster: IVSBroadcastSession.Delegate {
    
    public func broadcastSession(_ session: IVSBroadcastSession, didChange state: IVSBroadcastSession.State) {
        delegate?.stateUpdated(state: SPSBroadcasterState(avsState: state))
        self.state = SPSBroadcasterState(avsState: state)
    }
    
    public func broadcastSession(_ session: IVSBroadcastSession, didEmitError error: Error) {
        
    }
 
}
