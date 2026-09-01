//
//  StitchedWithBindings.swift
//  Stitched
//
//  Created by Justin Wilkin on 31/8/2026.
//

import Stitch
import SwiftUI

struct StitchedWithBindings: View {
    @StitchObservable(SewingStore.self) var store
    @Stitch(\.shortFormatter) var short
    @Stitch(\.detailedFormatter) var detailed
    
    var body: some View {
        List {
            Section("Short") {
                ForEach(store.stitches, id: \.id) { stitch in
                    Text(short.format(stitch))
                }
            }
            
            Section("Detailed") {
                ForEach(store.stitches, id: \.id) { stitch in
                    Text(detailed.format(stitch))
                }
            }
        }
        .task {
            await store.fetchStitches()
        }
    }
}

struct StitchedWithBindings_Previews: PreviewProvider {
    static var previews: some View {
        StitchedWithBindings()
    }
}
