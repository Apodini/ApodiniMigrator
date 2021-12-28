//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct LegacyServiceInformation: Codable {
    enum MigrationError: Error {
        case failedMath(path: String)
        case failedHostnameExtraction(path: String)
        case failedPortConversion(path: String)
    }

    let version: Version
    let serverPath: String
    let encoderConfiguration: EncoderConfiguration
    let decoderConfiguration: DecoderConfiguration
}

extension HTTPInformation {
    /// Initialize a `HTTPInformation` from a legacy style server path string.
    /// - Parameter serverPath: The server path string e.g. formatted as follows: "http://<hostname>:<port>[/optional-path]"
    /// - Throws: Throws `LegacyServiceInformation.MigrationError` if encountering malformed format.
    public init(fromLegacyServerPath serverPath: String) throws {
        let range = NSRange(serverPath.startIndex..., in: serverPath)
        // swiftlint:disable:next force_try
        let regex = try! NSRegularExpression(pattern: "^http://(.+):([0-9]+)(/(\\w|\\d)+)?$")

        guard let match = regex.firstMatch(in: serverPath, range: range) else {
            throw LegacyServiceInformation.MigrationError.failedMath(path: serverPath)
        }

        guard let hostname = serverPath.retrieveMatch(match: match, at: 1),
              let portString = serverPath.retrieveMatch(match: match, at: 2) else {
            throw LegacyServiceInformation.MigrationError.failedHostnameExtraction(path: serverPath)
        }

        guard let port = Int(portString) else {
            throw LegacyServiceInformation.MigrationError.failedPortConversion(path: serverPath)
        }

        self.hostname = hostname
        self.port = port
    }
}

extension ServiceInformation {
    init(from information: LegacyServiceInformation) throws {
        let http = try HTTPInformation(fromLegacyServerPath: information.serverPath)

        self.init(
            version: information.version,
            http: http,
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
