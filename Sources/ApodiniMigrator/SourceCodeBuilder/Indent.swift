//
// Created by Andreas Bauer on 30.11.21.
//

import Foundation

public struct Indent: SourceCodeComponent {
    private let identString: String
    private let content: [SourceCodeComponent]

    public init(
        with identString: String = "    ",
        @SourceCodeComponentBuilder content: () -> [SourceCodeComponent]
    ) {
        self.identString = identString
        self.content = content()
    }

    public func render() -> [String] {
        content
            .map { $0.render() }
            .flatten()
            .map { identString + $0 }
    }
}
