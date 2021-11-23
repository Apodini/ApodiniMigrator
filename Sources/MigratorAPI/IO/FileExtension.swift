//
// Created by Andreas Bauer on 14.11.21.
//

import Foundation

public struct FileExtension: RawRepresentable {
    public var rawValue: String

    public init?(rawValue: String) {
        self.init(rawValue)
    }

    public init(_ `extension`: String) {
        self.rawValue = `extension`
    }
}

extension FileExtension: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

public extension FileExtension {
    static let markdown: Self = .init("md")
    static let json: Self = .init("json")
    static let swift: Self = .init("swift")
    // TODO other files?
}
