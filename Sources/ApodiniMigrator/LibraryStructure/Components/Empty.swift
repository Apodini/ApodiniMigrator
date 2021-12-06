//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation

public struct Empty: LibraryNode {
    public init() {}

    public func handle(at path: Path, with context: MigrationContext) {}
}
