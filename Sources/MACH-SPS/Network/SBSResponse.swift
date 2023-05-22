//
//  File.swift
//  
//
//  Created by Machina on 22.05.2023.
//

import Foundation

struct SBSResponse<T:Codable>: Codable {
    let success: Bool
    let code: Int
    let data: T
}
