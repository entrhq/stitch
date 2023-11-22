//
//  BindMacro.swift
//  
//
//  Created by Justin Wilkin on 22/11/2023.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftCompilerPlugin

public struct BindMacro: MemberMacro {
//    public static func expansion(
//        of node: SwiftSyntax.AttributeSyntax,
//        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
//        in context: some SwiftSyntaxMacros.MacroExpansionContext
//    ) throws -> [DeclSyntax] {
//        return [
//            """
//            struct SomethingDependency {
//                private struct Key: DependencyKey {
//                    static var dependency: any SomeProtocol = OtherSomeStruct()
//                }
//                var value: any SomeProtocol {
//                    get { resolve(key: Key.self) }
//                    set { register(key: Key.self, dependency: newValue) }
//                }
//            }
//            """
//        ]
//    }
    
//    public static func expansion(
//        of node: AttributeSyntax,
//        providingMembersOf declaration: some DeclGroupSyntax,
//        in context: some MacroExpansionContext
//    ) throws -> [DeclSyntax] {
//        return [
//            """
//            private struct Key: DependencyKey {
//                static var dependency: any SomeProtocol = OtherSomeStruct()
//            }
//            var value: any SomeProtocol {
//                get { resolve(key: Key.self) }
//                set { register(key: Key.self, dependency: newValue) }
//            }
//            """
//        ]
//    }
    
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
        
        let dependencyKey: DeclSyntax = """
        private struct Key: DependencyKey {
            static var dependency: any SomeProtocol = OtherSomeStruct()
        }
        """
        
        let dependency: DeclSyntax = """
        var value: any SomeProtocol {
            get { resolve(key: Key.self) }
            set { register(key: Key.self, dependency: newValue) }
        }
        """
        
        return [dependencyKey, dependency]
    }
}
