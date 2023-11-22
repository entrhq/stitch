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

/// Dependency map reference for accessing properties through key paths
///
/// Dependency map contains a file scoped singleton reference for accessing properties.
/// All dependencies are then declared in extensions of `DependencyMap` and can be accessed
/// through Swift's `KeyPath` implementation.
///
///
/// The following code reads a property from the `DependencyMap`:
///
///     DependencyMap.map[keyPath: \.keyPathToProperty]
///     or
///     DependencyMap.resolve(\.keyPathToProperty)
///
/// Accessing this property will provide both a `get` and `set` for the dependency through a `WritableKeyPath`
///
/// Declare a dynamic property within an extension of `DependencyMap` to create a dependency.
/// Creating a dependency requries a `DependencyKey` which stores the initial/default value for the dependency.
///
///
/// The following code registers a new dependency to the `DependencyMap`:
///
///     extension DependencyMap {
///         private struct ObjectKey: DependencyKey {
///             static var dependency: any SomeObjectProtocol = Object()
///         }
///
///         var object: any SomeObjectProtocol {
///             get { resolve(key: ObjectKey.self) }
///             set { register(key: ObjectKey.self, dependency: newValue) }
///         }
///     }
///
/// And can be accessed as follows:
///
///     // Returns the concrete implementation of Object as its existential type
///     DependencyMap.map[keyPath: \.object]
///     or
///     DependencyMap.resolve(\.object)
///
public class DependencyMap: DependencyLifecycleScope {
    internal static var map = DependencyMap()
}
