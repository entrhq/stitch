import XCTest
@testable import Stitch

/// `DependencyFactories` holds the factories a `Stitchable` builds instances from, tested here
/// without the static state a stitched type carries.
@MainActor
final class DependencyFactoriesTests: XCTestCase {
    func testSubscriptFallsBackToTheDefaultFactory() {
        let factories = DependencyFactories<String> { "default" }

        XCTAssertEqual(factories["unregistered"](), "default")
    }

    func testSubscriptReturnsTheFactoryRegisteredForAKey() {
        var factories = DependencyFactories<String> { "default" }
        factories["a"] = { "a-value" }

        XCTAssertEqual(factories["a"](), "a-value")
    }

    func testRegisteringAKeyLeavesOtherKeysOnTheDefault() {
        var factories = DependencyFactories<String> { "default" }
        factories["a"] = { "a-value" }

        XCTAssertEqual(factories["b"](), "default")
    }

    func testAssigningTheDefaultContextKeyReplacesTheDefaultFactory() {
        var factories = DependencyFactories<String> { "default" }
        factories[defaultScopeContextKey] = { "new-default" }

        // Check that keys with no factory of their own build from the new default
        XCTAssertEqual(factories["unregistered"](), "new-default")
        XCTAssertEqual(factories[defaultScopeContextKey](), "new-default")
    }
}
