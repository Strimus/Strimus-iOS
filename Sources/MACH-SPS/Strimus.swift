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
    
    private var key: String?
    private var secret: String?
    private var token: String?
    private var clientId: String?
    private var uniqueId: String?
    
    public func configure(key: String) {
        self.key = key
    }
    
    public func authenticateStreamer(clientId: String, uniqueId: String, secret: String) {
        guard let key else {
            print("Strimus.shared.configure(key:) not called, please configure sdk before authentication")
            return
        }
        self.clientId = clientId
        self.uniqueId = uniqueId
        self.secret = secret
        authRequest(clientId: clientId, uniqueId: uniqueId, secret: secret, key: key)
    }
    
    private func authRequest(clientId: String, uniqueId: String, secret: String, key: String) {
        Task {
            do {
                let client = SBSClient<SBSResponse<SBSAuthResponse>>()
                let parametes = ["clientId": clientId,
                                 "uniqueId": uniqueId,
                                 "secret": secret,
                                 "key": key]
                let response = try await client.performRequest(path: "",
                                                               method: .post,
                                                               parameters: parametes)
                self.token = response.data.token
            } catch {
                delegate?.authFailed(reason: error.localizedDescription)
            }
           
            
        }
    }
}
