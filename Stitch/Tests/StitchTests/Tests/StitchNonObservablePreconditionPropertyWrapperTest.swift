import XCTest
import Combine
import SwiftUI
@testable import Stitch

final class StitchNonObservablePreconditionPropertyWrapperTest: XCTestCase, DependencyRegistrant, DependencyMocker {
    private var disposables = Set<AnyCancellable>()
    
    // MARK: - Mock objects
    
    // Wrapper class for delaying our injection because injection happens on instantation of object
    class WrapperClass {
        @StitchObservable(\.testObject) var testNonObservableObject: any SomeTestProtocol
    }
    
    // MARK: - Precondition
    func testPreconditionTriggersOnNonObservableObject() {
        expectingPreconditionFailure("Cannot observe an object that does not confrom to 'AnyObservableObject'") {
            // Create our wrapper class to trigger injection of object not conforming to observable object
            _ = WrapperClass()
        }
    }
}

