import Stitch
import Combine

protocol BoundTestProtocol {
    var name: String { get }
}

/// Implementations carry no annotation, and can take whatever their initialiser needs
struct DefaultBoundObject: BoundTestProtocol {
    var name: String { "default" }
}

struct MockBoundObject: BoundTestProtocol {
    var name: String { "mock" }
}

struct ConfiguredBoundObject: BoundTestProtocol {
    let configuration: String
    var name: String { "configured(\(configuration))" }
}

@StitchModule
extension StitchValues {
    @StitchBinding(BoundTestProtocol.self)
    typealias BoundTestBinding = DefaultBoundObject
    
    @StitchBinding(as: "uniqueBoundTest", scoped: .unique)
    static func uniqueBound() -> any BoundTestProtocol { ConfiguredBoundObject(configuration: "unique") }
    
    @StitchBinding(BoundTestProtocol.self, as: "secondBoundTest")
    typealias SecondBoundTestBinding = MockBoundObject
    
    @StitchBinding(BoundTestProtocol.self, as: "registeredBoundTest")
    typealias RegisteredBoundTestBinding = DefaultBoundObject
    
    @StitchBinding(BoundTestProtocol.self, as: "factoryBoundTest")
    typealias FactoryBoundTestBinding = DefaultBoundObject
    
    @StitchBinding(BoundObservableTestProtocol.self, as: "boundObservable")
    typealias BoundObservableBinding = BoundObservableObject
    
    @StitchBinding(BoundObservableTestProtocol.self, as: "boundPublished")
    typealias BoundPublishedBinding = BoundObservableObject
    
    @StitchBinding(BoundObservableTestProtocol.self, as: "projectedObservable")
    typealias ProjectedObservableBinding = BoundObservableObject
}

@MainActor
protocol BoundObservableTestProtocol: ObservableObject, AnyObservableObject {
    var value: String { get set }
}

@MainActor
class BoundObservableObject: BoundObservableTestProtocol {
    @Published var value: String = "observed"
    required init() {}
}
