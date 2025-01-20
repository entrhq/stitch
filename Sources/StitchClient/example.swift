//
//  example.swift
//  Stitch
//
//  Created by Justin Wilkin on 20/1/2025.
//

import Stitch
import Combine
import Foundation

protocol Store: ObservableObject, AnyObservableObject {}

// MARK: SAME
@MainActor
protocol SomeProtocol: Store {
    var uuid: UUID { get }
    var property: String { get set }
}

@Stitchify(by: SomeProtocol.self, scoped: .application)
class SomeStore: SomeProtocol {
    required init() {}
    var uuid = UUID()
    @Published var property: String = "hello"
    @Published var otherProperty: String = "not visible by protocol"
}

@MainActor
struct SomeStruct {
    @Stitch(SomeStore.self) var new
    @StitchObservable(SomeStore.self) var newObservable
    
    func doSomething() {
        print(new.property)
        print(newObservable.uuid)
    }
}

@MainActor
class AnotherClass {
    @Stitch(SomeStore.self) var new
    @StitchObservable(SomeStore.self) var newObservable
    @StitchPublished(SomeStore.self) var newPublished
    var cancellables: Set<AnyCancellable> = []
    
    func doSomething() {
        $newPublished
            .property
            .sink { print("property is changing to: \($0)") }
            .store(in: &cancellables)
        
        print("making changes: world")
        newPublished.property = "world"
        
        print("changing again: new")
        newPublished.property = "new"
        
        print("closing")
    }
}

@main
struct Main {
    @MainActor
    static func main() {
        SomeStruct().doSomething()
        AnotherClass().doSomething()
    }
}
