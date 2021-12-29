//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// One to one mapping of enum cases of the ``Change`` type.
public enum ChangeType: String, Codable {
    case idChange
    case addition
    case removal
    case update
}

// MARK: ChangeType
extension Change {
    /// Retrieve the type of change.
    public var type: ChangeType {
        switch self {
        case .idChange:
            return .idChange
        case .addition:
            return .addition
        case .removal:
            return .removal
        case .update:
            return .update
        }
    }
}
