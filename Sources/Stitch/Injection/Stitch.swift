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
public struct Stitch<Value> {
    private let resolve: () -> Value
    private let register: (Value) -> Void
    public var wrappedValue: Value {
        get { resolve() }
        set { register(newValue) }
    }
    
    /// Creates the property wrapper for a stitched type
    ///
    /// - Parameter type: The `Stitchable` to resolve the dependency from.
    public init<Dependency: Stitchable>(
        _ type: (Dependency).Type
    ) where Dependency.Dependency == Value {
        self.resolve = { type.resolve() }
        self.register = { value in type.register { value } }
    }
    }
