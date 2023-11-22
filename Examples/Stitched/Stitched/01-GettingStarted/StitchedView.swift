//
//  StitchedView.swift
//  Stitched
//
//  Created by Justin Wilkin on 10/4/2023.
//

import Stitch
import SwiftUI

struct StitchedView: View {
    @StitchedObservable(SewingStore.self) var store
    
    var body: some View {
        List {
            ForEach(store.stitches, id: \.id) { stitch in
                cell(for: stitch)
            }
            
            Button(action: store.addStitch) {
                Text("Add another stitch")
                    .padding(.vertical)
                    .foregroundColor(.black)
            }
        }
        .task {
            await store.fetchStitches()
        }
    }
    
    func cell(for stitch: SewingStitch) -> some View {
        VStack(alignment: .leading) {
            Text(stitch.name)
                .font(.title3)
                .bold()
            
            Text(stitch.usecase)
                .font(.body)
            
            Text("Difficulty: \(stitch.difficulty)")
                .font(.callout)
                .opacity(0.6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct StitchedView_Previews: PreviewProvider {
    static var previews: some View {
        StitchedView()
    }
}
