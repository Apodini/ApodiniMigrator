//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest
import RESTMigrator

protocol TestResource {
    var bundle: Bundle { get }

    var fileName: String { get }
    var bundleFileURL: URL { get }

    func content() -> String
}

extension TestResource {
    var bundle: Bundle { .module }

    var bundleFileURL: URL {
        guard let fileUrl = bundle.url(forResource: fileName, withExtension: nil) else {
            fatalError("Resource \(fileName) not found!")
        }

        return fileUrl
    }

    var bundlePath: Path {
        Path(bundleFileURL.path)
    }

    func content() -> String {
        guard let content = try? String(contentsOf: bundleFileURL, encoding: .utf8) else {
            fatalError("Failed to read the resource \(fileName)")
        }

        return content
    }

    func decodedContent<D: Decodable>() throws -> D {
        try D.decode(from: content())
    }
}
