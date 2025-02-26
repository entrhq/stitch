//
//  SewingStore.swift
//  Stitched
//
//  Created by Justin Wilkin on 10/4/2023.
//

import Stitch
import Combine

@Stitchify(by: SewingStoring.self)
class SewingStore: SewingStoring {
    @Stitch(SewingRepository.self) private var repository
    @Published var stitches: [SewingStitch] = []
    @Published var other: String = ""
    
    func fetchStitches() async {
        guard let stitches = try? await repository.fetchStitches() else { return }
        self.stitches = stitches
    }
    
    func addStitch() {
        stitches.append(
            SewingStitch(
                name: "Running stitch",
                difficulty: "easy",
                usecase: "Best for beginners and basic projects"
            )
        )
    }
    
    required init() {}
}
