//
//  StitchableScope.swift
//
//
//  Created by Justin Wilkin on 19/6/2023.
//

public enum StitchableScope {
    /// Dependency scope that lasts the lifetime of the application
    case application
    /// Dependency scope that is recreated on each injection
    case unique
}

extension Stitchable {
    public static func resolve() -> Dependency {
        switch scope {
        case .application: return dependency // always use the same instance
        case .unique: return createNewInstance() // create a new instance every time
        }
    }
}
