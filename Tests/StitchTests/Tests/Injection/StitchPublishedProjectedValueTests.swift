import XCTest
import Combine
import SwiftUI
@testable import Stitch

/// `$object.property` on a `StitchPublished` hands back a publisher for that property alone,
/// found by reflecting over the resolved object.
///
/// A `@Published` property holds its value directly until the object's `objectWillChange` is
/// accessed, at which point it holds a publisher instead. Reflection finds a publisher only in
/// the second state, so these tests access `objectWillChange` before subscribing.
@MainActor
final class StitchPublishedProjectedValueTests: XCTestCase {
    private var disposables = Set<AnyCancellable>()
    @StitchPublished(PartiallyPublishedObject.self) var testObject

    override func setUp() {
        super.setUp()
        PartiallyPublishedObject.register { PartiallyPublishedObject() }
        _ = testObject.objectWillChange
    }

    // MARK: - Published property
    func testProjectedValueForwardsChangesMadeInsideTheObject() {
        var received: [String] = []
        $testObject.publishedProperty
            .sink { received.append($0) }
            .store(in: &disposables)

        testObject.change(to: "changed")

        XCTAssertEqual(received, ["changed"])
    }

    func testProjectedValueForwardsChangesMadeThroughTheWrappedValue() {
        var received: [String] = []
        $testObject.publishedProperty
            .sink { received.append($0) }
            .store(in: &disposables)

        testObject.publishedProperty = "assigned"

        XCTAssertEqual(received, ["assigned"])
    }

    func testProjectedValueForwardsEveryChange() {
        var received: [String] = []
        $testObject.publishedProperty
            .sink { received.append($0) }
            .store(in: &disposables)

        testObject.change(to: "first")
        testObject.publishedProperty = "second"

        XCTAssertEqual(received, ["first", "second"])
    }

    func testProjectedValueDoesNotReplayTheCurrentValue() {
        var received: [String] = []
        $testObject.publishedProperty
            .sink { received.append($0) }
            .store(in: &disposables)

        // Check that subscribing forwards changes from that point rather than the value it holds
        XCTAssertTrue(received.isEmpty)
    }

    // MARK: - Property without a publisher
    func testProjectedValueForAPlainPropertyPublishesNothing() {
        var received: [String] = []
        $testObject.plainProperty
            .sink { received.append($0) }
            .store(in: &disposables)

        testObject.plainProperty = "assigned"

        XCTAssertTrue(received.isEmpty)
    }
}
