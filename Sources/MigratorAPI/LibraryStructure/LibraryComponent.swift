//
// Created by Andreas Bauer on 15.11.21.
//

import Foundation
import PathKit

public protocol LibraryComponent {
    func _handle(at path: Path, with context: MigrationContext) throws
}

extension Array { // TODO move to utils!
    func flatten<InnerElement>() -> [InnerElement] where Element == [InnerElement] {
        self.reduce(into: []) { result, element in
            result.append(contentsOf: element)
        }
    }
}
