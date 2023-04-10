//
//  StitchAlertStore.swift
//  Stitched
//
//  Created by Justin Wilkin on 10/4/2023.
//

import Stitch
import Combine
import SwiftUI

class StitchAlertStore: StitchAlertStoring {
    @StitchPublished(\.store) var store
    private var cancellable: AnyCancellable?
    
    @Published var showAlert: Bool = false
    var alert: Alert? {
        didSet {
            showAlert = alert != nil
        }
    }
    
    init() {
        cancellable = $store.stitches
            .map { $0.last }
            .sink { [weak self] stitch in
                guard let stitch, let self else { return }
                self.alert = Alert(
                    title: Text("New stitch"),
                    message: Text("A new stitch: '\(stitch.name)' has been added. Check it out now")
                )
            }
    }
}

/// - Note: A conformance to `Equatable` is required for us to observe changes on the object publisher
/// Only properties conforming to `Equatable` can be accessed through the $ prefix, due to the generic conformance
/// requirement of internal diffing in `@StitchPublished`.
extension SewingStitch: Equatable {
    static func == (lhs: SewingStitch, rhs: SewingStitch) -> Bool {
        lhs.name == rhs.name &&
        lhs.usecase == rhs.usecase &&
        lhs.difficulty == rhs.difficulty
    }
}
