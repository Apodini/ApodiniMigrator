//
// Created by Andreas Bauer on 14.11.21.
//

import Foundation

public struct FileName {
    let name: String
    let `extension`: FileExtension?

    public init(_ name: String, `extension`: FileExtension?) {
        self.name = name
        self.`extension` = `extension`
    }
}

extension FileName: RawRepresentable {
    public var rawValue: String {
        if let ext = self.extension {
            return name + "." + ext.rawValue
        }

        return name
    }

    public init?(rawValue: String) {
        let split = rawValue.split(separator: ".")

        // TODO implement!
        fatalError("Not yet implemented")
    }
}

// MARK: Known Files
public extension FileName {
    static let readme: Self = .init("README", extension: .markdown)
    static let swiftPackageFile: Self = .init("Package", extension: .swift)
}
