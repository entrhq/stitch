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

                @MainActor static var instances: [ScopeContextKey: SomeStruct ] = [:]

                @MainActor static var factories: DependencyFactories<SomeStruct > = DependencyFactories {
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

                @MainActor static var instances: [ScopeContextKey: SomeStruct ] = [:]

                @MainActor static var factories: DependencyFactories<SomeStruct > = DependencyFactories {
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

                @MainActor static var instances: [ScopeContextKey: any SomeProtocol] = [:]

                @MainActor static var factories: DependencyFactories<any SomeProtocol> = DependencyFactories {
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
            
            @Stitchify(by: SomeProtocol.self, scoped: .keyed)
            struct SomeStruct {
                var property: String = "test"
            }
            """,
            expandedSource: """
            protocol SomeProtocol {}
            struct SomeStruct {
                var property: String = "test"

                @MainActor static var scope: StitchableScope = .keyed

                @MainActor static var instances: [ScopeContextKey: any SomeProtocol] = [:]

                @MainActor static var factories: DependencyFactories<any SomeProtocol> = DependencyFactories {
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

                @MainActor public static var instances: [ScopeContextKey: SomeStruct ] = [:]

                @MainActor public static var factories: DependencyFactories<SomeStruct > = DependencyFactories {
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

                @MainActor public static var instances: [ScopeContextKey: any SomeProtocol] = [:]

                @MainActor public static var factories: DependencyFactories<any SomeProtocol> = DependencyFactories {
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

                @MainActor private static var instances: [ScopeContextKey: SomeStruct ] = [:]

                @MainActor private static var factories: DependencyFactories<SomeStruct > = DependencyFactories {
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

                @MainActor fileprivate static var instances: [ScopeContextKey: SomeStruct ] = [:]

                @MainActor fileprivate static var factories: DependencyFactories<SomeStruct > = DependencyFactories {
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

                @MainActor package static var instances: [ScopeContextKey: SomeStruct ] = [:]

                @MainActor package static var factories: DependencyFactories<SomeStruct > = DependencyFactories {
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

                @MainActor public static var instances: [ScopeContextKey: SomeEnum ] = [:]

                @MainActor public static var factories: DependencyFactories<SomeEnum > = DependencyFactories {
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

                @MainActor public static var instances: [ScopeContextKey: SomeActor ] = [:]

                @MainActor public static var factories: DependencyFactories<SomeActor > = DependencyFactories {
                    SomeActor ()
                }
            }

            extension SomeActor : Stitchable {
            }
            """,
            macros: testMacros
        )
    }

    func testStitchifyExpandsWithKeyedScope() {
        assertMacroExpansion(
            """
            @Stitchify(scoped: .keyed)
            struct SomeStruct {
                var property: String = "test"
            }
            """,
            expandedSource: """

            struct SomeStruct {
                var property: String = "test"

                @MainActor static var scope: StitchableScope = .keyed

                @MainActor static var instances: [ScopeContextKey: SomeStruct ] = [:]

                @MainActor static var factories: DependencyFactories<SomeStruct > = DependencyFactories {
                    SomeStruct ()
                }
            }

            extension SomeStruct : Stitchable {
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

                @MainActor internal static var scope: StitchableScope = .application

                @MainActor internal static var instances: [ScopeContextKey: SomeStruct ] = [:]

                @MainActor internal static var factories: DependencyFactories<SomeStruct > = DependencyFactories {
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

                @MainActor static var scope: StitchableScope = .application

                @MainActor static var instances: [ScopeContextKey: SomeClass ] = [:]

                @MainActor static var factories: DependencyFactories<SomeClass > = DependencyFactories {
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

                @MainActor public static var scope: StitchableScope = .unique

                @MainActor public static var instances: [ScopeContextKey: any SomeProtocol] = [:]

                @MainActor public static var factories: DependencyFactories<any SomeProtocol> = DependencyFactories {
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
