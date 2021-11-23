//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

extension Placeholder: NameComponent {
    public func description(with context: MigrationContext) -> String {
        guard let value = context.placeholderValues[self] else {
            fatalError("Could not find value for placeholder \(self)")
        }

        return value
    }
}
