//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

enum PackageProductType {
    case library
    case executable
    case plugin
}

struct PackageProduct {
    let type: PackageProductType
    let name: [NameComponent]
    // TODO library type for type=.library is unsupported right now!
    let targets: [[NameComponent]]
}

extension PackageProduct {
    func description(with context: MigrationContext) -> String {
        """
        .\(type)(name: \"\(name.description(with: context))\", targets: [\( targets.map { "\"\($0.description(with: context))\""}.joined(separator: ",\n") )])
        """
    }
}
