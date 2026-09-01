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

/// Macro that resolves the bindings declared in a `StitchValues` extension.
///
/// The `StitchModule` macro is attached to an extension of `StitchValues`. It reads every
/// `@StitchBinding` declaration inside that extension, and gives each one a `Stitchable` container
/// to hold its dependency along with the key path accessor for an injection site to resolve by.
///
/// The following code declares a module holding a single binding:
///
///     @StitchModule
///     extension StitchValues {
///         @StitchBinding(Analytics.self)
///         typealias AnalyticsBinding = FirebaseAnalytics
///     }
///
/// You then inject the dependency with its key path, using any of Stitch's property wrappers:
///
///     @Stitch(\.analytics) private var analytics
@attached(member, names: arbitrary)
public macro StitchModule() = #externalMacro(module: "StitchMacros", type: "StitchModuleMacro")

/// Macro that binds a concrete implementation to the protocol, providing an IoC container for resolution.
///
/// The `StitchBinding` macro is attached to a declaration inside a `@StitchModule` extension.
/// When your implementation takes no arguments, attach it to a `typealias`. The accessor is named
/// after the alias with its `Binding` suffix truncated. The following code binds `Analytics` to
/// `FirebaseAnalytics` and provides `\.analytics`:
///
///     @StitchModule
///     extension StitchValues {
///         @StitchBinding(Analytics.self)
///         typealias AnalyticsBinding = FirebaseAnalytics
///     }
///
/// When your implementation requires construction or conditional registration, attach it to a
/// `static func` returning the protocol. The accessor is named after the function:
///
///     @StitchModule
///     extension StitchValues {
///         @StitchBinding
///         static func logger() -> any Logging {
///             #if DEBUG
///             return StandardOutputLogger()
///             #else
///             return RemoteLogger()
///             #endif
///         }
///     }
///
/// Binding one protocol more than once gives each binding its own dependency. This enables you to use accessors as context keys,
/// and resolve different dependencies from the same protocol at call site.
///
/// You should provide `as:` when the derived name would collide or read poorly:
///
///     @StitchBinding(Analytics.self, as: "debugAnalytics")
///     typealias DebugAnalyticsBinding = ConsoleAnalytics
///
/// - Parameters:
///   - dependency: The protocol the implementation is bound to. Used only when bound to a typealias.
///   - name: Optional name for the accessor. When not provided, the name is derived from the declaration the macro is attached to.
///   - scoped: The scope of the bound dependency. Defaults to `.application`.
@attached(peer)
public macro StitchBinding(
    _ dependency: Any.Type? = nil,
    as name: String? = nil,
    scoped: StitchableScope = .application
) = #externalMacro(module: "StitchMacros", type: "StitchBindingMacro")
