//  Copyright (c) 2026. entr, pty ltd
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
//

extension Stitchable {
    @available(*, deprecated, message: "Use `register(factory:)` or `register(key:factory:)` instead")
    public static func register(dependency: Dependency) {
        register { dependency }
    }
    
    /// Registers a new factory for the default dependency instance creation
    ///
    /// The new factory will be used by the `Stitchable` for any future instance recreations on the `defaultScopeContextKey`,
    public static func register(factory: @escaping DependencyFactories<Dependency>.Factory) {
        // we register the default scope when no scope is provided
        self.factories[defaultScopeContextKey] = factory
        if case .unique = scope { return } // unique scoped dependencies do not store instances, they are held by callers
        // we greedily re-instantiate so that we do not serve a stale dependency
        self.instances[defaultScopeContextKey] = factory()
    }
    
    /// Registers a new factory for dependency instance creation against a given `ScopeContextKey` or defaults to `register(factory:)` if none provided
    public static func register(key: ScopeContextKey? = nil, factory: @escaping DependencyFactories<Dependency>.Factory) {
        // try to set a factory for a scope on an application or unique scope is a no-op, fall back to default registration
        guard case .keyed = scope, let scopeKey = key else { return register(factory: factory) }
        factories[scopeKey] = factory
        // greedily re-instantiate after we created a new factory so we do not serve a stale dependency
        instances[scopeKey] = factory()
    }
}
