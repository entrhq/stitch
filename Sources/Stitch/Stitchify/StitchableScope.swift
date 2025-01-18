//
//  StitchableScope.swift
//
//
//  Created by Justin Wilkin on 19/6/2023.
//

public protocol Scope {
    var name: String { get }
}

extension String: Scope {
    public var name: String { self }
}

public enum StitchableScope {
    case application
    case unique
}
