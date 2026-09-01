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

/// Macro that wraps a type as a `Stitchable`, to be used for injection.
///
/// The `Stitchify` macro is used to convert a type into a `Stitchable`. It accepts optional parameters for the `by` and `scoped`.
/// The `by` parameter specifies the keyed type to be stored against and to be referenced when resolving.
/// The `scoped` parameter specifies the `StitchableScope` of the stitchable representation.
///
/// The macro automatically inherits the access level of the annotated type (public, internal, fileprivate, private, or package)
/// and applies it to all generated members (`scope`, `instance`, `factory`), ensuring consistent visibility
/// across your dependency injection setup.
///
/// - Parameters:
///   - by: Optional type to be stitched by. When not provided, the type will be stitched against its concrete type.
///   - scoped: The scope of the stitchable representation. Defaults to `.application`.
@attached(member, names: named(Dependency), named(scope), named(instance), named(factory))
@attached(extension, conformances: Stitchable)
public macro Stitchify(by: Any.Type? = nil, scoped: StitchableScope = .application) = #externalMacro(module: "StitchMacros", type: "StitchifyMacro")
