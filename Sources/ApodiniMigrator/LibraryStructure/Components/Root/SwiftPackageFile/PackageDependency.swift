//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
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
