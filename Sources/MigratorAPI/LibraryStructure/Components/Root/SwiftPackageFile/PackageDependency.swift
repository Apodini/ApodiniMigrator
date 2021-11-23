//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

struct PackageDependency {
    var name: String?
    var url: String
    var requirementString: String
}

extension PackageDependency: CustomStringConvertible {
    var description: String {
        """
        .package(\(name != nil ? "name: \"\(name ?? "")\", " : "")url: \"\(url)\", \(requirementString))
        """
    }
}
