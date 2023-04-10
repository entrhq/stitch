//
//  SewingStore.swift
//  Stitched
//
//  Created by Justin Wilkin on 10/4/2023.
//

import Stitch
import Combine

class SewingStore: SewingStoring {
    @Stitch(\.repository) private var repository
    
    @Published var stitches: [SewingStitch] = []
    
    @MainActor
    func fetchStitches() async {
        guard let stitches = try? await repository.fetchStitches() else { return }
        self.stitches = stitches
    }
    
    @MainActor
    func addStitch() {
        stitches.append(
            SewingStitch(
                name: "Running stitch",
                difficulty: "easy",
                usecase: "Best for beginners and basic projects"
            )
        )
    }
}
