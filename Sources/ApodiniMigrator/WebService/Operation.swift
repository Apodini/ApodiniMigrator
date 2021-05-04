

import Foundation

/** Operation from Apodini*/

/// Defines the Operation of a given endpoint
enum Operation: String, CaseIterable, CustomStringConvertible, ComparableProperty {
    /// The associated endpoint is used for a `create` operation
    case create
    /// The associated endpoint is used for a `read` operation
    case read
    /// The associated endpoint is used for a `update` operation
    case update
    /// The associated endpoint is used for a `delete` operation
    case delete

    var description: String {
        rawValue
    }
}
