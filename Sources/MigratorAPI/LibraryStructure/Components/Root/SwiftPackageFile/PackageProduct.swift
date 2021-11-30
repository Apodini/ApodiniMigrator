//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

enum PackageProductType {
    case library
    case executable
    case plugin
}

struct PackageProduct: SourceCodeRenderable {
    let type: PackageProductType
    let name: [NameComponent]
    // Note: Library type for type=`.library` is unsupported right now!
    let targets: [[NameComponent]]

    var renderableContent: String {
        """
        .\(type)(name: "\(name.nameString)", targets: [\(
            targets.map { "\"\($0.nameString)\"" }.joined(separator: ",")
        )])
        """
    }
}
