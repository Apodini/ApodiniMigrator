//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

public protocol NameComponent: CustomStringConvertible {
    func description(with context: MigrationContext) -> String
}

public extension Array where Element == NameComponent {
    func description(with context: MigrationContext) -> String {
        self
            .map { component in
                component.description(with: context)
            }
            .joined()
    }
}

extension Array where Element == NameComponent {
    public var nameString: String {
        self.map { $0.description }.joined()
    }
}
