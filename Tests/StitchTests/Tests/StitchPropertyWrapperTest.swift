import XCTest
import Combine
import SwiftUI
@testable import Stitch

@MainActor
final class StitchPropertyWrapperTest: XCTestCase, DependencyRegistrant, DependencyMocker {
    @Stitch(TestObject.self) var testObject: any SomeTestProtocol
    
    // MARK: - Mock objects
    struct MockTestObject: SomeTestProtocol {
        var someProperty: String = "mocked"
    }

    // MARK: Same type as default concrete injection
    func testObjectIsInjectedUsingInjectPropertyWrapperAndDefaultDependency() throws {
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someProperty, "test")
    }
    
    func testObjectIsInjectedWithNewDependencyWhenProvidedAtRunTimeThroughPropertyWrapper() throws {
        testObject = TestObject(someProperty: "otherproperty")
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someProperty, "otherproperty")
    }
    
    func testObjectIsInjectedWithNewDependencyWhenProvidedAtRunTimeThroughRegisterAndKeypath() throws {
        register(TestObject.self, dependency: TestObject(someProperty: "someotherproperty"))
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someProperty, "someotherproperty")
    }
    
    // MARK: Other conforming type
    func testOtherObjectIsInjectedWhenProvidedAtRunTimeThroughPropertyWrapper() throws {
        testObject = MockTestObject()
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someProperty, "mocked")
    }
    
    func testOtherObjectIsInjectedWhenProvidedAtRunTimeThroughRegisterAndKeypath() throws {
        register(TestObject.self, dependency: MockTestObject())
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someProperty, "mocked")
    }
    
    func testOtherObjectIsInjectedWhenMockProvidedThroughKeypathMockInViewScope() throws {
        let view = mockInViewScope(TestObject.self, mock: MockTestObject())
        // Check that our property has been injected into the class with the appropriate value
        XCTAssertEqual(testObject.someProperty, "mocked")
        // Assert an empty view was provided with the mockInViewScope
        XCTAssertEqual("\(view.self)", "\(EmptyView().self)")
    }
}
