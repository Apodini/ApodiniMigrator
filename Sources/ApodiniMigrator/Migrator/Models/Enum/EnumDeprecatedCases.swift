//
//  EnumDeprecatedCases.swift
//  ApodiniMigrator
//
//  Created by Eldi Cano on 29.06.21.
//  Copyright © 2021 TUM LS1. All rights reserved.
//

import Foundation

/// Represents the deprecetad cases static property on an `enum` declaration
struct EnumDeprecatedCases: Renderable {
    /// Name of the deprecated cases variable
    static let variableName = "deprecatedCases"
    /// String description of the static variable
    private static let base = "private static let \(variableName): [Self] = "
    
    /// Names of deprecated cases of the enum
    private let deprecatedCaseNames: [String]
    
    /// Initializes a new instance out of the deprecated cases of an enum
    init(deprecated: [EnumCase] = []) {
        self.deprecatedCaseNames = deprecated.map { $0.name }
    }
    
    /// Renders the deprecated cases static variable
    func render() -> String {
        """
        \(Self.base)[\(deprecatedCaseNames.map { ".\($0)" }.joined(separator: ", "))]
        """
    }
}
