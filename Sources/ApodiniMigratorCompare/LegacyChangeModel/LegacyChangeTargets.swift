//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Distinct cases of endpoint targets that are subject to change
enum LegacyEndpointTarget: String, Decodable {
    /// Indicates a change that relates to the endpoint itself, e.g. a deleted or added endpoint
    case `self`
    /// Indicates a change that relates to the identifier of the endpoint, e.g. updated to some new id
    case deltaIdentifier = "id"
    /// Query parameter target
    case queryParameter = "query-parameter"
    /// Path parameter target
    case pathParameter = "path-parameter"
    /// Content parameter target
    case contentParameter = "content-parameter"
    /// Path target
    case resourcePath = "resource-path"
    /// Operation target
    case operation = "http-method"
    /// Errors target
    case errors
    /// Response target
    case response
}

/// Distinct cases of object targets that are subject to change
enum LegacyObjectTarget: String, Decodable {
    /// Indicates a change that relates to the object itself, e.g. a deleted or added object
    case `self`
    /// TypeName target
    case typeName = "type-name"
    /// Property target
    case property
    /// Property necessity target
    case necessity = "property-necessity"
}

/// Distinct cases of enum targets that are subject to change
enum LegacyEnumTarget: String, Decodable {
    /// Indicates a change that relates to the enum itself, e.g. a deleted or added enum
    case `self`
    /// TypeName target
    case typeName = "type-name"
    /// Case target
    case `case`
    /// Case raw value target
    case caseRawValue = "raw-value"
    /// RawValue type target
    case rawValueType = "raw-value-type"
}

/// Distinct cases of networking service targets that are subject to change
enum LegacyNetworkingTarget: String, Decodable {
    /// Server path target, including the version path component
    case serverPath = "base-url"
    /// Encoder configuration target
    case encoderConfiguration = "encoder"
    /// Decoder configuration target
    case decoderConfiguration = "decoder"
}
