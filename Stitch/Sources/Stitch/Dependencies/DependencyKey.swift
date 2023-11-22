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

/// A generic key value type for storing a dependency inside the `DependencyMap`
///
/// The following code creates a `DependencyKey` for a new depenency:
///
///     private struct ObjectKey: DependencyKey {
///         static var dependency: any SomeObjectProtocol = Object()
///     }
///
/// A dependency key provides the initial/default value for a dependency within the `DependencyMap`
/// at compile time. This dependency can be overwritten during run time to provide subsequent concrete types
/// if the initial value does not provide the required functionality. Or if the dependency requires mocking.
///
/// Each dependency is lazily loaded on first reference through its `static` reference, thus, we do not have any
/// extra overhead on application launch for instantiating dependencies that are not immediately used. This allows us
/// to also overwrite the dependency before its first read within the application through a `WriteableKeyPath`.
///
/// - Note: Dependencies can either be stored in the key as a Concrete or Protocol type. This type will be used as the
///         resolving type at injection site. For objects that do not need to be mocked or require differing concrete
///         implementations, the use of a concrete `Value` type is preferred over an `Existential` type,
///         providing less overhead at runtime for the application, and allowing for the compiler to optimise and
///         statically dispatch the dependency.
public protocol DependencyKey {
    associatedtype Value
    static var dependency: Value { get set }
}
