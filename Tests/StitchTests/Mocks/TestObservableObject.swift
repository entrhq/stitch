import Stitch
import SwiftUI

@MainActor
protocol SomeObservableTestProtocol: ObservableObject, AnyObservableObject {
    var someObservableProperty: String { get set }
    func doSomething()
}

@MainActor
@Stitchify(by: SomeObservableTestProtocol.self)
class TestObservableObject: SomeObservableTestProtocol {
    required init() {}
    @Published var someObservableProperty: String = "test"
    func doSomething() {
        print("changing to did something original")
        someObservableProperty = "did something"
    }
}
