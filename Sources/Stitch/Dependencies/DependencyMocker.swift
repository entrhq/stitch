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

// MARK: - Dependency mocking
@MainActor
public protocol DependencyMocker {
    func mockInViewScope<Dependency>(_ stitchable: any Stitchable<Dependency>.Type, mock: Dependency) -> EmptyView
}

@MainActor
extension DependencyMocker {
    // MARK: Mock inside ViewBuilder and View bodies
    public func mockInViewScope<Dependency>(
        _ stitchable: any Stitchable<Dependency>.Type,
        mock: Dependency
    ) -> EmptyView {
        stitchable.register(dependency: mock)
        // Returns an empty view for use inside a view scope
        return EmptyView()
    }
}
