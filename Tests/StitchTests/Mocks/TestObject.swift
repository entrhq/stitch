import Stitch

protocol SomeTestProtocol {
    var someProperty: String { get }
}

struct TestObject: SomeTestProtocol {
    var someProperty: String
}

extension DependencyMap {
    private struct TestObjectKey: DependencyKey {
        static var dependency: any SomeTestProtocol = TestObject(someProperty: "test")
    }
    
    var testObject: any SomeTestProtocol {
        get { resolve(key: TestObjectKey.self) }
        set { register(key: TestObjectKey.self, dependency: newValue) }
    }
}
