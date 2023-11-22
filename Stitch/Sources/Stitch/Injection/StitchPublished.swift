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
public class StitchPublished<Dependency>: DependencyLifecycleScope {
    private var cancellable: AnyCancellable?
    private var publisher = Publisher<Dependency>()
    private let keyPath: WritableKeyPath<DependencyMap, Dependency>
    public var wrappedValue: Dependency {
        get { resolve(keyPath) }
        set {
            register(keyPath, dependency: newValue)
            observe()
        }
    }
    
    /// Projected value
    ///
    /// The projected value provides a `$` publisher accessor to the calling site, much like `Published`
    /// inside an `ObservableObject` and provides a `ChangePublisher` for properties of the underlying object through
    /// `DynamicMemberLookup`.
    ///
    /// This wraps the expected property in a `ChangePublisher` which provides a publisher for handling
    /// update events for only that property.
    ///
    /// - Note: Generic typed `ObservableObjects` erased as `AnyObservableObjects` are required to
    /// use the publisher binding $ on the parent object, and access the property through `DynamicMemberLookup`.
    /// This is different to normal `Published` properties on concrete types, which can be referenced on the parent
    /// type with their publisher binding.
    ///
    /// The following code demonstrates the differences:
    ///
    ///   // Generic type AnyObservableObjects
    ///   $object.someProperty
    ///
    ///   // Concrete ObservableObjects
    ///   object.$someProperty
    ///
    /// This is due to the nature of Generics and the need for `DynamicMemberLookup`
    public var projectedValue: Wrapper {
        /// Our dependency may have changed since creation. Retrigger our subscription forwarding
        /// through observe(). This ensures that our object when changed
        /// will publish from the newly registered dependency.
        ///
        /// Note: this will re-observe on every subscription. So multiple subscriptions after each other
        /// will trigger multiple observes. This can lead to recreation of the objectWillChange on multiple
        /// occurances. This may seem expensive at first glance, but only one reference to the objectWillChange
        /// is kept in memory at any point in time, and for all new subscribers that trigger observe(), the new
        /// `ObjectWillChange` will be valid for all previous subscribers as it simply forwards all change events to
        /// our single reference of `StitchPublished` and its single `Publisher`.
        ///
        /// The `Wrapper` here subscribes our `ChangePublisher` to the single reference of `Publisher`
        /// ensuring no mutation of previous subscriber instances.
        observe()
        return Wrapper(self)
    }
    
    public init(_ keyPath: WritableKeyPath<DependencyMap, Dependency>) {
        self.keyPath = keyPath
        observe()
    }
    
    /// Start observing our observable object
    ///
    /// Forwards object will change events to our internal object publisher.
    /// Converting all objectWillChange events to objectDidChange events on the `RunLoop.main`,
    /// in order to perform `ChangePublisher` diffing which provides published values for dynamic members of the
    /// `AnyObservableObject`.
    private func observe() {
        let observable = wrappedValue as? AnyObservableObject
        precondition(observable != nil, "Cannot observe an object that does not conform to 'AnyObservableObject'")
        guard let observable else { return }
        
        cancellable = observable.objectWillChange
            /// `ObjectWillChange` triggers before the value of the underlying observable changes.
            /// This is so the ObservableObject can dispatch an event on the `RunLoop.main` to compute a diff
            /// bofore a view recomposition, telling the view only which properties it requires to recompose.
            ///
            /// Because of this, we can receive our objectWillChange on the `RunLoop.main` (which will receive
            /// the value after the RunLoop has become idle, due to it blocking). This turns our `ObjectWillChange`
            /// into an `ObjectDidChange`. Allowing us to forward the newly updated object to our publisher.
            ///
            /// Now that we have the updated object, we can perform a diff on the `lastValue` and determine
            /// if we need to publish an update to downstream subscribers for the dynamic property.
            .receive(on: RunLoop.main)
            .sink {
                self.publisher.send(self.wrappedValue)
            }
    }
    
    // MARK: Value observer wrapping
    /// Generic typed wrapper for `ObservableObjects` erased as `AnyObservableObjects`.
    ///
    /// This wraps the `AnyObservableObject` and provides `DynamicMemberLookup` for properties on the object.
    /// It wraps each property in a `ChangePublisher` which provides a publisher for handling update events for
    /// that property alone, rather than the whole object.
    @dynamicMemberLookup
    public struct Wrapper {
        private var wrapped: StitchPublished
        
        internal init(_ wrap: StitchPublished<Dependency>) {
            self.wrapped = wrap
        }
        
        public subscript<Subject: Equatable>(
            dynamicMember keyPath: ReferenceWritableKeyPath<Dependency, Subject>
        ) -> Publisher<Subject> {
            ChangePublisher(
                for: self.wrapped.wrappedValue[keyPath: keyPath],
                keyPath: keyPath,
                rootPublisher: &wrapped.publisher
            ).publisher
        }
    }
    
    /// Used for wrapping a property of an object and provides a publisher for handling update
    /// events for that property alone, rather than the whole object.
    ///
    /// Internally the `ChangePublisher` does a diff on the property and its `lastValue`
    /// to determine if an update should be published.
    public class ChangePublisher<Subject: Equatable> {
        private var cancellable: AnyCancellable?
        private var lastValue: Subject
        var publisher = Publisher<Subject>()
        
        internal init(
            for subject: Subject,
            keyPath: KeyPath<Dependency, Subject>,
            rootPublisher: inout Publisher<Dependency>
        ) {
            self.lastValue = subject
            cancellable = rootPublisher.sink { object in
                let newValue = object[keyPath: keyPath]
                guard newValue != self.lastValue else { return }
                self.publisher.send(newValue)
                
                // Update our last value to be the new one we just published
                self.lastValue = newValue
            }
        }
    }
    
    // MARK: Internal erased publisher
    /// A simple publisher wrapper for properties marked with the `@StitchPublished` attribute.
    public class Publisher<T>: Combine.Publisher {
        private var cancellable: AnyCancellable?
        fileprivate let subject = PassthroughSubject<T, Never>()

        /// The type of values published by this publisher.
        public typealias Output = T

        /// The kind of errors this publisher might publish.
        ///
        /// Use `Never` if this `Publisher` does not publish errors.
        public typealias Failure = Never

        /// Attaches the specified subscriber to this publisher.
        ///
        /// The provided implementation of ``Publisher/subscribe(_:)``calls this method.
        ///
        /// - Parameter subscriber: The downstream subscriber to attach to this ``Publisher``,
        /// after which it will receive values.
        public func receive<Downstream: Subscriber>(
            subscriber: Downstream
        ) where Downstream.Input == T, Downstream.Failure == Never {
            subject.subscribe(subscriber)
        }

        /// Sends an input to the publisher for downstream subscribers to receive.
        fileprivate func send(_ input: T) {
            subject.send(input)
        }
    }
}
