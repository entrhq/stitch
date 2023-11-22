import Stitch
import Foundation


var value = SomeStruct.resolve()
print("\(value.uuid): \(value.property)")

// MARK: SAME
protocol SomeProtocol {
    var uuid: UUID { get }
    var property: String { get set }
}

// MARK: NEW
@Stitchify
struct SomeStruct: SomeProtocol {
    var uuid = UUID()
    var property: String = "hello"
    var otherProperty: String = "not visible by protocol"
}

// MARK: OLD
struct OtherSomeStruct: SomeProtocol {
    var uuid = UUID()
    var property: String = "hello other"
    var otherProperty: String = "not visible by protocol"
}

extension DependencyMap {
    private struct OtherSomeStructKey: DependencyKey {
        static var dependency: any SomeProtocol = OtherSomeStruct()
    }
    
    var otherStruct: any SomeProtocol {
        get { resolve(key: OtherSomeStructKey.self) }
        set { register(key: OtherSomeStructKey.self, dependency: newValue) }
    }
}

// MARK: IMPL
struct SomeClass {
    @Stitched(SomeStruct.self) var new
    @Stitch(\.otherStruct) var old
    @Stitch(\.otherStruct) var otherNew
//    @Stitch(\Some) var old
    
    func doSomething() {
        print("\(old.uuid): \(old.property)")
        print("\(new.uuid): \(new.property)")
    }
}


SomeClass().doSomething()
