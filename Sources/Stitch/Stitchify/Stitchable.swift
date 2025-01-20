//
//  Stitchable.swift
//
//
//  Created by Justin Wilkin on 19/6/2023.
//

@MainActor
public protocol Stitchable<Dependency> {
    associatedtype Dependency
    // MARK: dependency storage
    static var scope: StitchableScope { get }
    static var dependency: Dependency { get set }
    
    // MARK: dependency lifecycle
    static func resolve() -> Dependency
    static func register(dependency: Dependency)
    static func createNewInstance() -> Dependency
    init()
}

extension Stitchable {    
    public static func register(dependency: Dependency) {
        self.dependency = dependency
    }
}
