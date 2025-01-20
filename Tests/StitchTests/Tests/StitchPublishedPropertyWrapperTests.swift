import XCTest
import Combine
import SwiftUI
@testable import Stitch

@MainActor
final class StitchPublishedPropertyWrapperTests: XCTestCase, DependencyMocker, DependencyRegistrant {
    private var disposables = Set<AnyCancellable>()
    @StitchPublished(TestObservableObject.self) var testObject
    
    // MARK: - Mock objects
    @MainActor
    class MockTestObservableObject: SomeObservableTestProtocol {
        @Published var someObservableProperty: String = "mocked"
        
        @MainActor
        func doSomething() {
            print("changing to did something")
            someObservableProperty = "did something mocked"
        }
    }
    
    // MARK: Same type as default concrete injection
    
    func testObjectIsInjectedWithNewDependencyWhenProvidedAtRunTimeThroughPropertyWrapper() throws {
        testObject = TestObservableObject()
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someObservableProperty, "test")
    }
    
    func testObjectIsInjectedWithNewDependencyWhenProvidedAtRunTimeThroughRegisterAndKeypath() throws {
        register(TestObservableObject.self, dependency: TestObservableObject())
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someObservableProperty, "test")
    }
    
    // MARK: Other conforming type
    func testOtherObjectIsInjectedWhenProvidedAtRunTimeThroughPropertyWrapper() throws {
        testObject = MockTestObservableObject()
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someObservableProperty, "mocked")
    }
    
    func testOtherObjectIsInjectedWhenProvidedAtRunTimeThroughRegisterAndKeypath() throws {
        register(TestObservableObject.self, dependency: MockTestObservableObject())
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someObservableProperty, "mocked")
    }
    
    func testOtherObjectIsInjectedWhenMockProvidedThroughKeypathMockInViewScope() throws {
        let view = mockInViewScope(TestObservableObject.self, mock: MockTestObservableObject())
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someObservableProperty, "mocked")
        // Assert an empty view was provided with the mockInViewScope
        XCTAssertEqual("\(view.self)", "\(EmptyView().self)")
    }
    
    func testInjectedObservableObjectPublisherChangNewValue() {
        register(TestObservableObject.self, dependency: MockTestObservableObject())
        XCTAssertEqual(testObject.someObservableProperty, "mocked")
        
        // Trigger a change
        testObject.doSomething()
        
        // Check that the object updated its change property
        XCTAssertEqual(testObject.someObservableProperty, "did something mocked")
    }
}
