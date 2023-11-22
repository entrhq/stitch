//
//  Stitchify.swift
//
//
//  Created by Justin Wilkin on 16/6/2023.
//
//

/// Macro that wraps a type as a `Stitchable`, to be used for injection.
///
/// The `Stitchify` macro is used to convert a type into a `Stitchable`. It accepts optional parameters for the `type` and `scoped`.
/// The `type` parameter specifies the keyed type to be stored against and to be referenced when resolving.
/// The `scoped` parameter specifies the `StitchableScope` of the stitchable representation.
///
/// - Parameters:
///   - type: Optional type to be stitched by. When not provided, the type will be stitched against its concrete type.
///   - scoped: The scope of the stitchable representation. Defaults to `.application`.
@attached(member, names: named(scope), named(dependency), named(init))
@attached(extension, conformances: Stitchable)
//@attached(peer, names: prefixed(My), suffixed(Key))
public macro Stitchify(by: Any.Type? = nil, scoped: StitchableScope = .application) = #externalMacro(module: "StitchMacros", type: "StitchifyMacro")
