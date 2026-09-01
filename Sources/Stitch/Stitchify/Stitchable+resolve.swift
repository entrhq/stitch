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
    public static func resolve() -> Dependency {
        switch scope {
        case .application: return createOrFetchInstance() // always use the same instance
        case .unique: return factory() // create a new instance every time
        }
    }
    
    static func createOrFetchInstance() -> Dependency {
        // dependency already exists so reuse
        if let instance { return instance }
        // otherwise create a new dependency and save for recall
        let new = factory()
        instance = new
        return new
    }
}
