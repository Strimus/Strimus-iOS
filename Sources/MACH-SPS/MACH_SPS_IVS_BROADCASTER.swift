//
//  File.swift
//  
//
//  Created by Machina on 17.05.2023.
//

import AmazonIVSBroadcast

public class SPSIvsBroadcaster: SPSBroadcasterView {
   
    private var session: IVSBroadcastSession?
    
    override func setupStream() {
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
    
    public override func startStream() {
        guard let url = streamURL else { return }
        guard let key = streamKey else { return }
        try? session?.start(with: url,
                       streamKey: key)
    }
    
    public override func stopStream() {
        session?.stop()
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
