//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import XCTest
@testable import ApodiniMigratorCore

final class LegacyHTTPInformation: XCTestCase {
    func testLegacyServerPath() throws {
        XCTAssertEqual(
            try HTTPInformation(fromLegacyServerPath: "http://localhost:8080"),
            HTTPInformation(hostname: "localhost", port: 8080)
        )

        XCTAssertEqual(
            try HTTPInformation(fromLegacyServerPath: "http://localhost:8080/"),
            HTTPInformation(hostname: "localhost", port: 8080)
        )

        XCTAssertEqual(
            try HTTPInformation(fromLegacyServerPath: "http://localhost:8080/asdf"),
            HTTPInformation(hostname: "localhost", port: 8080)
        )

        XCTAssertEqual(
            try HTTPInformation(fromLegacyServerPath: "http://localhost:8080/asdf-asda_asdawd882"),
            HTTPInformation(hostname: "localhost", port: 8080)
        )

        XCTAssertEqual(
            try HTTPInformation(fromLegacyServerPath: "http://127.0.0.1:8080"),
            HTTPInformation(hostname: "127.0.0.1", port: 8080)
        )
    }
}
