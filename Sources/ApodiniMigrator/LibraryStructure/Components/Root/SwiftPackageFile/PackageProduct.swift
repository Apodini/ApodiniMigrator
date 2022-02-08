//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

enum PackageProductType {
    case library
    case executable
    case plugin
}

struct PackageProduct: SourceCodeRenderable {
    let type: PackageProductType
    let name: Name
    // Note: Library type for type=`.library` is unsupported right now!
    let targets: [Name]

    var renderableContent: String {
        """
        .\(type)(name: "\(name.description)", targets: [\(
            targets.map { "\"\($0.description)\"" }.joined(separator: ",")
        )])
        """
    }
}
