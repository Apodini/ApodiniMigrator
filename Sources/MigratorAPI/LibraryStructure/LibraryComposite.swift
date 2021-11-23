//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation
import PathKit

public protocol LibraryComposite: LibraryComponent {
    @DefaultLibraryComponentBuilder
    var content: [LibraryComponent] { get }
}

public extension LibraryComposite {
    func _handle(at path: Path, with context: MigrationContext) throws {}
}
