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

@MainActor
@propertyWrapper
public class StitchPublished<Dependency: Stitchable>: DependencyLifecycleScope {
    private var cancellable: AnyCancellable?
    private var publisher = Publisher<Dependency.Dependency>()
    
    private let stitchedType: (Dependency).Type
    public var wrappedValue: Dependency.Dependency {
        get { stitchedType.resolve() }
        set {
            stitchedType.register(dependency: newValue)
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
        return Wrapper(self)
    }
    
    public init(_ type: (Dependency).Type) {
        self.stitchedType = type
    }
    
    // MARK: Value observer wrapping
    /// Generic typed wrapper for `ObservableObjects` erased as `AnyObservableObjects`.
    ///
    /// This wraps the `AnyObservableObject` and provides `DynamicMemberLookup` for properties on the object.
    /// It wraps each property in a `ChangePublisher` which forwards publishe events for handling update events for
    /// that property alone, rather than the whole object.
    @MainActor
    @dynamicMemberLookup
    public struct Wrapper {
        private var wrapped: StitchPublished
        
        internal init(_ wrap: StitchPublished<Dependency>) {
            self.wrapped = wrap
        }
        
        /// Fetches the published wrapper attached to the given property
        func getPublishedWrapper<Object, Value: Equatable>(
            of object: Object,
            for keyPath: KeyPath<Object, Value>
        ) -> Combine.Published<Value>? {
            // Use Mirror to reflect the object
            let mirror = Mirror(reflecting: object)
            let keyValue = object[keyPath: keyPath] as Value?

            // Iterate through the children to find publishers
            for child in mirror.children {
                // filter by Combine published types only
                guard let pw = child.value as? Combine.Published<Value> else { continue }
                
                // check current value of publisher is equal to keyPath value
                if getPublishedValue(from: pw) == keyValue {
                    return pw
                }
            }
            return nil
        }
        
        /// Traverses the publisher object to get the underlying current value
        func getPublishedValue<Value>(from published: Combine.Published<Value>) -> Value? {
            let publishedMirror = Mirror(reflecting: published)
            let traverseValue: Value? = MirrorTraverser(mirror: publishedMirror)
                .traverse(by: "storage")?
                .traverse(by: "publisher")
                .traverse(by: "subject")
                .traverse(by: "currentValue")
                .value()
            
            return traverseValue
        }
        
        public subscript<Subject: Equatable>(
            dynamicMember keyPath: ReferenceWritableKeyPath<Dependency.Dependency, Subject>
        ) -> ChangePublisher<Subject> {
            var published = getPublishedWrapper(of: self.wrapped.wrappedValue, for: keyPath)
            return ChangePublisher(rootPublisher: published?.projectedValue)
        }
    }

    
    /// Used for wrapping an @Published property and forwarding published events through the StitchPublished projectedValue
    @MainActor
    public class ChangePublisher<Subject: Equatable> {
        private var cancellable: AnyCancellable?
        var publisher = Publisher<Subject>()
        
        internal init(
            rootPublisher: Combine.Published<Subject>.Publisher?
        ) {
            guard let rootPublisher else { return } // no publisher to forward events from
            // forward our published via our change publisher
            cancellable = rootPublisher.sink { value in
                self.publisher.send(value)
            }
        }
    }
    
    // MARK: Internal erased publisher
    /// A simple publisher wrapper for properties marked with the `@StitchPublished` attribute.
    /// Allows conversion of publishers to be Passthrough in nature rather than currentValue or other.
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
