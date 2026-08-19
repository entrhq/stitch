import XCTest
@testable import Stitch

/// Registration writes static state that lives for the process, so each test that registers
/// uses its own `Stitchable`.
@MainActor
@Stitchify(by: CountedTestProtocol.self)
final class ApplicationScopedObject: CountedTestProtocol {
    let id = InstanceCounter.next()
    init() {}
}

@MainActor
@Stitchify(by: CountedTestProtocol.self)
final class ApplicationScopedFactoryObject: CountedTestProtocol {
    let id = InstanceCounter.next()
    init() {}
}

@MainActor
@Stitchify(by: CountedTestProtocol.self)
final class ApplicationScopedKeyRegistrationObject: CountedTestProtocol {
    let id = InstanceCounter.next()
    init() {}
}

@MainActor
final class ApplicationScopeTests: XCTestCase {
    // MARK: - Resolution
    func testResolveReturnsTheSameInstanceEveryTime() {
        let first = ApplicationScopedObject.resolve()
        let second = ApplicationScopedObject.resolve()

        XCTAssertEqual(first.id, second.id)
    }

    func testResolveIgnoresAContextKey() {
        let unkeyed = ApplicationScopedObject.resolve()

        // Check that a key does not create a separate instance
        XCTAssertEqual(ApplicationScopedObject.resolve(key: "a").id, unkeyed.id)
        XCTAssertEqual(ApplicationScopedObject.resolve(key: "b").id, unkeyed.id)
    }

    // MARK: - Registration
    func testRegisteringAFactoryReplacesTheHeldInstance() {
        ApplicationScopedFactoryObject.register { MockCountedObject() }

        let resolved = ApplicationScopedFactoryObject.resolve()

        XCTAssertTrue(resolved is MockCountedObject)
        // Check that the registered instance is reused
        XCTAssertEqual(ApplicationScopedFactoryObject.resolve().id, resolved.id)
    }

    func testRegisteringAFactoryInstantiatesImmediately() {
        ApplicationScopedFactoryObject.register { MockCountedObject() }

        // Check that registration created the instance without waiting for a resolve
        XCTAssertNotNil(ApplicationScopedFactoryObject.instances[defaultScopeContextKey])
    }

    func testRegisteringWithAKeyFallsBackToTheDefaultRegistration() {
        ApplicationScopedKeyRegistrationObject.register(key: "ignored") { MockCountedObject() }

        // Check that the factory was registered on the default context and not the key
        XCTAssertTrue(ApplicationScopedKeyRegistrationObject.resolve() is MockCountedObject)
        XCTAssertNil(ApplicationScopedKeyRegistrationObject.instances["ignored"])
    }
}
