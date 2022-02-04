//
// This source file is part of the Apodini open source project
//
// SPDX-FileCopyrightText: 2019-2022 Paul Schmiedmayer and the Apodini project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ApodiniContext

/// Some sort of identifier for `TypeInformation`-
public protocol TypeInformationIdentifier: ElementIdentifier {}

public struct TypeInformationIdentifierContextKey: CodableContextKey, ContextKey {
    public typealias Value = ElementIdentifierStorage
    public static var defaultValue = ElementIdentifierStorage()
}
