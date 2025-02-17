//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniMigrator

protocol Changeable: AnyObject {
    associatedtype Element: ChangeableElement

    func applyIdChange(_ change: Change<Element>.IdentifierChange)

    func applyUpdateChange(_ change: Change<Element>.UpdateChange)

    func applyRemovalChange(_ change: Change<Element>.RemovalChange)
}

extension Changeable {
    func applyIdChange(_ change: Change<Element>.IdentifierChange) {
        // default is to do nothing. Identifier changes typically don't have any effects for grpc
    }
}
