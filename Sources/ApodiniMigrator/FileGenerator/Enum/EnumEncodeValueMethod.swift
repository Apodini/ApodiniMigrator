//
//  File.swift
//  
//
//  Created by Eldi Cano on 10.05.21.
//

import Foundation

struct EnumDeprecatedCases: Renderable {
    static let base = "private static let deprecatedCases: [Self] = "
    func render() -> String {
        """
        \(Self.base)[]
        """
    }
}

struct EnumEncodeValueMethod: Renderable {
    
    /// Renders the content of the initializer in a non-formatted way
    func render() -> String {
        """
        private func encodableValue() -> Self {
        let deprecated = Self.deprecatedCases
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
