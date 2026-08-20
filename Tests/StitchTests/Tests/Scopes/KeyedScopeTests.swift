import XCTest
@testable import Stitch

@MainActor
@Stitchify(by: CountedTestProtocol.self, scoped: .keyed)
final class KeyedScopedObject: CountedTestProtocol {
    let id = InstanceCounter.next()
    init() {}
}

@MainActor
@Stitchify(by: CountedTestProtocol.self, scoped: .keyed)
final class KeyedScopedDefaultFactoryObject: CountedTestProtocol {
    let id = InstanceCounter.next()
    init() {}
}

@MainActor
@Stitchify(by: CountedTestProtocol.self, scoped: .keyed)
final class KeyedScopedKeyFactoryObject: CountedTestProtocol {
    let id = InstanceCounter.next()
    init() {}
}

@MainActor
final class KeyedScopeTests: XCTestCase {
    // MARK: - Resolution
    func testResolveCreatesOneInstancePerKey() {
        let first = KeyedScopedObject.resolve(key: "per-key-a")
        let second = KeyedScopedObject.resolve(key: "per-key-b")

        XCTAssertNotEqual(first.id, second.id)
    }

    func testResolveReturnsTheSameInstanceForTheSameKey() {
        let first = KeyedScopedObject.resolve(key: "same-key")
        let second = KeyedScopedObject.resolve(key: "same-key")

        XCTAssertEqual(first.id, second.id)
    }

    func testResolveWithoutAKeyUsesTheDefaultContext() {
        let unkeyed = KeyedScopedObject.resolve()

        XCTAssertEqual(KeyedScopedObject.instances[defaultScopeContextKey]?.id, unkeyed.id)
    }

    func testResolveBuildsFromTheDefaultFactoryForAnUnregisteredKey() {
        // Check that an unregistered key builds from the default factory
        XCTAssertFalse(KeyedScopedObject.resolve(key: "unregistered") is MockCountedObject)
    }

    // MARK: - Registration
    func testRegisteringADefaultFactoryAppliesToUnregisteredKeys() {
        KeyedScopedDefaultFactoryObject.register { MockCountedObject() }

        // Check that a key with no factory of its own builds from the new default
        XCTAssertTrue(KeyedScopedDefaultFactoryObject.resolve(key: "fresh") is MockCountedObject)
    }

    func testRegisteringAFactoryForAKeyAppliesOnlyToThatKey() {
        KeyedScopedKeyFactoryObject.register(key: "mocked") { MockCountedObject() }

        XCTAssertTrue(KeyedScopedKeyFactoryObject.resolve(key: "mocked") is MockCountedObject)
        XCTAssertFalse(KeyedScopedKeyFactoryObject.resolve(key: "unmocked") is MockCountedObject)
    }

    func testRegisteringAFactoryForAKeyReplacesItsInstance() {
        let before = KeyedScopedKeyFactoryObject.resolve(key: "replaced")
        KeyedScopedKeyFactoryObject.register(key: "replaced") { MockCountedObject() }
        let after = KeyedScopedKeyFactoryObject.resolve(key: "replaced")

        XCTAssertNotEqual(before.id, after.id)
        XCTAssertTrue(after is MockCountedObject)
    }
}
