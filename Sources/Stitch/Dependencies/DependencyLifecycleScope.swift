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

// Compose our protocols together for all functionality
public protocol DependencyLifecycleScope: DependencyResolver, DependencyRegistrant {}
public protocol DependencyRegistrant {}
public protocol DependencyResolver {}

public extension DependencyRegistrant {
    /// Register a dependency by keyPath
    ///
    /// Forwards dependency registration to the `DependencyMap`
    func register<Dependency>(_ keyPath: WritableKeyPath<DependencyMap, Dependency>, dependency: Dependency) {
        DependencyMap.map[keyPath: keyPath] = dependency
    }
    
    /// Register a dependency by key
    ///
    /// Forwards dependency registration via dependency key to the `DependencyMap`
    func register<Key>(key: Key.Type, dependency: Key.Value) where Key: DependencyKey {
        key.dependency = dependency
    }
}

public extension DependencyResolver {
    /// Resolve a dependency
    ///
    /// Forwards dependency resolution to the `DependencyMap`
    func resolve<Dependency>(_ keyPath: WritableKeyPath<DependencyMap, Dependency>) -> Dependency {
        Self.resolve(keyPath)
    }
    
    /// Resolution outside of self scope or inside initializers
    ///
    /// Forwards dependency resolution to the `DependencyMap`
    static func resolve<Dependency>(_ keyPath: WritableKeyPath<DependencyMap, Dependency>) -> Dependency {
        return DependencyMap.map[keyPath: keyPath]
    }
    
    /// Register a dependency by key
    ///
    /// Forwards dependency registration via dependency key to the `DependencyMap`
    func resolve<Key>(key: Key.Type) -> Key.Value where Key: DependencyKey {
        return key.dependency
    }
}
