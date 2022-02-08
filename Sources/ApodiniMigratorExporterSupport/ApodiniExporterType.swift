//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Describes an Apodini exporter type.
public enum ApodiniExporterType: String, Codable, Hashable, CodingKey, CaseIterable {
    /// The `ApodiniREST` exporter.
    case rest
    /// The `ApodiniGRPC` exporter.
    case grpc
}
