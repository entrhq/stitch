//
//  SewingStitch.swift
//  Stitched
//
//  Created by Justin Wilkin on 10/4/2023.
//

import Foundation

struct SewingStitch: Decodable {
    var id: String = UUID().uuidString
    var name: String
    var difficulty: String
    var usecase: String
}
