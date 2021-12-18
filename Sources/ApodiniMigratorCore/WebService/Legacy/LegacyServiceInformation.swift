//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct LegacyServiceInformation: Codable {
    let version: Version
    let serverPath: String
    let encoderConfiguration: EncoderConfiguration
    let decoderConfiguration: DecoderConfiguration
}

extension ServiceInformation {
    init(from information: LegacyServiceInformation) throws {
        let range = NSRange(information.serverPath.startIndex..., in: information.serverPath)
        let regex = try! NSRegularExpression(pattern: "^http://(.+):([0-9]+)(/[a-zA-Z]+)?$")

        guard let match = regex.firstMatch(in: information.serverPath, range: range) else {
            throw APIDocument.CodingError.failedServicePathMigration(path: information.serverPath)
        }

        guard let hostname = information.serverPath.retrieveMatch(match: match, at: 1),
              let portString = information.serverPath.retrieveMatch(match: match, at: 2) else {
            throw APIDocument.CodingError.failedServicePathMigration(path: information.serverPath)
        }

        guard let port = Int(portString) else {
            throw APIDocument.CodingError.failedServicePathMigration(path: information.serverPath)
        }

        self.init(
            version: information.version,
            http: HTTPInformation(hostname: hostname, port: port),
            exporters: [
                RESTExporterConfiguration(
                    encoderConfiguration: information.encoderConfiguration,
                    decoderConfiguration: information.decoderConfiguration)
            ]
        )
    }
}

private extension String {
    /// Retrieves the substring of a matched group of a `NSTextCheckingResult`.
    /// - Parameters:
    ///   - match: The match (corresponding to the self String)
    ///   - at: The group number to retrieve
    /// - Returns: The matched substring for the given group
    func retrieveMatch(match: NSTextCheckingResult, at: Int) -> String? {
        let rangeBounds = match.range(at: at)
        guard let range = Range(rangeBounds, in: self) else {
            return nil
        }

        return String(self[range])
    }
}
