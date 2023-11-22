import XCTest
import StitchMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

let testMacros: [String: Macro.Type] = [
    "Stitchify": StitchifyMacro.self,
]

final class StitchMacrosTests: XCTestCase {
    func testStitchifyExpandsNoArguments() {
        assertMacroExpansion(
            """
            @Stitchify
            struct SomeStruct {
                var property: String = "test"
            }
            """,
            expandedSource:"""
            
            struct SomeStruct {
                var property: String = "test"

                static var scope: StitchableScope = .application

                static var dependency: SomeStruct  = SomeStruct ()
            }

            extension SomeStruct: Stitchable {
            }
            """,
            macros: testMacros
        )
    }
    
    func testStitchifyExpandsWithScopedArgument() {
        assertMacroExpansion(
            """
            @Stitchify(scoped: .cached)
            struct SomeStruct {
                var property: String = "test"
            }
            """,
            expandedSource: """
            
            struct SomeStruct {
                var property: String = "test"

                static var scope: StitchableScope = .cached

                static var dependency: SomeStruct  = SomeStruct ()
            }

            extension SomeStruct: Stitchable {
            }
            """,
            macros: testMacros
        )
    }
    
    func testStitchifyExpandsWithKeyedArgument() {
        assertMacroExpansion(
            """
            protocol SomeProtocol {}
            
            @Stitchify(by: SomeProtocol.self)
            struct SomeStruct {
                var property: String = "test"
            }
            """,
            expandedSource: """
            protocol SomeProtocol {}
            struct SomeStruct {
                var property: String = "test"

                static var scope: StitchableScope = .application

                static var dependency: any SomeProtocol = SomeStruct ()
            }

            extension SomeStruct: Stitchable {
            }

            extension SomeStruct: SomeProtocol {
            }
            """,
            macros: testMacros
        )
    }
    
    func testStitchifyExpandsWithBothArguments() {
        assertMacroExpansion(
            """
            protocol SomeProtocol {}
            
            @Stitchify(type: SomeProtocol.self, scoped: .cached)
            struct SomeStruct {
                var property: String = "test"
            }
            """,
            expandedSource: """
            protocol SomeProtocol {}
            struct SomeStruct {
                var property: String = "test"

                static var scope: StitchableScope = .cached

                static var dependency: any SomeProtocol = SomeStruct ()
            }

            extension SomeStruct: Stitchable {
            }

            extension SomeStruct: SomeProtocol {
            }
            """,
            macros: testMacros
        )
    }
}
