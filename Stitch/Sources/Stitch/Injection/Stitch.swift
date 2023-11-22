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

@propertyWrapper
public struct Stitch<Dependency>: DependencyLifecycleScope {
    private let keyPath: WritableKeyPath<DependencyMap, Dependency>
    public var wrappedValue: Dependency {
        get { resolve(keyPath) }
        set { register(keyPath, dependency: newValue) }
    }
    
    public init(_ keyPath: WritableKeyPath<DependencyMap, Dependency>) {
        self.keyPath = keyPath
    }
}

@propertyWrapper
public struct Stitched<Dependency: Stitchable>: DependencyLifecycleScope {
    private let stitchedType: (Dependency).Type
    public var wrappedValue: Dependency.Dependency {
        get { stitchedType.resolve() }
        set { stitchedType.register(dependency: newValue) }
    }
    
    public init(_ type: (Dependency).Type) {
        self.stitchedType = type
    }
}
