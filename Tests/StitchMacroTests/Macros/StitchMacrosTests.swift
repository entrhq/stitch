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

                typealias Dependency = SomeStruct

                @MainActor static var scope: StitchableScope = .application

                @MainActor static var instance: (SomeStruct )? = nil

                @MainActor static var factory: DependencyFactory = {
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

                typealias Dependency = SomeStruct

                @MainActor static var scope: StitchableScope = .unique

                @MainActor static var instance: (SomeStruct )? = nil

                @MainActor static var factory: DependencyFactory = {
                    SomeStruct ()
                }
            }

            extension SomeStruct : Stitchable {
            }
            """,
            macros: testMacros
        )
    }
    
    func testStitchifyExpandsWithByArgument() {
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

                typealias Dependency = any SomeProtocol

                @MainActor static var scope: StitchableScope = .application

                @MainActor static var instance: (any SomeProtocol)? = nil

                @MainActor static var factory: DependencyFactory = {
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
            
            @Stitchify(by: SomeProtocol.self, scoped: .unique)
            struct SomeStruct {
                var property: String = "test"
            }
            """,
            expandedSource: """
            protocol SomeProtocol {}
            struct SomeStruct {
                var property: String = "test"

                typealias Dependency = any SomeProtocol

                @MainActor static var scope: StitchableScope = .unique

                @MainActor static var instance: (any SomeProtocol)? = nil

                @MainActor static var factory: DependencyFactory = {
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

                public typealias Dependency = SomeStruct

                @MainActor public static var scope: StitchableScope = .application

                @MainActor public static var instance: (SomeStruct )? = nil

                @MainActor public static var factory: DependencyFactory = {
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

                public typealias Dependency = any SomeProtocol

                @MainActor public static var scope: StitchableScope = .application

                @MainActor public static var instance: (any SomeProtocol)? = nil

                @MainActor public static var factory: DependencyFactory = {
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

                private typealias Dependency = SomeStruct

                @MainActor private static var scope: StitchableScope = .application

                @MainActor private static var instance: (SomeStruct )? = nil

                @MainActor private static var factory: DependencyFactory = {
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

                fileprivate typealias Dependency = SomeStruct

                @MainActor fileprivate static var scope: StitchableScope = .application

                @MainActor fileprivate static var instance: (SomeStruct )? = nil

                @MainActor fileprivate static var factory: DependencyFactory = {
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

                package typealias Dependency = SomeStruct

                @MainActor package static var scope: StitchableScope = .application

                @MainActor package static var instance: (SomeStruct )? = nil

                @MainActor package static var factory: DependencyFactory = {
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

                public typealias Dependency = SomeEnum

                @MainActor public static var scope: StitchableScope = .application

                @MainActor public static var instance: (SomeEnum )? = nil

                @MainActor public static var factory: DependencyFactory = {
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

                public typealias Dependency = SomeActor

                @MainActor public static var scope: StitchableScope = .application

                @MainActor public static var instance: (SomeActor )? = nil

                @MainActor public static var factory: DependencyFactory = {
                    SomeActor ()
                }
            }

            extension SomeActor : Stitchable {
            }
            """,
            macros: testMacros
        )
    }

    func testStitchifyExpandsWithInternalAccessLevel() {
        assertMacroExpansion(
            """
            @Stitchify
            internal struct SomeStruct {
                var property: String = "test"
            }
            """,
            expandedSource: """

            internal struct SomeStruct {
                var property: String = "test"

                internal typealias Dependency = SomeStruct

                @MainActor internal static var scope: StitchableScope = .application

                @MainActor internal static var instance: (SomeStruct )? = nil

                @MainActor internal static var factory: DependencyFactory = {
                    SomeStruct ()
                }
            }

            extension SomeStruct : Stitchable {
            }
            """,
            macros: testMacros
        )
    }
    
    func testStitchifyExpandsOnFinalClassWithoutAccessLevel() {
        assertMacroExpansion(
            """
            @Stitchify
            final class SomeClass {
                init() {}
            }
            """,
            expandedSource: """

            final class SomeClass {
                init() {}

                typealias Dependency = SomeClass

                @MainActor static var scope: StitchableScope = .application

                @MainActor static var instance: (SomeClass )? = nil

                @MainActor static var factory: DependencyFactory = {
                    SomeClass ()
                }
            }

            extension SomeClass : Stitchable {
            }
            """,
            macros: testMacros
        )
    }
    
    func testStitchifyExpandsWithUniqueScopeAndProtocol() {
        assertMacroExpansion(
            """
            protocol SomeProtocol {}
            
            @Stitchify(by: SomeProtocol.self, scoped: .unique)
            public final class SomeClass: SomeProtocol {
                init() {}
            }
            """,
            expandedSource: """
            protocol SomeProtocol {}
            public final class SomeClass: SomeProtocol {
                init() {}

                public typealias Dependency = any SomeProtocol

                @MainActor public static var scope: StitchableScope = .unique

                @MainActor public static var instance: (any SomeProtocol)? = nil

                @MainActor public static var factory: DependencyFactory = {
                    SomeClass()
                }
            }

            extension SomeClass: Stitchable {
            }
            """,
            macros: testMacros
        )
    }
}
