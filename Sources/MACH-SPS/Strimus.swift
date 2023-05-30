//
//  File.swift
//  
//
//  Created by Machina on 22.05.2023.
//

import Foundation

public protocol StrimusDelegate: AnyObject {
    func authSuccess()
    func authFailed(reason: String)
}

public class Strimus {
    
    public static let shared = Strimus()
    public weak var delegate: StrimusDelegate?
    
    var key: String?
    var token: String?
    var uniqueId: String?
    
    //MARK: - Configuration -
    public func configure(key: String) {
        self.key = key
       
    }
    
    public func setStreamerData(uniqueId: String?, streamerToken: String?) {
        self.uniqueId = uniqueId
        self.token = streamerToken
    }
    
    //MARK: - Player -
    //MARK: Concurrency
    public func getStreams() async throws -> [SBSStream] {
        let client = SBSClient<SBSResponse<[SBSStream]>>()
        
        let result = try await client.performRequest(path: "/streams",
                                        method: .get,
                                        parameters: nil)
        
        return result.data
    }
    
    //MARK: Completion Block
    public func getStreams(completion: @escaping ([SBSStream]?, Error?) -> Void) {
        Task {
            do {
                let streams = try await getStreams()
                completion(streams, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    //MARK: - Broadcaster -
    //MARK: Concurrency
    public func createStream() async throws -> SBSBroadcastData {
        let client = SBSClient<SBSResponse<SBSBroadcastData>>()
        
        let parameters: [String:Any] = ["source": "mux",
                          "streamData": ["uniqueId": uniqueId]]
        
        let result = try await client.performRequest(path: "/stream",
                                        method: .post,
                                        parameters: parameters)
        
        return result.data
    }
    
}
