//
//  EnumEncodingMethod.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 29.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Represents `encode(to:)` method of an Enum object
struct EnumEncodingMethod: Renderable {
    /// Renders the content of the method in a non-formatted way
    func render() -> String {
        """
        public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
                
        try container.encode(encodableValue().rawValue)
        }
        """
    }
}
