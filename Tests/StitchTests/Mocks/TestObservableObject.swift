import Stitch
import SwiftUI

protocol SomeObservableTestProtocol: ObservableObject, AnyObservableObject {
    var someObservableProperty: String { get set }
    func doSomething()
}

class TestObservableObject: SomeObservableTestProtocol {
    @Published var someObservableProperty: String = "test"
    func doSomething() {
        someObservableProperty = "did something"
    }
}

extension DependencyMap {
    private struct TestObservableObjectKey: DependencyKey {
        static var dependency: any SomeObservableTestProtocol = TestObservableObject()
    }
    
    var testObservableObject: any SomeObservableTestProtocol {
        get { resolve(key: TestObservableObjectKey.self) }
        set { register(key: TestObservableObjectKey.self, dependency: newValue) }
    }
}
