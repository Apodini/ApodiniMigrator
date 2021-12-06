//
// Created by Andreas Bauer on 30.11.21.
//

import Foundation

public struct Indent: SourceCodeComponent {
    private let indentString: String
    private let content: [SourceCodeComponent]

    public init(with indentString: String = "    ", _ content: String) {
        self.indentString = indentString
        self.content = [content]
    }

    public init(
        with indentString: String = "    ",
        @SourceCodeComponentBuilder content: () -> [SourceCodeComponent]
    ) {
        self.indentString = indentString
        self.content = content()
    }

    public func render() -> [String] {
        content
            .map { $0.render() }
            .flatten()
            .map { indentString + $0 }
    }
}
