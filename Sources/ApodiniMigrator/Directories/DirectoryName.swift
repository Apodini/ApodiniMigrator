//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// An enum that defines the names of the directories of a package generated by ApodiniMigrator
public enum DirectoryName: String {
    /// Sources
    case sources = "Sources"
    /// HTTP
    case http = "HTTP"
    /// Models
    case models = "Models"
    /// Resources
    case resources = "Resources"
    /// Endpoints
    case endpoints = "Endpoints"
    /// Networking
    case networking = "Networking"
    /// Utils
    case utils = "Utils"
    case pb_swift = "PB.SWIFT"
    case grpc_swift = "GRPC.SWIFT"
    /// Tests
    case tests = "Tests"
}

/// Path + DirectoryName
extension Path {
    init(_ directoryName: DirectoryName) {
        self.init(directoryName.rawValue)
    }
    
    static func + (lhs: Path, rhs: DirectoryName) -> Self {
        lhs + Path(rhs)
    }
}
