import XCTest
import Combine
import SwiftUI
@testable import Stitch

@MainActor
final class StitchObservablePropertyWrapperTest: XCTestCase, DependencyRegistrant, DependencyMocker {
    private var disposables = Set<AnyCancellable>()
    @StitchObservable(TestObservableObject.self) var testObject: any SomeObservableTestProtocol
    
    // MARK: - Mock objects
    class MockTestObservableObject: SomeObservableTestProtocol {
        @Published var someObservableProperty: String = "mocked"
        func doSomething() {
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
    
    // MARK: - Observed object publishes changes to objects
    func testInjectedObservableObjectValueChangesOnMutation() {
        testObject = TestObservableObject()
        XCTAssertEqual(testObject.someObservableProperty, "test")
        
        // Trigger an internal function that should change state
        testObject.doSomething()
        
        XCTAssertEqual(testObject.someObservableProperty, "did something")
    }
    
    func testInjectedObservableObjectValuePublishesChange() {
        testObject = TestObservableObject()
        XCTAssertEqual(testObject.someObservableProperty, "test")
        
        // Validate our response from decoder processor
        var changeCount = 0
        
        // Observe our object's change publisher
        _testObject.observableObject.objectWillChange
            .sink { _ in
                // Increase our change count
                changeCount += 1
            }
            .store(in: &disposables)
        
        // Trigger a published state change on our object
        testObject.doSomething()
        
        // Check that our object notified observers of its change
        XCTAssertEqual(testObject.someObservableProperty, "did something")
        XCTAssertEqual(changeCount, 1)
    }
    
    func testInjectedObservableObjectBinding() {
        testObject = TestObservableObject()
        
        // Update our value through the binding
        // We have to use .wrappedVlue here, but SwiftUI will automatically forward
        // the assigned value when @Binding property wrapper is used
        $testObject.someObservableProperty.wrappedValue = "new value"
        
        // Check that our value changed on the base property
        XCTAssertEqual(testObject.someObservableProperty, "new value")
    }
}
