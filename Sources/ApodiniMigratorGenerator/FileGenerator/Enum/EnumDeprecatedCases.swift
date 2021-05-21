//
//  File.swift
//  
//
//  Created by Eldi Cano on 21.05.21.
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
