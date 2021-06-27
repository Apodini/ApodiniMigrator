//
//  EnumEncodeValueMethod.swift
//  
//
//  Created by Eldi Cano on 10.05.21.
//

import Foundation

/// Represents the `encodableValue()` util method in an enum
struct EnumEncodeValueMethod: Renderable {
    /// Renders the content of the initializer in a non-formatted way
    func render() -> String {
        """
        private func encodableValue() -> Self {
        let deprecated = Self.\(EnumDeprecatedCases.variableName)
        guard deprecated.contains(self) else {
        return self
        }
        if let alternativeCase = Self.allCases.first(where: { !deprecated.contains($0) }) {
        return alternativeCase
        }
        fatalError("The web service does not support the cases of this enum anymore")
        }
        """
    }
}
