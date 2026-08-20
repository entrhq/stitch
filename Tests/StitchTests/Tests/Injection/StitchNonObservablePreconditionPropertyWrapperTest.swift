import XCTest
import Combine
import SwiftUI
@testable import Stitch

@MainActor
final class StitchNonObservablePreconditionPropertyWrapperTest: XCTestCase {
    // MARK: - Mock objects
    // Wrapper class for delaying our injection because injection happens on instantation of object
    @MainActor
    struct WrapperClass {
        @StitchObservable(TestObject.self) var testNonObservableObject
    }
    
    // MARK: - Precondition
    func testPreconditionTriggersOnNonObservableObject() {
        expectingPreconditionFailure("Cannot observe an object that does not confrom to 'AnyObservableObject'") {
            // Create our wrapper class to trigger injection of object not conforming to observable object
            _ = WrapperClass()
        }
    }
}
