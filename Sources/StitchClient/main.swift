import Stitch
import Combine
import Foundation

// MARK: SAME
@MainActor
protocol SomeProtocol {
    var uuid: UUID { get }
    var property: String { get set }
}

typealias SomeStoreBox = SomeStore
@Stitchify(by: SomeProtocol.self, scoped: .application)
class SomeStore: SomeProtocol, ObservableObject, AnyObservableObject {
    var objectDidChange = ObservableObjectPublisher()
    var cancellables: Set<AnyCancellable> = []
    required init() {}
    
    var uuid = UUID()
    @Published var property: String = "hello"
    @Published var otherProperty: String = "not visible by protocol"
}

@MainActor
struct SomeClass {
    @Stitch(SomeStoreBox.self) var new
    @StitchObservable(SomeStoreBox.self) var newObservable
    
    func doSomething() {
        print(new.property)
        print(newObservable.uuid)
    }
}

@MainActor
class AnotherClass {
    @Stitch(SomeStoreBox.self) var new
    @StitchObservable(SomeStoreBox.self) var newObservable
    @StitchPublished(SomeStoreBox.self) var newPublished
    var cancellables: Set<AnyCancellable> = []
    
    func doSomething() {
//        var wrapper = $newPublished.property
//        var property: Published<String>.Publisher? = wrapper.property
//        print(type(of: property))
        
        
//            .sink { print("property is changing to: \($0)") }
//            .store(in: &cancellables)
        
        print("making changes: world")
        newPublished.property = "world"
        
        print("changing again: new")
        newPublished.property = "new"
        
        print("closing")
    }
}

SomeClass().doSomething()
AnotherClass().doSomething()
