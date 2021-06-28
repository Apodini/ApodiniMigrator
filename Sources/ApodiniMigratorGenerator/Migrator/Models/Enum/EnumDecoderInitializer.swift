//
//  EnumDecoderInitializer.swift
//  ApodiniMigratorGenerator
//
//  Created by Eldi Cano on 28.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Represents the `init(from:)` initializer of an `enum`
struct EnumDecoderInitializer: Renderable {
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
    func render() -> String {
        """
        public init(from decoder: Decoder) throws {
        self = Self(rawValue: try decoder.singleValueContainer().decode(RawValue.self)) ?? .\(defaultCase.name)
        }
        """
    }
}
