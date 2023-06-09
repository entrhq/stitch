//
//  StitchedMockedPreview.swift
//  Stitched
//
//  Created by Justin Wilkin on 10/4/2023.
//

import Stitch
import SwiftUI

struct StitchedMockedPreview: PreviewProvider, DependencyMocker {
    class MockSewingStore: SewingStoring {
        @Published var stitches: [SewingStitch] =
            [
                SewingStitch(
                    name: "Running stitch",
                    difficulty: "easy",
                    usecase: "Best for beginners and basic projects"
                )
            ]
        
        func fetchStitches() async {}
        func addStitch() {}
    }
    
    static var previews: some View {
        mockInViewScope(\.store, mock: MockSewingStore())
        StitchedView()
    }
}

