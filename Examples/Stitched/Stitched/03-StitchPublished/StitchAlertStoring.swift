//
//  StitchAlertStore.swift
//  Stitched
//
//  Created by Justin Wilkin on 10/4/2023.
//

import Stitch
import SwiftUI

protocol StitchAlertStoring: ObservableObject, AnyObservableObject {
    var showAlert: Bool { get set }
    var alert: Alert? { get }
}

extension DependencyMap {
    private struct StitchAlertStoreKey: DependencyKey {
        static var dependency: any StitchAlertStoring = StitchAlertStore()
    }
    
    var alertStore: any StitchAlertStoring {
        get { resolve(key: StitchAlertStoreKey.self) }
        set { register(key: StitchAlertStoreKey.self, dependency: newValue) }
    }
}
