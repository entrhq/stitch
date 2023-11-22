//
//  Stitchable.swift
//
//
//  Created by Justin Wilkin on 19/6/2023.
//

public protocol Stitchable {
    associatedtype Dependency
    static var scope: StitchableScope { get }
    static var dependency: Dependency { get set }
    static func resolve() -> Dependency
    static func register(dependency: Dependency)
    init()
}

extension Stitchable {
    public static func resolve() -> Dependency {
        switch scope {
        case .application: return dependency
        case .cached: return dependency
        case .unique: return dependency
        }
    }
    
    public static func register(dependency: Dependency) {
        self.dependency = dependency
    }
}
