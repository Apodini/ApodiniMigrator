//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

public struct Placeholder: CustomStringConvertible {
    public var description: String {
        "___\(name)___"
    }

    public var name: String

    public init(_ name: String) {
        self.name = name
    }
}

extension Placeholder: Equatable {}

extension Placeholder: Hashable {}
