//  Copyright (c) 2023. entr, pty ltd
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

@MainActor
@propertyWrapper
public struct Stitch<Dependency: Stitchable> {
    private let scopeContextKey: ScopeContextKey?
    private let stitchedType: (Dependency).Type
    public var wrappedValue: Dependency.Dependency {
        get { stitchedType.resolve(key: scopeContextKey) }
        set { stitchedType.register(key: scopeContextKey) { newValue } }
    }
    
    /// Creates the property wrapper for a stitched type
    ///
    /// - Parameters:
    ///   - type: The `Stitchable` to resolve the dependency from.
    ///   - key: The `ScopeContextKey` to resolve against. Only a `.keyed` scope reads the key,
    ///   so leave it `nil` for any other scope.
    public init(_ type: (Dependency).Type, key: ScopeContextKey? = nil) {
        self.stitchedType = type
        self.scopeContextKey = key
    }
}
