//
// Created by Andreas Bauer on 29.11.21.
//

import Foundation

extension DeltaIdentifier {
    var swiftSanitizedName: String {
        // incomplete list of special characters
        rawValue
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: ":", with: "_")
    }
}
