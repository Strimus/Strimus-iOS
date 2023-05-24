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
    
    private var streamURL: URL?
    private var streamKey: String?
    
    public func createStream() {
        Task {
            do {
                let data = try await Strimus.shared.createStream()
                streamURL = data.streamUrl
                streamKey = data.streamKey
            } catch {
                print("error while creating stream: \(error.localizedDescription)")
            }
        }
        
        requestVideoPermission()
    }
    
    public func startStream() {
        guard let url = streamURL else { return }
        guard let key = streamKey else { return }
        try? session?.start(with: url,
                       streamKey: key)
    }
    
    public func stopStream() {
        session?.stop()
    }
    
    private func requestVideoPermission(){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // permission already granted.
            requestAudioPermission()
        case .notDetermined:
           AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
               if granted {
                   self?.requestAudioPermission()
               }
           }
        case .denied, .restricted: // permission denied.
            break
        @unknown default: // permissions unknown.
            break
        }
    }
    
    private func requestAudioPermission(){
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized: // permission already granted.
            setupStream()
        case .notDetermined:
           AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
               if granted {
                   self?.setupStream()
               }
           }
        case .denied, .restricted: // permission denied.
            break
        @unknown default: // permissions unknown.
            break
        }
    }
    
    private func setupStream() {
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
