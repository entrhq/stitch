//
//  SewingInteractor.swift
//  Stitch
//
//  Created by Justin Wilkin on 20/1/2025.
//

import Stitch

/// Creating a stitchified dependency using .application will result in a single dependency returned
/// for all locations injected
@Stitchify(scoped: .application)
class SewingInteractor {
    @Stitch(SewingRepository.self) private var repository
    @Stitch(SewingStore.self) private var store
    
    func fetchStitches() async {
        guard let stitches = try? await repository.fetchStitches() else { return }
        store.stitches = stitches
    }
    
    func addStitch() {
        store.stitches.append(
            SewingStitch(
                name: "Running stitch",
                difficulty: "easy",
                usecase: "Best for beginners and basic projects"
            )
        )
    }
    
    required init() {}
}
