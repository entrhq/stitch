import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

/// A dependency binding declared in a `StitchValues` extension
private struct Binding {
    let accessor: String
    let dependency: String
    let factory: String
    let scoped: String
    
    var container: String { accessor.prefix(1).uppercased() + accessor.dropFirst() + "Container" }
}

public struct StitchModuleMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try declaration.memberBlock.members
            .compactMap { try binding(from: $0.decl) }
            .flatMap(members(for:))
    }
    
    private static func members(for binding: Binding) -> [DeclSyntax] {
        [
            """
            struct \(raw: binding.container): Stitchable {
                typealias Dependency = \(raw: binding.dependency)
                @MainActor static var scope: StitchableScope = \(raw: binding.scoped)
                @MainActor static var instance: Dependency? = nil
                @MainActor static var factory: DependencyFactory = { \(raw: binding.factory) }
            }
            """,
            """
            @MainActor var \(raw: binding.accessor): \(raw: binding.dependency) {
                get { \(raw: binding.container).resolve() }
                set { \(raw: binding.container).register { newValue } }
            }
            """,
        ]
    }
    
    private static func binding(from declaration: DeclSyntax) throws -> Binding? {
        guard let attributes = declaration.asProtocol(WithAttributesSyntax.self),
              let attribute = attributes.attributes.stitchBinding else { return nil }
        guard let declared = declaration.asProtocol(NamedDeclSyntax.self) else { throw StitchifyError.invalidType }
        
        var arguments = LabeledExprListSyntax()
        if case .argumentList(let list) = attribute.arguments { arguments = list }
        
        let given = name(in: arguments)
        let source = try source(of: declaration, arguments: arguments)
        
        return Binding(
            accessor: given ?? accessor(from: declared.name.text),
            dependency: source.dependency,
            factory: source.factory,
            scoped: scope(in: arguments)
        )
    }
    
    /// Extracts the dependency a binding resolves and the expression that builds it
    private static func source(
        of declaration: DeclSyntax,
        arguments: LabeledExprListSyntax
    ) throws -> (dependency: String, factory: String) {
        // a typealias names its implementation, so the dependency comes from the attribute
        if let alias = declaration.as(TypeAliasDeclSyntax.self) {
            guard let dependency = arguments.first(where: { $0.label == nil })?.expression else {
                throw StitchifyError.invalidType
            }
            let implementation = "\(alias.initializer.value)".trimmed
            return ("any \("\(dependency)".strippingSelf)", "\(implementation)()")
        }
        
        // a provider names the dependency in its return clause and builds it in its body
        guard let provider = declaration.as(FunctionDeclSyntax.self),
              let returned = provider.signature.returnClause?.type else {
            throw StitchifyError.invalidType
        }
        return ("\(returned)".trimmed, "StitchValues.\(provider.name.text)()")
    }
    
    /// Reads the accessor name given by `as:`, which the macro requires as a string literal
    private static func name(in arguments: LabeledExprListSyntax) -> String? {
        let given = arguments.first { $0.label?.text == "as" }?.expression
        return given?.as(StringLiteralExprSyntax.self)?.segments.description
    }
    
    /// Reads the scope given by `scoped:`, which defaults to the application scope
    private static func scope(in arguments: LabeledExprListSyntax) -> String {
        guard let scoped = arguments.first(where: { $0.label?.text == "scoped" })?.expression else {
            return ".application"
        }
        return "\(scoped)"
    }
    
    /// Derives the accessor name from a declaration, truncating a `Binding` suffix
    private static func accessor(from name: String) -> String {
        let stripped = name.hasSuffix("Binding") ? String(name.dropLast("Binding".count)) : name
        return stripped.prefix(1).lowercased() + stripped.dropFirst()
    }
}

public struct StitchBindingMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] { [] }
}

private extension AttributeListSyntax {
    var stitchBinding: AttributeSyntax? {
        lazy.compactMap { $0.as(AttributeSyntax.self) }
            .first { "\($0.attributeName)" == "StitchBinding" }
    }
}

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    var strippingSelf: String { replacingOccurrences(of: ".self", with: "") }
}
