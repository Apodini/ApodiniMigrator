//
// Created by Andreas Bauer on 30.11.21.
//

import Foundation

public protocol SourceCodeRenderable: SourceCodeComponent {
    @SourceCodeBuilder
    var renderableContent: String { get }
}

public extension SourceCodeRenderable {
    func render() -> [String] {
        renderableContent
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { String($0) }
    }
}
