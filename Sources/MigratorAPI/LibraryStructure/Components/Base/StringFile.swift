//
// Created by Andreas Bauer on 29.11.21.
//

import Foundation

public struct StringFile: GeneratedFile {
    public let fileName: [NameComponent]
    public let fileContent: String

    public init(name fileName: NameComponent..., content: String) {
        self.fileName = fileName
        self.fileContent = content
    }

    public init(name fileName: NameComponent..., @FileCodeStringBuilder content: () -> String) {
        self.fileName = fileName
        self.fileContent = content()
    }
}
