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
protocol SomeProtocol: Store {
    var uuid: UUID { get }
    var property: String { get set }
}

class SomeStore: SomeProtocol {
    var uuid = UUID()
    @Published var property: String = "hello"
    @Published var otherProperty: String = "not visible by protocol"
}

@MainActor
class SomeClass {
    @StitchPublished(\.someStore) var newPublished
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
    static func main() {
        let cls = SomeClass()
        // invoke once
        cls.doSomething()
        // invoke same instance
        cls.doSomething()
    }
}

@StitchModule
extension StitchValues {
    @StitchBinding(SomeProtocol.self)
    typealias SomeStoreBinding = SomeStore
}
