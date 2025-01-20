import Stitch

protocol SomeTestProtocol {
    var someProperty: String { get }
}

@MainActor
@Stitchify(by: SomeTestProtocol.self)
struct TestObject: SomeTestProtocol {
    var someProperty: String = "test"
}
