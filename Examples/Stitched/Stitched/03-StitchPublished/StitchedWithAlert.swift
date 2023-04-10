//
//  StitchedWithAlert.swift
//  Stitched
//
//  Created by Justin Wilkin on 10/4/2023.
//

import Stitch
import SwiftUI

struct StitchedWithAlert: View {
    @StitchObservable(\.store) var store
    @StitchObservable(\.alertStore) var alertStore
    
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
        .alert(isPresented: $alertStore.showAlert) {
            alertStore.alert ?? Alert(title: Text("Something went wrong"))
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

struct StitchedWithAlert_Previews: PreviewProvider {
    static var previews: some View {
        StitchedWithAlert()
    }
}

