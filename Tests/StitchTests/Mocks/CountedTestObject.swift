import Stitch

/// Reference type carrying a unique `id` so that tests can tell one instance from another
///
/// Scope behaviour is defined by instance identity, so comparing two ids tells you whether a
/// resolve returned a cached instance or built a new one.
protocol CountedTestProtocol: AnyObject {
    var id: Int { get }
}

/// Monotonic source of instance ids
@MainActor
enum InstanceCounter {
    private static var count = 0

    static func next() -> Int {
        count += 1
        return count
    }
}

/// Stand-in implementation used to assert that a registered factory replaced the default one
@MainActor
final class MockCountedObject: CountedTestProtocol {
    let id = InstanceCounter.next()
    init() {}
}
