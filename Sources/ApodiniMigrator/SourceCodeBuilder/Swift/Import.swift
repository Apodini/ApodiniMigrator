//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// An object representing imports of a Swift file
public struct Import: SourceCodeRenderable {
    /// Distinct framework cases that can be imported in `ApodiniMigrator`
    public enum Frameworks: String {
        case foundation
        case combine
        case apodiniMigrator
        case apodiniMigratorClientSupport
        case xCTest

        /// String representation of the import
        var string: String {
            "import \(rawValue.upperFirst)"
        }
    }

    /// Set of to be imported frameworks
    private var frameworks: Set<String>
    private var testable: Bool

    /// Initializes `self` with `frameworks`
    public init(_ frameworks: Frameworks..., testable: Bool = false) {
        self.frameworks = Set(frameworks.map { $0.string })
        self.testable = testable
    }

    public init(_ frameworks: String..., testable: Bool = false) {
        self.frameworks = Set(frameworks.map { "import " + $0 })
        self.testable = testable
    }

    /// Inserts `framework`
    public mutating func insert(_ framework: Frameworks, testable: Bool = false) {
        precondition(self.testable == testable)
        frameworks.insert(framework.string)
    }

    /// String representation of `frameworks`
    /// One line per framework, no empty lines in between
    public var renderableContent: String {
        for framework in frameworks.sorted() {
            if testable {
                "@testable \(framework)"
            } else {
                framework
            }
        }
    }
}
