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

    func testResolveDoesNotStoreTheInstance() {
        _ = UniqueScopedObject.resolve()

        // Check that no instance was stored
        XCTAssertNil(UniqueScopedObject.instance)
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
        XCTAssertNil(UniqueScopedFactoryObject.instance)
    }

    func testRegisteringAnInstancePinsEveryResolve() {
        let pinned = MockCountedObject()
        UniqueScopedInstanceObject.register { pinned }

        // Check that every resolve returns the registered instance
        XCTAssertEqual(UniqueScopedInstanceObject.resolve().id, pinned.id)
        XCTAssertEqual(UniqueScopedInstanceObject.resolve().id, pinned.id)
    }
}
