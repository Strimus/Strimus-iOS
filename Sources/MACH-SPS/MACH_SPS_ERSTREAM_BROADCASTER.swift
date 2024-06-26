//
//  MACH_SPS_ERSTREAM_BROADCASTER.swift
//  
//
//  Created by Sukru Kahraman on 26.02.2024.
//

import AmazonIVSBroadcast

public class SPSErstreamBroadcaster: SPSBroadcasterView {

    private var session: IVSBroadcastSession?
    
    override func setupStream() {
        session = try? IVSBroadcastSession(
            configuration: IVSPresets.configurations().basicPortrait(),
           descriptors: IVSPresets.devices().frontCamera(),
           delegate: self)
        guard let session else { return }
        session.awaitDeviceChanges { [weak self] in
            self?.setupPreview()
        }
        
    }
    
    private func setupPreview() {
        let devicePreview = try? session?.listAttachedDevices()
           .compactMap({ $0 as? IVSImageDevice })
           .first?
           .previewView()
        previewView = devicePreview
        delegate?.streamIsReady(preview: previewView)
    }
    
    public override func startStream() {
        guard let url = streamURL else { return }
        guard let key = streamKey else { return }
        try? session?.start(with: url,
                       streamKey: key)
    }
    
    public override func stopStream() {
        Task {
            if let id = streamId {
                try? await Strimus.shared.stopStream(id: id)
            }
            session?.stop()
        }
        
    }
}

extension SPSErstreamBroadcaster: IVSBroadcastSession.Delegate {
    
    public func broadcastSession(_ session: IVSBroadcastSession, didChange state: IVSBroadcastSession.State) {
        delegate?.stateUpdated(state: SPSBroadcasterState(avsState: state))
        self.state = SPSBroadcasterState(avsState: state)
    }
    
    public func broadcastSession(_ session: IVSBroadcastSession, didEmitError error: Error) {
        
    }
 
}
