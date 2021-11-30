//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

/// Represents the deprecated cases static property on an `enum` declaration
struct EnumDeprecatedCases: SourceCodeRenderable {
    /// Name of the deprecated cases variable
    static let variableName = "deprecatedCases"
    /// String description of the static variable
    private static let base = "private static let \(variableName): [Self] = "
    
    /// Names of deprecated cases of the enum
    private let deprecatedCaseNames: [String]
    
    /// Initializes a new instance out of the deprecated cases of an enum
    init(deprecated: [EnumCase] = []) {
        self.deprecatedCaseNames = deprecated.map { $0.name }
    }

    /// Renders the deprecated cases static variable
    var renderableContent: String {
        "\(Self.base)[\(deprecatedCaseNames.map { ".\($0)" }.joined(separator: ", "))]"
    }
}
