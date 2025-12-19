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
    
    func testStitchifyExpandsWithPublicAccessLevel() {
        assertMacroExpansion(
            """
            @Stitchify
            public struct SomeStruct {
                var property: String = "test"
            }
            """,
            expandedSource: """
            
            public struct SomeStruct {
                var property: String = "test"

                @MainActor public static var scope: StitchableScope = .application

                @MainActor public static var dependency: SomeStruct  = createNewInstance()

                public static func createNewInstance() -> SomeStruct  {
                    SomeStruct ()
                }
            }

            extension SomeStruct : Stitchable {
            }
            """,
            macros: testMacros
        )
    }
    
    func testStitchifyExpandsWithPublicAccessLevelAndProtocol() {
        assertMacroExpansion(
            """
            protocol SomeProtocol {}
            
            @Stitchify(by: SomeProtocol.self)
            public class SomeClass {
                init() {}
            }
            """,
            expandedSource: """
            protocol SomeProtocol {}
            public class SomeClass {
                init() {}

                @MainActor public static var scope: StitchableScope = .application

                @MainActor public static var dependency: any SomeProtocol = createNewInstance()

                public static func createNewInstance() -> any SomeProtocol {
                    SomeClass ()
                }
            }

            extension SomeClass : Stitchable {
            }
            """,
            macros: testMacros
        )
    }
    
    func testStitchifyExpandsWithPrivateAccessLevel() {
        assertMacroExpansion(
            """
            @Stitchify
            private struct SomeStruct {
                var property: String = "test"
            }
            """,
            expandedSource: """
            
            private struct SomeStruct {
                var property: String = "test"

                @MainActor private static var scope: StitchableScope = .application

                @MainActor private static var dependency: SomeStruct  = createNewInstance()

                private static func createNewInstance() -> SomeStruct  {
                    SomeStruct ()
                }
            }

            extension SomeStruct : Stitchable {
            }
            """,
            macros: testMacros
        )
    }
    
    func testStitchifyExpandsWithFileprivateAccessLevel() {
        assertMacroExpansion(
            """
            @Stitchify
            fileprivate struct SomeStruct {
                var property: String = "test"
            }
            """,
            expandedSource: """
            
            fileprivate struct SomeStruct {
                var property: String = "test"

                @MainActor fileprivate static var scope: StitchableScope = .application

                @MainActor fileprivate static var dependency: SomeStruct  = createNewInstance()

                fileprivate static func createNewInstance() -> SomeStruct  {
                    SomeStruct ()
                }
            }

            extension SomeStruct : Stitchable {
            }
            """,
            macros: testMacros
        )
    }
    
    func testStitchifyExpandsWithPackageAccessLevel() {
        assertMacroExpansion(
            """
            @Stitchify
            package struct SomeStruct {
                var property: String = "test"
            }
            """,
            expandedSource: """
            
            package struct SomeStruct {
                var property: String = "test"

                @MainActor package static var scope: StitchableScope = .application

                @MainActor package static var dependency: SomeStruct  = createNewInstance()

                package static func createNewInstance() -> SomeStruct  {
                    SomeStruct ()
                }
            }

            extension SomeStruct : Stitchable {
            }
            """,
            macros: testMacros
        )
    }
    
    func testStitchifyExpandsOnEnum() {
        assertMacroExpansion(
            """
            @Stitchify
            public enum SomeEnum {
                case value
            }
            """,
            expandedSource: """
            
            public enum SomeEnum {
                case value

                @MainActor public static var scope: StitchableScope = .application

                @MainActor public static var dependency: SomeEnum  = createNewInstance()

                public static func createNewInstance() -> SomeEnum  {
                    SomeEnum ()
                }
            }

            extension SomeEnum : Stitchable {
            }
            """,
            macros: testMacros
        )
    }
    
    func testStitchifyExpandsOnActor() {
        assertMacroExpansion(
            """
            @Stitchify
            public actor SomeActor {
                init() {}
            }
            """,
            expandedSource: """
            
            public actor SomeActor {
                init() {}

                @MainActor public static var scope: StitchableScope = .application

                @MainActor public static var dependency: SomeActor  = createNewInstance()

                public static func createNewInstance() -> SomeActor  {
                    SomeActor ()
                }
            }

            extension SomeActor : Stitchable {
            }
            """,
            macros: testMacros
        )
    }
}
