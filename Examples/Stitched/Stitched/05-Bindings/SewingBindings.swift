//
//  SewingBindings.swift
//  Stitched
//
//  Created by Justin Wilkin on 31/8/2026.
//

import Stitch

/// Binding a protocol to an implementation gives it a key path on `StitchValues`, which you use
/// to inject it. Two bindings of one protocol resolve two separate dependencies.
@StitchModule
extension StitchValues {
    @StitchBinding(SewingFormatting.self)
    typealias ShortFormatterBinding = ShortSewingFormatter
    
    @StitchBinding(SewingFormatting.self, as: "detailedFormatter")
    typealias DetailedFormatterBinding = DetailedSewingFormatter
}
