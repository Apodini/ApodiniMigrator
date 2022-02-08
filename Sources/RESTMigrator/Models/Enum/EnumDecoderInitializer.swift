//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

/// Represents the `init(from:)` initializer of an `enum`
struct EnumDecoderInitializer: SourceCodeRenderable {
    /// The default enum case to be set in the initializer
    let defaultCase: EnumCase
    
    /// Initializer
    init(_ cases: [EnumCase]) {
        guard let defaultCase = cases.first else {
            fatalError("Something went fundamentally wrong. Enum types supported by ApodiniMigrator, must be raw representable codables")
        }
        self.defaultCase = defaultCase
    }
    
    /// Renders the content of the initializer in a non-formatted way
    var renderableContent: String {
        "public init(from decoder: Decoder) throws {"
        Indent {
            "self = Self(rawValue: try decoder.singleValueContainer().decode(RawValue.self)) ?? .\(defaultCase.name)"
        }
        "}"
    }
}
