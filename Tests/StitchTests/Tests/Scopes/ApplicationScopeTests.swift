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
final class ApplicationScopeTests: XCTestCase {
    // MARK: - Resolution
    func testResolveReturnsTheSameInstanceEveryTime() {
        let first = ApplicationScopedObject.resolve()
        let second = ApplicationScopedObject.resolve()

        XCTAssertEqual(first.id, second.id)
    }

    func testResolveStoresTheInstance() {
        let resolved = ApplicationScopedObject.resolve()

        // Check that the instance was kept for the next resolve
        XCTAssertEqual(ApplicationScopedObject.instance?.id, resolved.id)
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
        XCTAssertNotNil(ApplicationScopedFactoryObject.instance)
    }
}
