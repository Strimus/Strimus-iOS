//
//  File.swift
//  
//
//  Created by Machina on 22.05.2023.
//

import Foundation

enum SBSMethod: String {
    case get = "GET"
    case post = "POST"
}

class SBSClient<T:Codable> {
    
    let baseURL = "http://164.92.178.132:5555"
    
    func performRequest(path: String, method: SBSMethod, parameters: [String: Any]?) async throws -> T {
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
       
        if let key = Strimus.shared.key {
            request.addValue(key, forHTTPHeaderField: "key")
        }
        
        if let token = Strimus.shared.token {
            request.addValue(token, forHTTPHeaderField: "token")
        }
        
        if let parameters, parameters.isEmpty == false {
            let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
            request.httpBody = jsonData
        }
        
        let result = try await URLSession.shared.data(for: request)
        let res = try JSONDecoder().decode(T.self, from: result.0)
        return res
    }
    
    
}
