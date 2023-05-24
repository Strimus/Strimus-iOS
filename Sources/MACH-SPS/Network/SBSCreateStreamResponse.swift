//
//  File.swift
//  
//
//  Created by Machina on 24.05.2023.
//

import Foundation

public struct SBSBroadcastData: Codable {
    public let id: Int
    public let source: String
    public let streamUrl: URL
    public let streamKey: String
}
