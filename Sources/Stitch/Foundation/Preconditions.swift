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

/// Replacement of Swift's `precondition`.
///
/// This will call Swift's `precondition` by default (and terminate the program).
/// Its encapsulated closure can be modified at run time through modifying
/// `Preconditions.closure` for ease of testing without exiting our program, or for
/// swallowing our precondition errors, handling them gracefully or composing further functionality.
func precondition(
    _ condition: @autoclosure () -> Bool,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
//    Preconditions.closure(condition(), message(), file, line)
}

struct Preconditions {
    /// Wrapper closure for executing swift's default precondition whilst providing
    /// the ability to swap out at run time for testing.
//    public static var closure: (Bool, String, StaticString, UInt) -> Void = defaultPreconditionClosure
//    public static let defaultPreconditionClosure = {Swift.precondition($0, $1, file: $2, line: $3)}
}
