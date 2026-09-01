import XCTest
import Combine
@testable import Stitch

/// You resolve a binding declared in a `StitchValues` extension with its key path.
@MainActor
final class StitchBindingTests: XCTestCase {
    @Stitch(\.boundTest) private var bound
    @Stitch(\.uniqueBoundTest) private var unique
    @Stitch(\.secondBoundTest) private var second
    @Stitch(\.registeredBoundTest) private var registered
    @Stitch(\.factoryBoundTest) private var factoryBound
    @StitchObservable(\.boundObservable) private var observable
    @StitchPublished(\.boundPublished) private var published
    @StitchObservable(\.projectedObservable) private var projected

    // MARK: - Resolution
    func testTypeAliasBindingResolvesItsImplementation() {
        XCTAssertEqual(bound.name, "default")
    }

    func testProviderBindingResolvesWhatItReturns() {
        XCTAssertEqual(unique.name, "configured(unique)")
    }

    func testEachBindingHoldsItsOwnDependency() {
        // Check that two bindings of one protocol resolve separately
        XCTAssertEqual(bound.name, "default")
        XCTAssertEqual(second.name, "mock")
    }

    func testStitchObservableResolvesABinding() {
        XCTAssertEqual(observable.value, "observed")
    }

    func testStitchPublishedResolvesABinding() {
        XCTAssertEqual(published.value, "observed")
    }

    func testStitchObservableProjectsABindingForABoundDependency() {
        $projected.value.wrappedValue = "bound"

        XCTAssertEqual(projected.value, "bound")
    }

    // MARK: - Registration
    func testAssigningThroughTheWrapperRegisters() {
        registered = MockBoundObject()

        XCTAssertEqual(registered.name, "mock")
    }

    func testRegisteringAFactoryOnTheContainerReplacesTheImplementation() {
        StitchValues.FactoryBoundTestContainer.register { ConfiguredBoundObject(configuration: "registered") }

        XCTAssertEqual(factoryBound.name, "configured(registered)")
    }
}
