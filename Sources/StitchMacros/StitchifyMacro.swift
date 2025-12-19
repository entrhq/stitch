import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftCompilerPlugin

enum StitchifyError: Error {
    case invalidType
    case invalidScope
}

public struct StitchifyMacro: MemberMacro, ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declared = declaration.asProtocol(NamedDeclSyntax.self) else { return [] }
        let name = declared.name
        
        // Determine access level from the declaration
        let accessLevel = extractAccessLevel(from: declaration)
        
        // Extract args
        var arguments: LabeledExprListSyntax?
        if case .argumentList(let args) = node.arguments { arguments = args }
        
        // Extract our key if provided and strip .self, otherwise default to declared name
        let keyExpression = arguments?.first { $0.label?.text == "by" }?.expression
        let key = "\(keyExpression != nil ? "any \(keyExpression!)" : name)".replacingOccurrences(of: ".self", with: "")
        let scoped = arguments?.first { $0.label?.text == "scoped" }?.expression ?? ".application"
        
        // add our dependency management properties and functionality
        let scope: DeclSyntax = "@MainActor \(raw: accessLevel)static var scope: StitchableScope = \(raw: scoped)"
        let dependency: DeclSyntax = "@MainActor \(raw: accessLevel)static var dependency: \(raw: key) = createNewInstance()"
        let new: DeclSyntax = "\(raw: accessLevel)static func createNewInstance() -> \(raw: key) { \(name)() }"
        
        return [scope, dependency, new]
    }
    
    /// Extracts the access level modifier from a declaration's modifiers
    private static func extractAccessLevel(from declaration: some DeclGroupSyntax) -> String {
        let modifiers = declaration.modifiers
        
        return modifiers.first { modifier in
            switch modifier.name.tokenKind {
            case .keyword(.public), .keyword(.private), .keyword(.fileprivate), 
                 .keyword(.internal), .keyword(.package):
                return true
            default:
                return false
            }
        }.map { "\($0.name.text) " } ?? ""
    }
    
    // stitchable protocol conformance
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let declared = declaration.asProtocol(NamedDeclSyntax.self) else { return [] }
        let name = declared.name
        
        // add stitchable conformance
        let base = [try ExtensionDeclSyntax("extension \(name): Stitchable {}")]
        guard case .argumentList(_) = node.arguments else { return base }
        return base
    }
}
