//
//  File.swift
//  
//
//  Created by Eldi Cano on 10.05.21.
//

import Foundation

struct EnumEncodeValueMethod: Renderable {
    /// The deleted cases of the enum
    let deletedCases: [EnumCase]
    
    /// Initializer
    init(_ deletedCases: [EnumCase] = []) {
        self.deletedCases = deletedCases
    }
    
    /// Renders the content of the initializer in a non-formatted way
    func render() -> String {
        """
        private func encodableValue() -> Self {
        let deletedCases: [Self] = [\(deletedCases.map { ".\($0.name.value)" }.joined(separator: ", "))]
        guard deletedCases.contains(self) else {
        return self
        }
        if let alternativeCase = Self.allCases.first(where: { !deletedCases.contains($0) }) {
        return alternativeCase
        }
        fatalError("The web service does not support the cases of this enum anymore")
        }
        """
    }
}
