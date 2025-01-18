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
