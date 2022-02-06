//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit
import ApodiniDocumentExport

public extension Path {
    /// Returns all swift files in `self` and in subdirectories of `self`
    func recursiveSwiftFiles() throws -> [Path] {
        guard isDirectory else {
            return []
        }
        return try recursiveChildren().filter { $0.is(.swift) }
    }
}
