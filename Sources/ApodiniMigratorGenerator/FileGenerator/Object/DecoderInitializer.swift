//
//  File.swift
//  
//
//  Created by Eldi Cano on 08.05.21.
//

import Foundation

/// Represents `init(from decoder: Decoder)` initializer of a Decodable object
struct DecoderInitializer: Renderable {
    /// The properties of the object that this initializer belongs to
    var properties: [TypeProperty]
    
    /// Initializer
    init(_ properties: [TypeProperty]) {
        self.properties = properties
    }
    
    /// Renders the content of the initializer in a non-formatted way
    func render() -> String {
        """
        public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        \(properties.map { "\($0.decoderInitLine)" }.lineBreaked)
        }
        """
    }
}

/// TypeProperty extension
extension TypeProperty {
    /// The corresponding line of the property to be rendered inside `init(from decoder: Decoder)`
    var decoderInitLine: String {
        let decodeMethodString = "decode\(type.isOptional ? "IfPresent" : "")"
        return "\(name.value) = try container.\(decodeMethodString)(\(type.typeString.dropQuestionMark).self, forKey: .\(name.value))"
    }
}
