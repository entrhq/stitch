import Stitch
import SwiftUI

/// Observable object carrying one published and one plain property
///
/// The projected value of `StitchPublished` finds the publisher behind a property by reflection,
/// so testing it needs an object where one property has a publisher and one does not.
@MainActor
protocol PartiallyPublishedTestProtocol: ObservableObject, AnyObservableObject {
    var publishedProperty: String { get set }
    var plainProperty: String { get set }
    func change(to value: String)
}

@MainActor
@Stitchify(by: PartiallyPublishedTestProtocol.self)
class PartiallyPublishedObject: PartiallyPublishedTestProtocol {
    required init() {}
    @Published var publishedProperty: String = "published"
    var plainProperty: String = "plain"

    func change(to value: String) {
        publishedProperty = value
    }
}
