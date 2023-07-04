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
    public func getStreams(type: StreamListType) async throws -> [SBSStream] {
        let client = SBSClient<SBSResponse<[SBSStream]>>()
        
        let result = try await client.performRequest(path: "/streams?type=\(type.rawValue)",
                                        method: .get,
                                        parameters: nil)
        
        return result.data
    }
    
    //MARK: Completion Block
    public func getStreams(type: StreamListType, completion: @escaping ([SBSStream]?, Error?) -> Void) {
        Task {
            do {
                let streams = try await getStreams(type: type)
                if type == .past {
                    let filteredStreams = streams.filter({ $0.videos?.first != nil })
                    completion(filteredStreams, nil)
                } else {
                    completion(streams, nil)
                }
            } catch {
                completion(nil, error)
            }
        }
    }
    //MARK: - Broadcaster -
    //MARK: Concurrency
    public func createStream(source: BroadcastSource) async throws -> SBSBroadcastData {
        let client = SBSClient<SBSResponse<SBSBroadcastData>>()
        
        let parameters: [String:Any] = ["source": source.getLabel(),
                          "streamData": ["uniqueId": uniqueId]]
        
        let result = try await client.performRequest(path: "/stream",
                                        method: .post,
                                        parameters: parameters)
        
        return result.data
    }
    
    public func stopStream(id: Int) async throws {
        let client = SBSClient<SBSResponse<SBSStopBroadcastData>>()
        
        let _ = try await client.performRequest(path: "/stream/\(id)",
                                        method: .delete,
                                        parameters: nil)
        
    }
    
    func getAgoraSubscriberToken(streamId: String) async throws -> SBSSubscriber {
        let client = SBSClient<SBSResponse<SBSSubscriber>>()
        
        let response = try await client.performRequest(path: "/subscriber/\(streamId)?uid=0",
                                        method: .get,
                                        parameters: nil)
        return response.data
    }
    
}
