//
//  SewingRepository.swift
//  Stitched
//
//  Created by Justin Wilkin on 10/4/2023.
//

import Stitch
import Foundation

/// Creating a stitchified dependency using .unique will result in a new dependency returned
/// for each dependency injection. This is useful for stateless objects, or when state should be local
/// to each injection location.
@Stitchify(scoped: .unique)
struct SewingRepository {
    enum SewingError: Error {
        case notFound
        case noStitches
    }
    
    func fetchStitches() async throws -> [SewingStitch] {
        try await Task.sleep(nanoseconds: 1_000_000_000) // Sleep simulate network
        guard let data = try readSewingFile() else { throw SewingError.noStitches }
        return try JSONDecoder().decode([SewingStitch].self, from: data)
    }
    
    private func readSewingFile() throws -> Data? {
        guard let file = Bundle.main.path(forResource: "stitches", ofType: "json") else {
            throw SewingError.notFound
        }
        return try String(contentsOfFile: file).data(using: .utf8)
    }
}
