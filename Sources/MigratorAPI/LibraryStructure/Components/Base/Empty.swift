//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation
import PathKit // TODO export?

public struct Empty: LibraryNode {
    public init() {}

    public func handle(at: Path, with context: MigrationContext) {}
}
