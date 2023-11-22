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
