//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// OutputFormat cases for encodable instances
public enum OutputFormat: String {
    /// JSON output format
    case json
    /// YAML output format
    case yaml
    
    /// Returns the string representation of `encodable`
    public func string<E: Encodable>(of encodable: E) -> String {
        switch self {
        case .json: return encodable.json
        case .yaml: return encodable.yaml
        }
    }
}
