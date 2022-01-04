//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// A protocol that represents a change that can appear in the Migration Guide
protocol LegacyChange: Decodable {
    /// Top-level changed element related to the change
    var element: LegacyChangeElement { get }
    /// Type of change
    var type: LegacyChangeType { get }
    /// Indicates whether the change is non-backward compatible
    var breaking: Bool { get }
    /// Indicates whether the change can be handled by `ApodiniMigrator`
    var solvable: Bool { get }
}
