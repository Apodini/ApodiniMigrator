//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.05.21.
//

import Foundation

struct EnumDeprecatedCases: Renderable {
    static let base = "private static let deprecatedCases: [Self] = "
    
    let deprecated: [EnumCase]
    
    init(deprecated: [EnumCase] = []) {
        self.deprecated = deprecated
    }
    
    func render() -> String {
        """
        \(Self.base)[\(deprecated.map { ".\($0.name)" }.joined(separator: ", "))]
        """
    }
}
