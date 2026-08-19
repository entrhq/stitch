import XCTest
@testable import Stitch

/// Values reflected by the traverser tests
private struct Leaf {
    let name: String = "leaf"
}

private struct Root {
    let leaf = Leaf()
    let count = 3
}

final class MirrorTraverserTests: XCTestCase {
    private var traverser: MirrorTraverser {
        MirrorTraverser(mirror: Mirror(reflecting: Root()))
    }

    // MARK: - Traversal
    func testTraverseFindsAChildByItsLabel() {
        let count: Int? = traverser.traverse(by: "count").value()

        XCTAssertEqual(count, 3)
    }

    func testTraverseWalksNestedChildren() {
        let name: String? = traverser.traverse(by: "leaf").traverse(by: "name").value()

        XCTAssertEqual(name, "leaf")
    }

    func testTraverseReturnsNilForAnUnknownLabel() {
        XCTAssertNil(traverser.traverse(by: "unknown"))
    }

    func testTraverseFromANilTraverserReturnsNil() {
        // Check that a broken link stops the walk instead of trapping
        XCTAssertNil(traverser.traverse(by: "unknown").traverse(by: "name"))
    }

    // MARK: - Value
    func testValueReturnsNilForAMismatchedType() {
        let count: String? = traverser.traverse(by: "count").value()

        XCTAssertNil(count)
    }

    func testValueReturnsNilFromANilTraverser() {
        let name: String? = traverser.traverse(by: "unknown").value()

        XCTAssertNil(name)
    }

    func testValueReturnsNilAtTheRoot() {
        // The root holds no reflected child value, only the mirror it was built from
        let root: Root? = traverser.value()

        XCTAssertNil(root)
    }
}
