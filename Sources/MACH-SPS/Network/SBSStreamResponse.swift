//
//  SBSStreamResponse.swift
//  
//
//  Created by Machina on 22.05.2023.
//

import Foundation

public struct SBSStream: Codable {
    public let id: Int
    public let streamData: SBSStreamData
    public let url: URL?
}

public struct SBSStreamData: Codable {
    public let uniqueId: String
    public let name: String?
    public let image: URL?
}
