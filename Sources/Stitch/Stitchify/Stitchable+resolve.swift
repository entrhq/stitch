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

extension Stitchable {
    public static func resolve(key: ScopeContextKey? = nil) -> Dependency {
        switch scope {
        case .application: return createOrFetchInstance(for: defaultScopeContextKey) // always use the default instance and ignore any key
        case .unique: return factories[defaultScopeContextKey]() // create a new instance every time
        case .keyed: return createOrFetchInstance(for: key ?? defaultScopeContextKey) // retrieves instance or creates a new one for the context
        }
    }
    
    static func createOrFetchInstance(for key: ScopeContextKey) -> Dependency {
        // dependency already exists in instances so reuse
        if let instance = instances[key] { return instance }
        // otherwise create a new dependency and save for recall
        let new = factories[key]()
        instances[key] = new
        return new
    }
}
