import Stitch
import Foundation

// MARK: SAME
@MainActor
protocol SomeProtocol {
    var uuid: UUID { get }
    var property: String { get set }
}

@Stitchify(by: SomeProtocol.self, scoped: .unique)
class SomeStore: SomeProtocol {
    required init() {}
    var uuid = UUID()
    var property: String = "hello"
    var otherProperty: String = "not visible by protocol"
}

typealias SomeStoreType = SomeStore

// MARK: IMPL
@MainActor
struct SomeClass {
    @Stitched(SomeStore.self) var new
    @StitchedObservable(SomeStore.self) var newObservable
    
    func doSomething() {
        print(new.property)
        print(newObservable.uuid)
    }
}

@MainActor
struct AnotherClass {
    @Stitched(SomeStoreType.self) var new
    @StitchedObservable(SomeStore.self) var newObservable
    
    func doSomething() {
        print(new.property)
        print(newObservable.uuid)
    }
}

// these class id's will be different because our injection was set to unique.
SomeClass().doSomething()
AnotherClass().doSomething()
