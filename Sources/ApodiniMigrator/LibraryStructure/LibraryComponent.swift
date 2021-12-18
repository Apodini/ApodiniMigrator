//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PathKit

public protocol LibraryComponent {
    // swiftlint:disable:next identifier_name
    func _handle(at path: Path, with context: MigrationContext) throws
}

extension Array { // TODO move to utils!
    func flatten<InnerElement>() -> [InnerElement] where Element == [InnerElement] {
        self.reduce(into: []) { result, element in
            result.append(contentsOf: element)
        }
    }
}
