import XCTest
@testable import Stitch

@MainActor
@Stitchify(by: CountedTestProtocol.self, scoped: .unique)
final class UniqueScopedObject: CountedTestProtocol {
    let id = InstanceCounter.next()
    init() {}
}

@MainActor
@Stitchify(by: CountedTestProtocol.self, scoped: .unique)
final class UniqueScopedFactoryObject: CountedTestProtocol {
    let id = InstanceCounter.next()
    init() {}
}

@MainActor
@Stitchify(by: CountedTestProtocol.self, scoped: .unique)
final class UniqueScopedInstanceObject: CountedTestProtocol {
    let id = InstanceCounter.next()
    init() {}
}

@MainActor
final class UniqueScopeTests: XCTestCase {
    // MARK: - Resolution
    func testResolveReturnsANewInstanceEveryTime() {
        let first = UniqueScopedObject.resolve()
        let second = UniqueScopedObject.resolve()

        XCTAssertNotEqual(first.id, second.id)
    }

    func testResolveDoesNotCacheInstances() {
        _ = UniqueScopedObject.resolve()

        // Check that no instance was stored
        XCTAssertTrue(UniqueScopedObject.instances.isEmpty)
    }

    func testResolveIgnoresAContextKey() {
        let first = UniqueScopedObject.resolve(key: "a")
        let second = UniqueScopedObject.resolve(key: "a")

        XCTAssertNotEqual(first.id, second.id)
    }

    // MARK: - Registration
    func testRegisteringAFactoryChangesWhatIsBuilt() {
        UniqueScopedFactoryObject.register { MockCountedObject() }

        let first = UniqueScopedFactoryObject.resolve()
        let second = UniqueScopedFactoryObject.resolve()

        XCTAssertTrue(first is MockCountedObject)
        // Check that each resolve still builds a new instance
        XCTAssertNotEqual(first.id, second.id)
    }

    func testRegisteringAFactoryDoesNotInstantiate() {
        UniqueScopedFactoryObject.register { MockCountedObject() }

        // Check that registration did not store an instance
        XCTAssertTrue(UniqueScopedFactoryObject.instances.isEmpty)
    }

    func testRegisteringAnInstancePinsEveryResolve() {
        let pinned = MockCountedObject()
        UniqueScopedInstanceObject.register { pinned }

        // Check that every resolve returns the registered instance
        XCTAssertEqual(UniqueScopedInstanceObject.resolve().id, pinned.id)
        XCTAssertEqual(UniqueScopedInstanceObject.resolve().id, pinned.id)
    }
}
