import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftCompilerPlugin

enum StitchifyError: Error {
    case invalidType
    case invalidScope
}

public struct StitchifyMacro: MemberMacro, ExtensionMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declared = declaration.asProtocol(NamedDeclSyntax.self) else { return [] }
        let name = declared.name
        
        // Extract args
        var arguments: LabeledExprListSyntax?
        if case .argumentList(let args) = node.arguments { arguments = args }
        
        // Extract our key if provided and strip .self, otherwise default to declared name
        let keyExpression = arguments?.first { $0.label?.text == "by" }?.expression
        let key = "\(keyExpression != nil ? "any \(keyExpression!)" : name)".replacingOccurrences(of: ".self", with: "")
        let scoped = arguments?.first { $0.label?.text == "scoped" }?.expression ?? ".application"
        
        let scope: DeclSyntax = "static var scope: StitchableScope = \(raw: scoped)"
        let dependency: DeclSyntax = "static var dependency: \(raw: key) = \(name)()"
        
        return [scope, dependency]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let declared = declaration.asProtocol(NamedDeclSyntax.self) else { return [] }
        let name = declared.name
        
        var base = [try ExtensionDeclSyntax("extension \(name): Stitchable {  }")]
        guard case let .argumentList(arguments) = node.arguments else { return base }
//        // Extract our key if provided and strip .self, otherwise default to declared name
//        let typeExpression = arguments.first { $0.label?.text == "by" }?.expression
//        let type = typeExpression?.description.replacingOccurrences(of: ".self", with: "")
//        if type != "nil" && type != nil { base.append(try ExtensionDeclSyntax("extension SomeStruct: \(raw: type!) {  }")) }
        return base
    }
    
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [DeclSyntax] {
        [
            """
            struct MyKey {
                static var dependency: any SomeProtocol { SomeStruct.resolve() }
            }
            """
        ]
    }
}
