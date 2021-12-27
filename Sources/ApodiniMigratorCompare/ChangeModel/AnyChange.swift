//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation

public protocol AnyChange {
    associatedtype Element: ChangeableElement

    var id: DeltaIdentifier { get }
    var type: ChangeType { get }

    var breaking: Bool { get }
    var solvable: Bool { get }
}

fileprivate extension AnyChange {
    func typed() -> Change<Element> {
        guard let change = self as? Change<Element> else {
            fatalError("Encountered `AnyChange` which isn't of expected type `ChangeEnum`!")
        }
        return change
    }
}

public extension Array where Element: AnyChange {
    func of(base element: Element.Element) -> [Element] {
        self.filter { $0.id == element.deltaIdentifier }
    }
}
