//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// Distinct case of default input of endpoint methods
enum DefaultEndpointInput: String, CaseIterable, Hashable {
    /// Authorization
    case authorization
    /// HTTP headers
    case httpHeaders
    
    /// String representation of `self` in endpoint method signature
    var signature: String {
        switch self {
        case .authorization: return "\(rawValue): String? = nil"
        case .httpHeaders: return "\(rawValue): HTTPHeaders = [:]"
        }
    }
    
    /// `self` as a key-value pair, e.g. `authorization: authorization`. Variable used inside of API file methods
    var keyValue: String {
        "\(rawValue): \(rawValue)"
    }
}
