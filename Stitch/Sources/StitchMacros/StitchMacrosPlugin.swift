//
//  StitchMacrosPlugin.swift
//
//
//  Created by Justin Wilkin on 22/11/2023.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftCompilerPlugin


@main
struct StitchMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StitchifyMacro.self,
        BindMacro.self,
    ]
}
