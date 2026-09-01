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
//
import SwiftUI
import Combine

@MainActor
@propertyWrapper
public struct StitchObservable<Value>: DynamicProperty {
    @MainActor
    @dynamicMemberLookup
    public struct Wrapper {
        private var wrapped: StitchObservable
        
        internal init(_ wrap: StitchObservable<Value>) {
            self.wrapped = wrap
        }
        
        public subscript<Subject>(
            dynamicMember keyPath: ReferenceWritableKeyPath<Value, Subject>
        ) -> Binding<Subject> {
            Binding(
                get: { self.wrapped.wrappedValue[keyPath: keyPath] },
                set: { self.wrapped.wrappedValue[keyPath: keyPath] = $0 }
            )
        }
    }
    
    private let resolve: () -> Value
    private let register: (Value) -> Void
    public var wrappedValue: Value {
        get { resolve() }
        set {
            register(newValue)
            observe()
        }
    }
    
    @ObservedObject internal var observableObject = ErasedObservableObject()
    
    /// Projected value
    ///
    /// The projected value provides a `$` binding accessor to the calling site, much like `ObservableObject`
    /// or `StateObject` and produces a binding for SwiftUI view heirarchy to observe changes on.
    public var projectedValue: Wrapper {
        Wrapper(self)
    }
    
    /// Creates the property wrapper for a stitched type
    ///
    /// - Parameter type: The `Stitchable` to resolve the dependency from.
    public init<Dependency: Stitchable>(
        _ type: (Dependency).Type
    ) where Dependency.Dependency == Value {
        self.resolve = { type.resolve() }
        self.register = { value in type.register { value } }
        observe()
    }
        
    private mutating func observe() {
        let observable = wrappedValue as? (any AnyObservableObject)
        
        precondition(observable != nil, "Cannot observe an object that does not confrom to 'AnyObservableObject'")
        
        // Unwrapping safely to avoid force!
        // Should never get here if observable is nil due to precondition
        if let observable { 
            self.observableObject = .init(
                changePublisher: observable.objectWillChange.eraseToAnyPublisher()
            )
        }
    }
}
