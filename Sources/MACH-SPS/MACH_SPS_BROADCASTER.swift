//
//  File.swift
//  
//
//  Created by Machina on 29.05.2023.
//

import UIKit
import Foundation
import AVFoundation

public protocol SPSBroadcasterDelegate: AnyObject {
    func stateUpdated(state: SPSBroadcasterState)
    func streamIsReady(preview: UIView?)
}

public class SPSBroadcaster: UIView {
   
    public func getBroadcasterView(source: BroadcastSource) -> SPSBroadcasterView {
       switch source {
        case .aws:
            return SPSIvsBroadcaster()
        case .mux:
            return SPSMuxBroadcaster()
       case .erstream:
           return SPSErstreamBroadcaster()
       case .agora:
           return SPSAgoraBroadcaster()
       }

    }
    
    deinit {
        print("")
    }
}

public class SPSBroadcasterView: NSObject {
    public weak var delegate: SPSBroadcasterDelegate?
    public var state : SPSBroadcasterState = .unknown
    
    var streamURL: URL?
    var streamKey: String?
    var streamId: Int?
    var appId: String?
    var token: String?
    var channelName: String?
    var previewView: UIView?
    
    public func createStream(source: BroadcastSource) {
        Task {
            do {
                let data = try await Strimus.shared.createStream(source: source)
                streamURL = data.streamUrl
                streamKey = data.streamKey
                streamId = data.id
                appId = data.appId
                token = data.token
                channelName = data.channelName
                requestVideoPermission()
            } catch {
                print("error while creating stream: \(error.localizedDescription)")
            }
        }
        
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
    
    func setupStream() { }
    
    public func startStream() { }
    
    public func stopStream() { }
    
    deinit {
        print("")
    }
}
