//
//  File.swift
//  
//
//  Created by Eldi Cano on 08.05.21.
//

import Foundation

/// Represents `encode(to:)` method of an Encodable object
struct EncodingMethod: Renderable {
    /// The properties of the object that this method belongs to
    let properties: [TypeProperty]
    
    /// Initializer
    init(_ properties: [TypeProperty]) {
        self.properties = properties
    }
    
    /// Renders the content of the method in a non-formatted way
    func render() -> String {
        """
        public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        \(properties.map { "\($0.encodingMethodLine)" }.lineBreaked)
        }
        """
    }
}

/// TypeProperty extension
extension TypeProperty {
    /// The corresponding line of the property to be rendered inside `encode(to:)` method
    var encodingMethodLine: String {
        "try container.encode(\(name), forKey: .\(name))"
    }
}
