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

/// Dependency container for resolving bound dependencies through Swift's `KeyPath` implementation.
///
/// Each `@StitchBinding` you declare in an extension of `StitchValues` is given an accessor, and
/// you use its key path wherever you inject the dependency.
///
/// The following code resolves a binding named `analytics`:
///
///     @Stitch(\.analytics) private var analytics
public struct StitchValues {
    public init() {}
}
