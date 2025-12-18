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

                @MainActor static var scope: StitchableScope = .application

                @MainActor static var dependency: SomeStruct  = createNewInstance()

                static func createNewInstance() -> SomeStruct  {
                    SomeStruct ()
                }
            }

            extension SomeStruct : Stitchable {
            }
            """,
            macros: testMacros
        )
    }
    
    func testStitchifyExpandsWithScopedArgument() {
        assertMacroExpansion(
            """
            @Stitchify(scoped: .unique)
            struct SomeStruct {
                var property: String = "test"
            }
            """,
            expandedSource: """
            
            struct SomeStruct {
                var property: String = "test"

                @MainActor static var scope: StitchableScope = .unique

                @MainActor static var dependency: SomeStruct  = createNewInstance()

                static func createNewInstance() -> SomeStruct  {
                    SomeStruct ()
                }
            }

            extension SomeStruct : Stitchable {
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

                @MainActor static var scope: StitchableScope = .application

                @MainActor static var dependency: any SomeProtocol = createNewInstance()

                static func createNewInstance() -> any SomeProtocol {
                    SomeStruct ()
                }
            }

            extension SomeStruct : Stitchable {
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

                @MainActor static var scope: StitchableScope = .cached

                @MainActor static var dependency: SomeStruct  = createNewInstance()

                static func createNewInstance() -> SomeStruct  {
                    SomeStruct ()
                }
            }

            extension SomeStruct : Stitchable {
            }
            """,
            macros: testMacros
        )
    }
}
