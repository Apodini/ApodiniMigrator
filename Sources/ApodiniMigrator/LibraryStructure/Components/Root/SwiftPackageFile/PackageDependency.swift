//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

struct PackageDependency: SourceCodeRenderable {
    var name: String?
    var url: String
    var requirementString: String

    var renderableContent: String {
        """
        .package(\(name != nil ? "name: \"\(name ?? "")\", " : "")url: \"\(url)\", \(requirementString))
        """
    }
}
