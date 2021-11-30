//
// Created by Andreas Bauer on 29.11.21.
//

import Foundation

public struct StringFile: GeneratedFile {
    public let fileName: [NameComponent]
    public let renderableContent: String

    public init(name fileName: NameComponent..., content: String) {
        self.fileName = fileName
        self.renderableContent = content
    }

    public init(name fileName: NameComponent..., @SourceCodeBuilder content: () -> String) {
        self.fileName = fileName
        self.renderableContent = content()
    }
}
