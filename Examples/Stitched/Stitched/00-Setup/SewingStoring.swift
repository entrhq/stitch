//
//  SewingStoring.swift
//  Stitched
//
//  Created by Justin Wilkin on 10/4/2023.
//

import Stitch
import Combine

protocol SewingStoring: ObservableObject, AnyObservableObject {
    var stitches: [SewingStitch] { get set }
    func fetchStitches() async
    func addStitch()
}

extension DependencyMap {
    private struct SewingStoreKey: DependencyKey {
        static var dependency: any SewingStoring = SewingStore()
    }
    
    var store: any SewingStoring {
        get { resolve(key: SewingStoreKey.self) }
        set { register(key: SewingStoreKey.self, dependency: newValue) }
    }
}
