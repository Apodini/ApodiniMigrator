//
// Created by Andreas Bauer on 30.11.21.
//

import Foundation

public protocol SourceCodeComponent {
    func render() -> [String]
}

extension String: SourceCodeComponent {
    /// Every String is interpreted as a single line in the resulting code file.
    /// Therefore the render method always appends a line separator symbol.
    public func render() -> [String] {
        self
            .split(separator: "\n", omittingEmptySubsequences: false) // TODO is this needed?
            .map { String($0) }
    }
}
