//
//  File.swift
//  
//
//  Created by Eldi Cano on 09.05.21.
//

import Foundation

/// Represents `encode(to:)` method of an Enum object
struct EnumEncodingMethod: Renderable {
    /// Renders the content of the method in a non-formatted way
    func render() -> String {
        """
        func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
                
        try container.encode(encodableValue().rawValue)
        }
        """
    }
}
