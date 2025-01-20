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

@MainActor
public extension DependencyRegistrant {
    /// Register a dependency to its dependency container
    func register<Dependency>(_ stitchable: any Stitchable<Dependency>.Type, dependency: Dependency) {
        stitchable.register(dependency: dependency)
    }
}

@MainActor
public extension DependencyResolver {
    /// Resolve a dependency from its dependency container
    func resolve<Dependency>(_ stitchable: any Stitchable<Dependency>.Type) -> Dependency {
        stitchable.resolve()
    }
}
