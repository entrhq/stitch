//
//  SewingFormatting.swift
//  Stitched
//
//  Created by Justin Wilkin on 31/8/2026.
//

protocol SewingFormatting {
    func format(_ stitch: SewingStitch) -> String
}

struct ShortSewingFormatter: SewingFormatting {
    func format(_ stitch: SewingStitch) -> String {
        stitch.name
    }
}

struct DetailedSewingFormatter: SewingFormatting {
    func format(_ stitch: SewingStitch) -> String {
        "\(stitch.name), \(stitch.difficulty). \(stitch.usecase)"
    }
}
