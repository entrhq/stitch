import XCTest
@testable import Stitch

extension XCTestCase {
    public func expectingPreconditionFailure(_ expectedMessage: String, _ execute: () -> ()) {

        let expectation = expectation(description: "Precondition should fail")

        // Overwrite our precondition closure with an assertion for testing
        Preconditions.closure = {
            (condition, message, file, line) in
            if !condition {
                expectation.fulfill()
                XCTAssertEqual(message, expectedMessage, "precondition message did not match expected", file: file, line: line)
            }
        }

        execute()

        // Expect our precondition to fail
        waitForExpectations(timeout: 0.0, handler: nil)

        // Reset precondition to default
        Preconditions.closure = Preconditions.defaultPreconditionClosure
    }
}
