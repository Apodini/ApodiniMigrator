//
// Created by Andreas Bauer on 30.11.21.
//

import Foundation

public struct Group: SourceCodeComponent { // TODO document, only really useful in combination with the Joined operator!
    private let content: [SourceCodeComponent]

    public init(@SourceCodeComponentBuilder content: () -> [SourceCodeComponent]) {
        self.content = content()
    }

    internal init(content: [SourceCodeComponent]) {
        self.content = content
    }

    public func render() -> [String] {
        content
            .map { $0.render() }
            .flatten()
    }
}
