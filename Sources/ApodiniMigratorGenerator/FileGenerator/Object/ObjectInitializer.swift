//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.05.21.
//

import Foundation

/// Represents initializer of an object
struct ObjectInitializer: Renderable {
    /// The properties of the object that this initializer belongs to
    var properties: [TypeProperty]
    
    /// Initializer
    init(_ properties: [TypeProperty]) {
        self.properties = properties
    }
    
    /// Renders the content of the initializer in a non-formatted way
    func render() -> String {
        """
        public init(
        \(properties.map { "\($0.name.value): \($0.type.typeString)" }.joined(separator: ",\(String.lineBreak)"))
        ) {
        \(properties.map { "\($0.initLine)" }.lineBreaked)
        }
        """
    }
}

/// TypeProperty extension
extension TypeProperty {
    /// The corresponding line of the property to be rendered inside `init(from decoder: Decoder)`
    var initLine: String {
        "self.\(name.value) = \(name.value)"
    }
}
