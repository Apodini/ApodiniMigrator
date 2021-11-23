//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation
import PathKit

public protocol LibraryNode: LibraryComponent {
    func handle(at path: Path, with context: MigrationContext) throws
}

public extension LibraryNode {
    func _handle(at path: Path, with context: MigrationContext) throws {
        try handle(at: path, with: context)
    }
}
