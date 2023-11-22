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

import SwiftUI
import Combine

@propertyWrapper
public struct StitchObservable<Dependency>: DynamicProperty, DependencyLifecycleScope {
    @dynamicMemberLookup
    public struct Wrapper {
        private var wrapped: StitchObservable
        
        internal init(_ wrap: StitchObservable<Dependency>) {
            self.wrapped = wrap
        }
        
        public subscript<Subject>(
            dynamicMember keyPath: ReferenceWritableKeyPath<Dependency, Subject>
        ) -> Binding<Subject> {
            Binding(
                get: { self.wrapped.wrappedValue[keyPath: keyPath] },
                set: { self.wrapped.wrappedValue[keyPath: keyPath] = $0 }
            )
        }
    }
    
    private let keyPath: WritableKeyPath<DependencyMap, Dependency>
    public var wrappedValue: Dependency {
        get { resolve(keyPath) }
        set {
            register(keyPath, dependency: newValue)
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
    
    public init(_ keyPath: WritableKeyPath<DependencyMap, Dependency>) {
        self.keyPath = keyPath
        observe()
    }
    
    private mutating func observe() {
        let observable = wrappedValue as? AnyObservableObject
        
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

@propertyWrapper
public struct StitchedObservable<Dependency: Stitchable>: DynamicProperty, DependencyLifecycleScope {

    @dynamicMemberLookup
    public struct Wrapper {
        private var wrapped: StitchedObservable
        
        internal init(_ wrap: StitchedObservable<Dependency>) {
            self.wrapped = wrap
        }
        
        public subscript<Subject>(
            dynamicMember keyPath: ReferenceWritableKeyPath<Dependency.Dependency, Subject>
        ) -> Binding<Subject> {
            Binding(
                get: { self.wrapped.wrappedValue[keyPath: keyPath] },
                set: { self.wrapped.wrappedValue[keyPath: keyPath] = $0 }
            )
        }
    }
    
    private let stitchedType: (Dependency).Type
    public var wrappedValue: Dependency.Dependency {
        get { stitchedType.resolve() }
        set {
            stitchedType.register(dependency: newValue)
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
    
    public init(_ type: (Dependency).Type) {
        self.stitchedType = type
        observe()
    }
    
    private mutating func observe() {
        let observable = wrappedValue as? AnyObservableObject
        
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
