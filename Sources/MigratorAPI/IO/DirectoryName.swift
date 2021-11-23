//
// Created by Andreas Bauer on 14.11.21.
//

import Foundation

public struct DirectoryName: RawRepresentable {
    public var rawValue: String

    public init?(rawValue: String) {
        self.init(rawValue)
    }

    public init(_ name: String) {
        precondition(!name.contains("/"), "Directory name cannot include SEPARATOR string!")
        self.rawValue = name
    }
}

extension DirectoryName: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

public extension DirectoryName {
    static var sources: Self = .init("Sources")
    static var tests: Self = .init("Tests")
}
