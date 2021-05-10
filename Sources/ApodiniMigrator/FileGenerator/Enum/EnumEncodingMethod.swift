//
//  File.swift
//  
//
//  Created by Eldi Cano on 09.05.21.
//

import Foundation


/// Represents `encode(to:)` method of an Enum object
struct EnumEncodingMethod: Renderable {
    /// The cases of the enum
    let cases: [EnumCase]
    
    /// Initializer
    init(_ cases: [EnumCase]) {
        self.cases = cases
    }
    
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
