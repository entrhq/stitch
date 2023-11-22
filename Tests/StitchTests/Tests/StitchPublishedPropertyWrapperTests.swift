import XCTest
import Combine
import SwiftUI
@testable import Stitch

final class StitchPublishedPropertyWrapperTests: XCTestCase, DependencyRegistrant, DependencyMocker {
    private var disposables = Set<AnyCancellable>()
    @StitchPublished(\.testObservableObject) var testObject: any SomeObservableTestProtocol
    
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
        register(\.testObservableObject, dependency: TestObservableObject())
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someObservableProperty, "test")
    }
    
    func testObjectIsInjectedWithMockedDependencyWhenMockProvidedThroughKeypathMock() throws {
        mock(\.testObservableObject, mock: TestObservableObject())
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
        register(\.testObservableObject, dependency: MockTestObservableObject())
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someObservableProperty, "mocked")
    }
    
    func testOtherObjectIsInjectedWhenMockProvidedThroughKeypathMock() throws {
        mock(\.testObservableObject, mock: MockTestObservableObject())
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someObservableProperty, "mocked")
    }
    
    func testOtherObjectIsInjectedWhenMockProvidedThroughKeypathMockInViewScope() throws {
        let view = mockInViewScope(\.testObservableObject, mock: MockTestObservableObject())
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someObservableProperty, "mocked")
        // Assert an empty view was provided with the mockInViewScope
        XCTAssertEqual("\(view.self)", "\(EmptyView().self)")
    }
    
    // MARK: - Observed object publishes changes to objects
    
    func testInjectedObservableObjectPublisherPublishesChangeAndNewValue() {
        mock(\.testObservableObject, mock: MockTestObservableObject())
        XCTAssertEqual(testObject.someObservableProperty, "mocked")
        
        let expectation = self.expectation(description: "Receive response from sink")
        var actualChange: String?
        
        $testObject.someObservableProperty
            .sinkToExpectation(expectation) { change in
                // Check that our value changed on the base property
                actualChange = change
                expectation.fulfill()
            }
            .store(in: &disposables)
        
        // Trigger a published state change on our object
        self.testObject.doSomething()
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(actualChange, "did something mocked")
    }
    
    func testInjectedObservableObjectPublisherChangNewValue() {
        mock(\.testObservableObject, mock: MockTestObservableObject())
        XCTAssertEqual(testObject.someObservableProperty, "mocked")
        
        // Trigger a change
        testObject.doSomething()
        
        // Check that the object updated its change property
        XCTAssertEqual(testObject.someObservableProperty, "did something mocked")
    }
}
